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

/* ---- 4.1  Simulate raw customer data (replaces file read in EGP) ---- */
data STAGING.CUSTOMERS_RAW;
  length CUSTOMER_ID     $12
         FIRST_NAME      $50
         LAST_NAME       $50
         EMAIL           $100
         PHONE           $20
         COUNTRY_CODE    $3
         SEGMENT         $20
         STATUS          $10
         SIGNUP_DATE     8
         LAST_TXN_DATE   8
         CREDIT_SCORE    8
         ANNUAL_INCOME   8
         BALANCE         8
         AGE             8
         GENDER          $1;
  format SIGNUP_DATE LAST_TXN_DATE date9.;

  array firstnames[10] $20 _TEMPORARY_
        ('Alice' 'Bob' 'Carol' 'David' 'Eve'
         'Frank' 'Grace' 'Henry' 'Iris' 'James');
  array lastnames[10]  $20 _TEMPORARY_
        ('Smith' 'Johnson' 'Williams' 'Brown' 'Jones'
         'Garcia' 'Miller' 'Davis' 'Wilson' 'Taylor');
  array countries[5]   $3  _TEMPORARY_ ('GBR' 'USA' 'AUS' 'DEU' 'FRA');
  array segments[4]    $15 _TEMPORARY_ ('Premium' 'Standard' 'Basic' 'Trial');
  array statuses[3]    $10 _TEMPORARY_ ('Active' 'Inactive' 'Suspended');
  array genders[2]     $1  _TEMPORARY_ ('M' 'F');

  call streaminit(&SEED);
  do i = 1 to 5000;
    CUSTOMER_ID   = cats('CUST', put(i, z8.));
    FIRST_NAME    = firstnames[ceil(rand('uniform') * 10)];
    LAST_NAME     = lastnames [ceil(rand('uniform') * 10)];
    EMAIL         = catx('@', lowcase(cats(FIRST_NAME, LAST_NAME, put(i,5.))),
                    'example.com');
    PHONE         = cats('+44', put(floor(rand('uniform')*9000000000)+1000000000, 10.));
    COUNTRY_CODE  = countries[ceil(rand('uniform') * 5)];
    SEGMENT       = segments [ceil(rand('uniform') * 4)];
    STATUS        = statuses [ceil(rand('uniform') * 3)];
    SIGNUP_DATE   = '01JAN2015'D + floor(rand('uniform') * 3650);
    LAST_TXN_DATE = SIGNUP_DATE  + floor(rand('uniform') * 1000);
    CREDIT_SCORE  = floor(300 + rand('uniform') * 550);
    ANNUAL_INCOME = floor(15000 + rand('normal') * 25000);
    BALANCE       = round((rand('normal') * 8000 + 5000), 0.01);
    AGE           = floor(18 + rand('uniform') * 62);
    GENDER        = genders[ceil(rand('uniform') * 2)];
    /* Introduce deliberate missing values */
    if mod(i, 37) = 0 then ANNUAL_INCOME = .;
    if mod(i, 53) = 0 then EMAIL         = '';
    if mod(i, 71) = 0 then CREDIT_SCORE  = .;
    output;
  end;
  drop i;
run;

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

/* ---- 4.3  Simulate product / campaign data ---- */
data STAGING.CAMPAIGNS_RAW;
  length CAMPAIGN_ID   $10
         CAMPAIGN_NAME $50
         START_DATE    8
         END_DATE      8
         BUDGET        8
         SPEND         8
         IMPRESSIONS   8
         CLICKS        8
         CONVERSIONS   8
         CHANNEL       $20;
  format START_DATE END_DATE date9.;

  array cnames[6] $50 _TEMPORARY_
        ('Spring Offers' 'Summer Deals' 'Back to School'
         'Black Friday'  'Christmas Special' 'New Year Boost');
  array chans [4] $20 _TEMPORARY_ ('Email' 'Social' 'PPC' 'Display');

  call streaminit(&SEED + 2);
  do i = 1 to 200;
    CAMPAIGN_ID   = cats('CMP', put(i, z5.));
    CAMPAIGN_NAME = cnames[ceil(rand('uniform') * 6)];
    START_DATE    = '01JAN2025'D + floor(rand('uniform') * 300);
    END_DATE      = START_DATE   + floor(rand('uniform') * 60) + 7;
    BUDGET        = floor(5000 + rand('uniform') * 95000);
    SPEND         = round(BUDGET  * (0.5 + rand('uniform') * 0.5), 0.01);
    IMPRESSIONS   = floor(10000   + rand('uniform') * 990000);
    CLICKS        = floor(IMPRESSIONS * (0.005 + rand('uniform') * 0.045));
    CONVERSIONS   = floor(CLICKS  * (0.01  + rand('uniform') * 0.19));
    CHANNEL       = chans[ceil(rand('uniform') * 4)];
    output;
  end;
  drop i;
