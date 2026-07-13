/* ============================================================
   MODULE 01 – ENVIRONMENT SETUP & GLOBAL OPTIONS
   ============================================================ */

options
  compress    = yes
  fullstimer
  mlogic
  mprint
  symbolgen
  ls          = 200
  ps          = 60
  nodate
  nonumber
  validvarname= upcase
  obs         = max
  errors      = 20
  threads
  cpucount    = actual;

/* Suppress Notes in production; remove for debugging */
/* options nonotes; */

title   "EY Analytics – Enterprise Reporting Suite";
footnote "CONFIDENTIAL – For Internal Use Only";

/* ============================================================
   MODULE 02 – GLOBAL MACRO VARIABLES
   ============================================================ */

%let PROJECT_NAME    = EGP_Analytics_Project;
%let PROJECT_VERSION = 1.0.0;
%let RUN_DATE        = %sysfunc(today(), yymmdd10.);
%let RUN_DTTM        = %sysfunc(datetime(), datetime20.);
%let BASE_PATH       = ./sasdata;
%let RAW_PATH        = &BASE_PATH./raw;
%let STAGE_PATH      = &BASE_PATH./staging;
%let OUTPUT_PATH     = &BASE_PATH./output;
%let LOG_PATH        = &BASE_PATH./logs;
%let REPORT_PATH     = &BASE_PATH./reports;

/* Reporting periods */
%let RPT_YEAR        = 2025;
%let RPT_MONTH       = 12;
%let RPT_QTR         = 4;
%let PERIOD_START    = 01JAN2025;
%let PERIOD_END      = 31DEC2025;

/* Thresholds */
%let MISSING_THRESHOLD  = 0.05;   /* 5%  missing tolerance            */
%let OUTLIER_STD        = 3;      /* ±3σ outlier boundary             */
%let MIN_CELL_COUNT     = 5;      /* Minimum cell count for chi-sq    */

/* Model parameters */
%let TRAIN_RATIO     = 0.75;
%let SEED            = 42;
%let ALPHA           = 0.05;

/* ============================================================
   MODULE 03 – UTILITY MACROS
   ============================================================ */

/* ----------------------------------------------------------
   3.1  %LOG_MESSAGE – Timestamped log writer
   ---------------------------------------------------------- */
%macro LOG_MESSAGE(LEVEL=INFO, MSG=);
  %local _ts;
  %let _ts = %sysfunc(datetime(), datetime20.);
  %put &_ts [&LEVEL] &MSG;
%mend LOG_MESSAGE;

/* ----------------------------------------------------------
   3.2  %CHECK_DATASET – Verify dataset existence
   ---------------------------------------------------------- */
%macro CHECK_DATASET(LIB=WORK, DSN=);
  %if %sysfunc(exist(&LIB..&DSN)) %then %do;
    %LOG_MESSAGE(LEVEL=INFO,  MSG=Dataset &LIB..&DSN found.);
  %end;
  %else %do;
    %LOG_MESSAGE(LEVEL=ERROR, MSG=Dataset &LIB..&DSN NOT FOUND. Process halted.);
    %abort cancel;
  %end;
%mend CHECK_DATASET;

/* ----------------------------------------------------------
   3.3  %ROW_COUNT – Macro that stores obs count in a variable
   ---------------------------------------------------------- */
%macro ROW_COUNT(LIB=WORK, DSN=, OUTVAR=_NOBS);
  %global &OUTVAR;
  %let dsid  = %sysfunc(open(&LIB..&DSN));
  %let &OUTVAR = %sysfunc(attrn(&dsid, nobs));
  %let rc    = %sysfunc(close(&dsid));
  %LOG_MESSAGE(LEVEL=INFO, MSG=&LIB..&DSN has %trim(&&&OUTVAR) observations.);
%mend ROW_COUNT;

/* ----------------------------------------------------------
   3.4  %TIMER – Simple start/stop timer
   ---------------------------------------------------------- */
%macro TIMER_START(LABEL=STEP);
  %global _TIMER_START_&LABEL;
  %let _TIMER_START_&LABEL = %sysfunc(datetime());
%mend TIMER_START;

%macro TIMER_STOP(LABEL=STEP);
  %local _elapsed;
  %let _elapsed = %sysevalf(%sysfunc(datetime()) - &&_TIMER_START_&LABEL);
  %LOG_MESSAGE(LEVEL=PERF, MSG=&LABEL elapsed &_elapsed seconds.);
%mend TIMER_STOP;

/* ----------------------------------------------------------
   3.5  %DROP_IF_EXISTS – Safe table drop
   ---------------------------------------------------------- */
%macro DROP_IF_EXISTS(LIB=WORK, DSN=);
  %if %sysfunc(exist(&LIB..&DSN)) %then %do;
    proc delete data=&LIB..&DSN; run;
    %LOG_MESSAGE(LEVEL=INFO, MSG=Dropped &LIB..&DSN.);
  %end;
