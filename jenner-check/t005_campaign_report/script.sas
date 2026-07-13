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

/* ---- 7.5  Campaign ROI enrichment ---- */
data STAGING.CAMPAIGNS_ENRICHED;
  set STAGING.CAMPAIGNS_RAW;
  /* Derived KPIs */
  BUDGET_UTILISATION = SPEND / BUDGET;
  CTR               = CLICKS / IMPRESSIONS;
  CVR               = CONVERSIONS / CLICKS;
  CPC               = SPEND / (CLICKS + 0.01);        /* avoid div-by-zero */
  CPL               = SPEND / (CONVERSIONS + 0.01);
  ROAS              = (CONVERSIONS * 100) / SPEND;     /* simplified ROAS */
  CAMPAIGN_DAYS     = END_DATE - START_DATE + 1;
  DAILY_BUDGET      = BUDGET / CAMPAIGN_DAYS;
  format BUDGET_UTILISATION CTR CVR percent8.2
         CPC CPL comma10.2;
run;
/* ---- 12.4  Campaign report ---- */
proc report data=STAGING.CAMPAIGNS_ENRICHED nowd;
  column CHANNEL CAMPAIGN_NAME BUDGET SPEND BUDGET_UTILISATION
         IMPRESSIONS CLICKS CTR CONVERSIONS CVR CPC CPL ROAS;
  define CHANNEL            / group   "Channel"        width=10;
  define CAMPAIGN_NAME      / display "Campaign"       width=25;
  define BUDGET             / sum     "Budget"         format=comma12.;
  define SPEND              / sum     "Spend"          format=comma12.;
  define BUDGET_UTILISATION / mean    "Budget Util%"   format=percent7.1;
  define IMPRESSIONS         / sum    "Impressions"    format=comma14.;
  define CLICKS             / sum     "Clicks"         format=comma10.;
  define CTR                / mean    "CTR"            format=percent7.2;
  define CONVERSIONS        / sum     "Conversions"    format=comma10.;
  define CVR                / mean    "CVR"            format=percent7.2;
  define CPC                / mean    "CPC (£)"        format=comma8.2;
  define CPL                / mean    "CPL (£)"        format=comma8.2;
  define ROAS               / mean    "ROAS"           format=8.2;
  title "Digital Campaign Performance Report";
run;