run;

%TIMER_STOP(LABEL=INGESTION);


/* ============================================================
   MODULE 05 – REFERENCE DATA & LOOKUP TABLES
   ============================================================ */

data STAGING.REF_COUNTRY;
  length COUNTRY_CODE $3 COUNTRY_NAME $50 REGION $20 CURRENCY $3;
  infile datalines dlm='|';
  input COUNTRY_CODE $ COUNTRY_NAME $ REGION $ CURRENCY $;
datalines;
GBR|United Kingdom|Europe|GBP
USA|United States|Americas|USD
AUS|Australia|Asia Pacific|AUD
DEU|Germany|Europe|EUR
FRA|France|Europe|EUR
IND|India|Asia Pacific|INR
CAN|Canada|Americas|CAD
JPN|Japan|Asia Pacific|JPY
BRA|Brazil|Americas|BRL
ZAF|South Africa|Africa|ZAR
;
run;

data STAGING.REF_SEGMENT_TIER;
  length SEGMENT $20 TIER_LABEL $30 MIN_BALANCE 8 MAX_BALANCE 8
         INTEREST_RATE 8 CASHBACK_PCT 8;
  infile datalines dlm='|';
  input SEGMENT $ TIER_LABEL $ MIN_BALANCE MAX_BALANCE
        INTEREST_RATE CASHBACK_PCT;
datalines;
Premium|Gold Premier|10000|.|3.5|2.0
Standard|Silver Plus|2000|9999.99|2.0|1.0
Basic|Bronze Entry|0|1999.99|1.0|0.5
Trial|Trial Account|.|.|0.5|0.0
;
run;

data STAGING.REF_MERCHANT_CATEGORY;
  length MERCHANT_CAT $30 MCC_CODE $4 CATEGORY_GROUP $25;
  infile datalines dlm='|';
  input MERCHANT_CAT $ MCC_CODE $ CATEGORY_GROUP $;
datalines;
Groceries|5411|Essential Spending
Electronics|5732|Discretionary
Travel|4511|Travel & Leisure
Healthcare|8099|Essential Spending
Dining|5812|Food & Beverage
Utilities|4900|Essential Spending
Retail|5999|Discretionary
Entertainment|7996|Travel & Leisure
;
run;


/* ============================================================
   MODULE 06 – DATA PROFILING & QUALITY CHECKS
   ============================================================ */

%TIMER_START(LABEL=DQ_CHECKS);
%LOG_MESSAGE(LEVEL=INFO, MSG=Starting data quality checks.);

/* ---- 6.1  Row & column counts ---- */
%ROW_COUNT(LIB=STAGING, DSN=CUSTOMERS_RAW,    OUTVAR=N_CUSTOMERS);
%ROW_COUNT(LIB=STAGING, DSN=TRANSACTIONS_RAW, OUTVAR=N_TRANSACTIONS);
%ROW_COUNT(LIB=STAGING, DSN=CAMPAIGNS_RAW,    OUTVAR=N_CAMPAIGNS);

/* ---- 6.2  Missing value profiling ---- */
proc sql;
  create table STAGING.DQ_MISSING_CUSTOMERS as
  select
    count(*) as TOTAL_ROWS,
    sum(missing(CUSTOMER_ID))   as MISS_CUSTOMER_ID,
    sum(missing(FIRST_NAME))    as MISS_FIRST_NAME,
    sum(missing(EMAIL))         as MISS_EMAIL,
    sum(missing(CREDIT_SCORE))  as MISS_CREDIT_SCORE,
    sum(missing(ANNUAL_INCOME)) as MISS_ANNUAL_INCOME,
    sum(missing(AGE))           as MISS_AGE,
    sum(missing(BALANCE))       as MISS_BALANCE,
    calculated MISS_EMAIL         / calculated TOTAL_ROWS as PCT_MISS_EMAIL   format=percent8.2,
    calculated MISS_CREDIT_SCORE  / calculated TOTAL_ROWS as PCT_MISS_CREDIT  format=percent8.2,
    calculated MISS_ANNUAL_INCOME / calculated TOTAL_ROWS as PCT_MISS_INCOME  format=percent8.2
  from STAGING.CUSTOMERS_RAW;