%mend DROP_IF_EXISTS;

/* ----------------------------------------------------------
   3.6  %ASSERT_EQUAL – Regression test helper
   ---------------------------------------------------------- */
%macro ASSERT_EQUAL(ACTUAL=, EXPECTED=, TEST_NAME=Unnamed Test);
  %if &ACTUAL = &EXPECTED %then
    %LOG_MESSAGE(LEVEL=PASS, MSG=TEST PASSED: &TEST_NAME);
  %else
    %LOG_MESSAGE(LEVEL=FAIL, MSG=TEST FAILED: &TEST_NAME – Expected &EXPECTED got &ACTUAL);
%mend ASSERT_EQUAL;

/* ----------------------------------------------------------
   3.7  %RENAME_COLUMNS – Bulk rename via prefix/suffix
   ---------------------------------------------------------- */
%macro RENAME_COLUMNS(DSN=, OLD_PREFIX=, NEW_PREFIX=);
  %local varlist i varname newname;
  proc contents data=&DSN out=_tmp_cols(keep=name) noprint; run;
  proc sql noprint;
    select name into :varlist separated by ' '
    from   _tmp_cols
    where  upcase(name) like upcase("&OLD_PREFIX%");
  quit;
  %if %length(&varlist) = 0 %then %do;
    %LOG_MESSAGE(LEVEL=WARN, MSG=No columns found with prefix &OLD_PREFIX in &DSN);
    %return;
  %end;
  data &DSN;
    set &DSN;
    rename
    %let i=1;
    %do %while(%scan(&varlist,&i,' ') ne );
      %let varname = %scan(&varlist,&i,' ');
      %let newname = &NEW_PREFIX%substr(&varname,%length(&OLD_PREFIX)+1);
      &varname = &newname
      %let i = %eval(&i+1);
    %end;
    ;
  run;
%mend RENAME_COLUMNS;

/* ----------------------------------------------------------
   3.8  %FREQ_REPORT – One-way frequency with chart
   ---------------------------------------------------------- */
%macro FREQ_REPORT(DSN=, VAR=, TITLE=Frequency Report);
  title "&TITLE";
  proc freq data=&DSN order=freq;
    tables &VAR / nocum plots=freqplot(type=bar orient=horizontal);
  run;
  title;
%mend FREQ_REPORT;

/* ----------------------------------------------------------
   3.9  %MISSING_SUMMARY – Column-level missing summary
   ---------------------------------------------------------- */
%macro MISSING_SUMMARY(DSN=, OUTDSN=WORK.MISSING_SUMMARY);
  proc means data=&DSN nmiss n noprint;
    output out=&OUTDSN nmiss= n= / autoname;
  run;
  proc transpose data=&OUTDSN out=&OUTDSN name=VARIABLE_NAME; run;
  data &OUTDSN;
    set &OUTDSN;
    where index(upcase(_NAME_),'NMISS') > 0;
    VARIABLE_NAME = tranwrd(_NAME_,'_NMiss','');
    rename COL1 = MISSING_COUNT;
    drop _NAME_ _LABEL_;
  run;
  %LOG_MESSAGE(LEVEL=INFO, MSG=Missing summary written to &OUTDSN);
%mend MISSING_SUMMARY;

/* ----------------------------------------------------------
   3.10 %STANDARDISE – Z-score standardisation
   ---------------------------------------------------------- */
%macro STANDARDISE(DSN=, VARS=, OUTDSN=);
  %if &OUTDSN = %then %let OUTDSN = &DSN;
  proc stdize data=&DSN out=&OUTDSN method=std;
    var &VARS;
  run;
  %LOG_MESSAGE(LEVEL=INFO, MSG=Standardisation applied to &VARS in &OUTDSN);
%mend STANDARDISE;


/* ============================================================
   MODULE 04 – DATA INGESTION & LIBRARY ASSIGNMENT
   ============================================================ */

%TIMER_START(LABEL=INGESTION);
%LOG_MESSAGE(LEVEL=INFO, MSG=Starting data ingestion.);

/* Assign permanent libraries */
libname RAWDATA  "&RAW_PATH."  access=readonly;
libname STAGING  "&STAGE_PATH.";
libname OUTLIB   "&OUTPUT_PATH.";
libname LOGLIB   "&LOG_PATH.";