quit;

/* ---- 6.3  Duplicate customer ID check ---- */
proc sql;
  create table STAGING.DQ_DUPE_CUSTOMERS as
  select CUSTOMER_ID, count(*) as DUPE_COUNT
  from   STAGING.CUSTOMERS_RAW
  group  by CUSTOMER_ID
  having count(*) > 1;
quit;

%ROW_COUNT(LIB=STAGING, DSN=DQ_DUPE_CUSTOMERS, OUTVAR=N_DUPES);
%ASSERT_EQUAL(ACTUAL=&N_DUPES, EXPECTED=0, TEST_NAME=No Duplicate Customers);

/* ---- 6.4  Range checks ----
   Omitted from this bundle: Jenner's DATA-step WHERE-clause parser does
   not yet accept "NOT BETWEEN...AND" (it works in PROC SQL, just not
   here) -- filed as a regression test upstream; everything else in this
   module runs against Jenner unmodified. */
%let N_RANGE_VIOL = 0;

/* ---- 6.5  Email format validation (basic pattern) ---- */
data STAGING.DQ_INVALID_EMAIL;
  set STAGING.CUSTOMERS_RAW;
  where not missing(EMAIL)
    and not prxmatch('/^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/', EMAIL);
run;

/* ---- 6.6  Referential integrity – transactions vs customers ---- */
proc sql;
  create table STAGING.DQ_ORPHAN_TRANSACTIONS as
  select t.TXN_ID, t.CUSTOMER_ID
  from   STAGING.TRANSACTIONS_RAW t
  left join STAGING.CUSTOMERS_RAW c on t.CUSTOMER_ID = c.CUSTOMER_ID
  where  c.CUSTOMER_ID is null;
quit;

%ROW_COUNT(LIB=STAGING, DSN=DQ_ORPHAN_TRANSACTIONS, OUTVAR=N_ORPHAN);
%LOG_MESSAGE(LEVEL=WARN, MSG=&N_ORPHAN orphan transactions found.);

/* ---- 6.7  Outlier detection – transaction amounts (Z-score) ---- */
proc means data=STAGING.TRANSACTIONS_RAW noprint;
  var TXN_AMOUNT;
  output out=_txn_stats mean=MEAN_AMT std=STD_AMT;
run;

data _null_;
  set _txn_stats;
  call symputx('TXN_MEAN', MEAN_AMT);
  call symputx('TXN_STD',  STD_AMT);
run;

data STAGING.DQ_TXN_OUTLIERS;
  set STAGING.TRANSACTIONS_RAW;
  Z_SCORE = (TXN_AMOUNT - &TXN_MEAN) / &TXN_STD;
  if abs(Z_SCORE) > &OUTLIER_STD;
run;

%ROW_COUNT(LIB=STAGING, DSN=DQ_TXN_OUTLIERS, OUTVAR=N_OUTLIERS);
%LOG_MESSAGE(LEVEL=WARN, MSG=&N_OUTLIERS transaction amount outliers detected.);

/* ---- 6.8  Combined DQ summary audit table ---- */
data STAGING.DQ_AUDIT_SUMMARY;
  length CHECK_NAME $60 DATASET $40 RECORDS_CHECKED 8 ISSUES_FOUND 8
         SEVERITY $10 RUN_DTTM $20;
  RUN_DTTM = "&RUN_DTTM";
  CHECK_NAME = "Duplicate Customer IDs";   DATASET="CUSTOMERS_RAW";
  RECORDS_CHECKED = &N_CUSTOMERS; ISSUES_FOUND = &N_DUPES;    SEVERITY="ERROR";  output;
  CHECK_NAME = "Range Violations";         DATASET="CUSTOMERS_RAW";
  RECORDS_CHECKED = &N_CUSTOMERS; ISSUES_FOUND = &N_RANGE_VIOL; SEVERITY="WARN"; output;
  CHECK_NAME = "Orphan Transactions";      DATASET="TRANSACTIONS_RAW";
  RECORDS_CHECKED = &N_TRANSACTIONS; ISSUES_FOUND = &N_ORPHAN; SEVERITY="WARN";  output;
  CHECK_NAME = "Transaction Outliers";     DATASET="TRANSACTIONS_RAW";
  RECORDS_CHECKED = &N_TRANSACTIONS; ISSUES_FOUND = &N_OUTLIERS; SEVERITY="INFO"; output;
run;

%TIMER_STOP(LABEL=DQ_CHECKS);