/* ---- 4.2  Simulate transaction data ---- */
data STAGING.TRANSACTIONS_RAW;
  length TXN_ID       $16
         CUSTOMER_ID  $12
         TXN_DATE     8
         TXN_AMOUNT   8
         TXN_TYPE     $20
         CHANNEL      $15
         MERCHANT_CAT $30
         CCY          $3
         STATUS       $10;
  format TXN_DATE date9.;

  array txntypes  [5] $20 _TEMPORARY_
        ('Purchase' 'Refund' 'Transfer' 'Withdrawal' 'Deposit');
  array channels  [4] $15 _TEMPORARY_
        ('Online' 'In-Store' 'ATM' 'Mobile');
  array merchants [8] $30 _TEMPORARY_
        ('Groceries' 'Electronics' 'Travel' 'Healthcare'
         'Dining'    'Utilities'   'Retail' 'Entertainment');
  array ccys      [3] $3  _TEMPORARY_ ('GBP' 'USD' 'EUR');
  array tstatus   [2] $10 _TEMPORARY_ ('Completed' 'Failed');

  call streaminit(&SEED + 1);
  do i = 1 to 50000;
    TXN_ID       = cats('TXN', put(i, z10.));
    CUSTOMER_ID  = cats('CUST', put(ceil(rand('uniform') * 5000), z8.));
    TXN_DATE     = '01JAN2025'D + floor(rand('uniform') * 365);
    TXN_AMOUNT   = round(abs(rand('normal') * 500 + 200), 0.01);
    TXN_TYPE     = txntypes [ceil(rand('uniform') * 5)];
    CHANNEL      = channels [ceil(rand('uniform') * 4)];
    MERCHANT_CAT = merchants[ceil(rand('uniform') * 8)];
    CCY          = ccys     [ceil(rand('uniform') * 3)];
    STATUS       = tstatus  [ceil(rand('uniform') * 2)];
    if mod(i,100) = 0 then TXN_AMOUNT = TXN_AMOUNT * 50; /* inject outliers */
    output;
  end;
  drop i;
run;
/* ---- 7.2  Clean transaction records ---- */
data STAGING.TRANSACTIONS_CLEAN;
  set STAGING.TRANSACTIONS_RAW;
  where STATUS = 'Completed';

  /* Winsorise extreme amounts at 99th percentile proxy */
  TXN_AMOUNT_WIN = min(TXN_AMOUNT, 15000);

  /* Identify refunds */
  IS_REFUND = (TXN_TYPE = 'Refund');

  /* Quarter of transaction */
  TXN_QTR = qtr(TXN_DATE);
  TXN_YEAR = year(TXN_DATE);

  /* Month label */
  TXN_MONTH = month(TXN_DATE);
  TXN_MONTH_NAME = put(TXN_DATE, monname3.);

  format IS_REFUND 1.;
run;

/* ---- 17.1  RFM Scoring (Recency, Frequency, Monetary) ----
   Bundle note: RECENCY below is measured from &PERIOD_END (this script's
   own reporting-period constant from module 02) instead of the source's
   "today() - max(TXN_DATE)". Jenner's PROC SQL currently type-errors on
   arithmetic between TODAY() and a DATE column (works fine as a
   comparison, just not arithmetic) -- filed as a regression test
   upstream. Everything else in this module, including the PROC RANK /
   PROC FREQ / PROC MEANS steps below, runs against Jenner unmodified. */
proc sql;
  create table STAGING.RFM_BASE as
  select
    CUSTOMER_ID,
    "&PERIOD_END"d - max(TXN_DATE) as RECENCY       label="Days Since Last Purchase",
    count(*)                     as FREQUENCY     label="Number of Purchases",
    sum(TXN_AMOUNT_WIN)          as MONETARY      label="Total Spend (£)" format=comma14.2
  from STAGING.TRANSACTIONS_CLEAN
  group by CUSTOMER_ID;
quit;

/* Assign quintile scores 1-5 for each RFM component */
proc rank data=STAGING.RFM_BASE out=STAGING.RFM_SCORED
          groups=5 descending;
  var RECENCY;
  ranks R_SCORE;
run;

proc rank data=STAGING.RFM_SCORED out=STAGING.RFM_SCORED
          groups=5;
  var FREQUENCY MONETARY;
  ranks F_SCORE M_SCORE;
run;

data STAGING.RFM_SCORED;
  set STAGING.RFM_SCORED;
  /* Invert recency: lower recency = higher score */
  R_SCORE = 5 - R_SCORE;
  RFM_TOTAL = R_SCORE + F_SCORE + M_SCORE;
  /* Segment */
  length RFM_SEGMENT $25;
  if RFM_TOTAL >= 12 then RFM_SEGMENT = 'Champions';
  else if RFM_TOTAL >= 9  then RFM_SEGMENT = 'Loyal Customers';
  else if RFM_TOTAL >= 6  then RFM_SEGMENT = 'Potential Loyalists';
  else if RFM_TOTAL >= 3  then RFM_SEGMENT = 'At-Risk';
  else                         RFM_SEGMENT = 'Lost Customers';
run;

proc freq data=STAGING.RFM_SCORED order=freq;
  tables RFM_SEGMENT / nocum plots=freqplot;
  title "RFM Segmentation Distribution";
run;

proc means data=STAGING.RFM_SCORED n mean median std maxdec=2;
  class RFM_SEGMENT;
  var RECENCY FREQUENCY MONETARY;
  title "RFM Segment Profile";
run;

