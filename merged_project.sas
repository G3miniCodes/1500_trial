/*=============================================================================
  PROJECT  : Enterprise Analytics Platform
  FILE     : EGP_Analytics_Project.sas
  PURPOSE  : Comprehensive SAS EGP-based analytical framework covering data
             ingestion, transformation, statistical modelling, reporting,
             and data quality validation.
  AUTHOR   : Analytics Centre of Excellence
  CREATED  : 2026-03-26
  VERSION  : 1.0.0

  MODULES
  -------
  01  Environment Setup & Global Options
  02  Global Macro Variables
  03  Utility Macros
  04  Data Ingestion & Library Assignment
  05  Reference Data & Lookup Tables
  06  Data Profiling & Quality Checks
  07  Data Transformation & Feature Engineering
  08  Statistical Analysis (Descriptive)
  09  Statistical Analysis (Inferential)
  10  Predictive Modelling (Regression & Logistic)
  11  Customer Segmentation (Clustering)
  12  Reporting – PROC REPORT
  13  Reporting – PROC TABULATE
  14  Reporting – ODS Output
  15  ETL Pipeline Orchestration
  16  Audit & Logging Framework
  17  Cleanup & Session Closure
=============================================================================*/


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
%let BASE_PATH       = /data/analytics;
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

/* ---- 6.4  Range checks ---- */
data STAGING.DQ_RANGE_VIOLATIONS;
  set STAGING.CUSTOMERS_RAW;
  where  AGE           not between 18 and 120
      or CREDIT_SCORE  not between 300 and 850
      or ANNUAL_INCOME < 0;
run;

%ROW_COUNT(LIB=STAGING, DSN=DQ_RANGE_VIOLATIONS, OUTVAR=N_RANGE_VIOL);
%LOG_MESSAGE(LEVEL=WARN, MSG=&N_RANGE_VIOL range violations found.);

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


/* ============================================================
   MODULE 07 – DATA TRANSFORMATION & FEATURE ENGINEERING
   ============================================================ */

%TIMER_START(LABEL=TRANSFORM);
%LOG_MESSAGE(LEVEL=INFO, MSG=Starting data transformation.);

/* ---- 7.1  Clean customer records ---- */
data STAGING.CUSTOMERS_CLEAN;
  set STAGING.CUSTOMERS_RAW;

  /* Standardise case */
  FIRST_NAME   = propcase(strip(FIRST_NAME));
  LAST_NAME    = propcase(strip(LAST_NAME));
  FULL_NAME    = catx(' ', FIRST_NAME, LAST_NAME);
  EMAIL        = lowcase(strip(EMAIL));

  /* Age banding */
  length AGE_BAND $15;
  select;
    when (AGE < 25)                 AGE_BAND = '18-24';
    when (AGE >= 25 and AGE < 35)  AGE_BAND = '25-34';
    when (AGE >= 35 and AGE < 45)  AGE_BAND = '35-44';
    when (AGE >= 45 and AGE < 55)  AGE_BAND = '45-54';
    when (AGE >= 55 and AGE < 65)  AGE_BAND = '55-64';
    when (AGE >= 65)                AGE_BAND = '65+';
    otherwise                       AGE_BAND = 'Unknown';
  end;

  /* Credit score band */
  length CREDIT_BAND $15;
  select;
    when (CREDIT_SCORE < 580)                           CREDIT_BAND = 'Poor';
    when (CREDIT_SCORE >= 580 and CREDIT_SCORE < 670)  CREDIT_BAND = 'Fair';
    when (CREDIT_SCORE >= 670 and CREDIT_SCORE < 740)  CREDIT_BAND = 'Good';
    when (CREDIT_SCORE >= 740 and CREDIT_SCORE < 800)  CREDIT_BAND = 'Very Good';
    when (CREDIT_SCORE >= 800)                          CREDIT_BAND = 'Exceptional';
    otherwise                                           CREDIT_BAND = 'Unknown';
  end;

  /* Income band */
  length INCOME_BAND $20;
  if missing(ANNUAL_INCOME) then INCOME_BAND = 'Unknown';
  else if ANNUAL_INCOME <  20000 then INCOME_BAND = 'Low';
  else if ANNUAL_INCOME <  50000 then INCOME_BAND = 'Middle';
  else if ANNUAL_INCOME < 100000 then INCOME_BAND = 'Upper Middle';
  else                                INCOME_BAND = 'High';

  /* Tenure in years */
  TENURE_YEARS = round((today() - SIGNUP_DATE) / 365.25, 0.1);

  /* Days since last transaction */
  DAYS_SINCE_TXN = today() - LAST_TXN_DATE;

  /* Churn flag: inactive > 180 days */
  CHURN_FLAG = (STATUS = 'Inactive' and DAYS_SINCE_TXN > 180);

  /* Balance band */
  length BALANCE_BAND $15;
  if BALANCE <  0          then BALANCE_BAND = 'Negative';
  else if BALANCE <  1000  then BALANCE_BAND = '0-999';
  else if BALANCE <  5000  then BALANCE_BAND = '1K-4.9K';
  else if BALANCE < 10000  then BALANCE_BAND = '5K-9.9K';
  else                          BALANCE_BAND = '10K+';

  /* Impute missing values */
  if missing(ANNUAL_INCOME) then ANNUAL_INCOME = 35000;  /* median imputation */
  if missing(CREDIT_SCORE)  then CREDIT_SCORE  = 650;

  /* Flag imputed records */
  IMPUTED_FLAG = (mod(_n_, 37)=0 or mod(_n_, 71)=0);

  format CHURN_FLAG IMPUTED_FLAG 1.;
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

/* ---- 7.3  Customer transaction aggregates ---- */
proc sql;
  create table STAGING.CUST_TXN_AGG as
  select
    CUSTOMER_ID,
    count(*)                                        as TXN_COUNT         label="Total Transactions",
    sum(TXN_AMOUNT_WIN)                             as TOTAL_SPEND        label="Total Spend (Winsorised)" format=comma14.2,
    mean(TXN_AMOUNT_WIN)                            as AVG_TXN_AMOUNT     label="Avg Transaction Amount"  format=comma10.2,
    std(TXN_AMOUNT_WIN)                             as STD_TXN_AMOUNT     label="Std Dev Txn Amount"       format=comma10.2,
    max(TXN_AMOUNT_WIN)                             as MAX_TXN_AMOUNT     label="Max Transaction Amount"   format=comma10.2,
    min(TXN_DATE)                                   as FIRST_TXN_DATE     label="First Transaction Date"   format=date9.,
    max(TXN_DATE)                                   as LAST_TXN_DATE_AGG  label="Last Transaction Date"    format=date9.,
    max(TXN_DATE) - min(TXN_DATE)                  as TXN_TENURE_DAYS    label="Txn Tenure (Days)",
    sum(IS_REFUND)                                  as REFUND_COUNT       label="Refund Count",
    sum(IS_REFUND) / count(*)                       as REFUND_RATE        label="Refund Rate"              format=percent8.2,
    count(distinct CHANNEL)                         as CHANNEL_DIVERSITY  label="# Channels Used",
    count(distinct MERCHANT_CAT)                    as MERCHANT_DIVERSITY label="# Merchant Categories"
  from STAGING.TRANSACTIONS_CLEAN
  group by CUSTOMER_ID;
quit;

/* ---- 7.4  Master customer base – join enriched data ---- */
proc sql;
  create table STAGING.MASTER_CUSTOMER as
  select
    c.*,
    coalesce(t.TXN_COUNT,        0)    as TXN_COUNT,
    coalesce(t.TOTAL_SPEND,      0)    as TOTAL_SPEND       format=comma14.2,
    coalesce(t.AVG_TXN_AMOUNT,   0)    as AVG_TXN_AMOUNT    format=comma10.2,
    coalesce(t.STD_TXN_AMOUNT,   0)    as STD_TXN_AMOUNT    format=comma10.2,
    coalesce(t.MAX_TXN_AMOUNT,   0)    as MAX_TXN_AMOUNT    format=comma10.2,
    t.FIRST_TXN_DATE,
    t.LAST_TXN_DATE_AGG,
    coalesce(t.TXN_TENURE_DAYS,  0)    as TXN_TENURE_DAYS,
    coalesce(t.REFUND_COUNT,     0)    as REFUND_COUNT,
    coalesce(t.REFUND_RATE,      0)    as REFUND_RATE       format=percent8.2,
    coalesce(t.CHANNEL_DIVERSITY, 0)   as CHANNEL_DIVERSITY,
    coalesce(t.MERCHANT_DIVERSITY,0)   as MERCHANT_DIVERSITY,
    r.COUNTRY_NAME,
    r.REGION,
    r.CURRENCY,
    s.TIER_LABEL,
    s.INTEREST_RATE,
    s.CASHBACK_PCT
  from STAGING.CUSTOMERS_CLEAN c
  left join STAGING.CUST_TXN_AGG     t on c.CUSTOMER_ID = t.CUSTOMER_ID
  left join STAGING.REF_COUNTRY      r on c.COUNTRY_CODE = r.COUNTRY_CODE
  left join STAGING.REF_SEGMENT_TIER s on c.SEGMENT = s.SEGMENT;
quit;

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

%TIMER_STOP(LABEL=TRANSFORM);


/* ============================================================
   MODULE 08 – STATISTICAL ANALYSIS (DESCRIPTIVE)
   ============================================================ */

%TIMER_START(LABEL=DESCRIPTIVE);
%LOG_MESSAGE(LEVEL=INFO, MSG=Starting descriptive statistics.);

/* ---- 8.1  Overall customer descriptive stats ---- */
proc means data=STAGING.MASTER_CUSTOMER
           n nmiss mean std min p25 median p75 max skewness kurtosis
           maxdec=2;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE TENURE_YEARS
      TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT;
  title "Descriptive Statistics – Master Customer Base";
run;

/* ---- 8.2  Segment-level summary ---- */
proc means data=STAGING.MASTER_CUSTOMER
           n mean std median p75 max
           maxdec=2;
  class SEGMENT;
  var   ANNUAL_INCOME BALANCE CREDIT_SCORE TXN_COUNT TOTAL_SPEND;
  title "Descriptive Statistics by Segment";
run;

/* ---- 8.3  Region & country cross-tab ---- */
proc tabulate data=STAGING.MASTER_CUSTOMER format=comma14.2;
  class REGION COUNTRY_NAME SEGMENT;
  var   ANNUAL_INCOME BALANCE TOTAL_SPEND TXN_COUNT;
  table REGION * COUNTRY_NAME,
        SEGMENT * (ANNUAL_INCOME BALANCE TOTAL_SPEND TXN_COUNT) * (N MEAN SUM);
  title "Regional and Segment Summary";
run;

/* ---- 8.4  Frequency distributions ---- */
proc freq data=STAGING.MASTER_CUSTOMER;
  tables SEGMENT * STATUS / chisq expected cellchi2 norow nocol;
  tables AGE_BAND * CREDIT_BAND / chisq;
  tables REGION / nocum plots=freqplot;
  tables GENDER * SEGMENT / nocum;
  title "Frequency Analysis – Customer Dimensions";
run;

/* ---- 8.5  Univariate analysis ---- */
proc univariate data=STAGING.MASTER_CUSTOMER normal;
  var ANNUAL_INCOME BALANCE CREDIT_SCORE TXN_COUNT;
  histogram / normal kernel;
  qqplot / normal(mu=est sigma=est);
  inset n mean std skewness kurtosis / position=ne;
  title "Univariate Analysis – Key Numeric Variables";
run;

/* ---- 8.6  Correlation matrix ---- */
proc corr data=STAGING.MASTER_CUSTOMER
          pearson spearman
          plots=matrix(histogram nvar=all);
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE TENURE_YEARS
      TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT;
  title "Correlation Matrix – Numeric Customer Features";
run;

/* ---- 8.7  Distribution by channel (transactions) ---- */
proc means data=STAGING.TRANSACTIONS_CLEAN
           n mean std median min max
           maxdec=2;
  class CHANNEL MERCHANT_CAT;
  var   TXN_AMOUNT_WIN;
  title "Transaction Amount Distribution by Channel & Merchant";
run;

/* ---- 8.8  Monthly trend ---- */
proc means data=STAGING.TRANSACTIONS_CLEAN
           n sum mean maxdec=2;
  class TXN_YEAR TXN_MONTH;
  var TXN_AMOUNT_WIN;
  output out=STAGING.MONTHLY_TXN_TREND
         n=TXN_COUNT sum=TOTAL_VOLUME mean=AVG_AMOUNT;
  title "Monthly Transaction Trend";
run;

%TIMER_STOP(LABEL=DESCRIPTIVE);


/* ============================================================
   MODULE 09 – STATISTICAL ANALYSIS (INFERENTIAL)
   ============================================================ */

%TIMER_START(LABEL=INFERENTIAL);
%LOG_MESSAGE(LEVEL=INFO, MSG=Starting inferential statistics.);

/* ---- 9.1  Two-sample t-test: income by gender ---- */
proc ttest data=STAGING.MASTER_CUSTOMER alpha=&ALPHA;
  class GENDER;
  var   ANNUAL_INCOME BALANCE CREDIT_SCORE;
  title "Two-Sample T-Test: Differences by Gender";
run;

/* ---- 9.2  One-way ANOVA: credit score by segment ---- */
proc glm data=STAGING.MASTER_CUSTOMER;
  class  SEGMENT;
  model  CREDIT_SCORE = SEGMENT;
  means  SEGMENT / tukey hovtest;
  lsmeans SEGMENT / pdiff adjust=tukey;
  title "One-Way ANOVA: Credit Score by Customer Segment";
run;
quit;

/* ---- 9.3  Two-way ANOVA: total spend by region & segment ---- */
proc glm data=STAGING.MASTER_CUSTOMER;
  class  REGION SEGMENT;
  model  TOTAL_SPEND = REGION SEGMENT REGION*SEGMENT;
  lsmeans REGION*SEGMENT / pdiff;
  title "Two-Way ANOVA: Total Spend by Region and Segment";
run;
quit;

/* ---- 9.4  Chi-square test: churn by segment ---- */
proc freq data=STAGING.MASTER_CUSTOMER;
  tables SEGMENT * CHURN_FLAG / chisq relrisk;
  title "Chi-Square Test: Churn by Segment";
run;

/* ---- 9.5  Non-parametric – Wilcoxon rank-sum ---- */
proc npar1way data=STAGING.MASTER_CUSTOMER wilcoxon;
  class  CHURN_FLAG;
  var    TOTAL_SPEND TXN_COUNT;
  title "Wilcoxon Rank-Sum: Churned vs Retained Customers";
run;

/* ---- 9.6  Pearson & Spearman correlation tests ---- */
proc corr data=STAGING.MASTER_CUSTOMER pearson spearman;
  var  CREDIT_SCORE ANNUAL_INCOME BALANCE TOTAL_SPEND;
  with AGE TENURE_YEARS;
  title "Bivariate Correlation: Predictors vs Outcomes";
run;

%TIMER_STOP(LABEL=INFERENTIAL);


/* ============================================================
   MODULE 10 – PREDICTIVE MODELLING
   ============================================================ */

%TIMER_START(LABEL=MODELLING);
%LOG_MESSAGE(LEVEL=INFO, MSG=Starting predictive modelling.);

/* ---- 10.1  Train / test split ---- */
proc surveyselect data  = STAGING.MASTER_CUSTOMER
                  out   = STAGING.MODEL_SAMPLE
                  seed  = &SEED
                  samprate = &TRAIN_RATIO
                  method   = srs
                  outall;
run;

data STAGING.TRAIN_DATA STAGING.TEST_DATA;
  set STAGING.MODEL_SAMPLE;
  if Selected = 1 then output STAGING.TRAIN_DATA;
  else                  output STAGING.TEST_DATA;
run;

%ROW_COUNT(LIB=STAGING, DSN=TRAIN_DATA, OUTVAR=N_TRAIN);
%ROW_COUNT(LIB=STAGING, DSN=TEST_DATA,  OUTVAR=N_TEST);
%LOG_MESSAGE(LEVEL=INFO, MSG=Train: &N_TRAIN  Test: &N_TEST);

/* ---- 10.2  Linear regression: predict total spend ---- */
proc reg data=STAGING.TRAIN_DATA outest=STAGING.REG_ESTIMATES plots=all;
  model TOTAL_SPEND = AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
                      TENURE_YEARS TXN_COUNT AVG_TXN_AMOUNT
                      / selection=stepwise slentry=0.05 slstay=0.10
                        vif tol r;
  output out=STAGING.REG_PREDICTED predicted=PRED_SPEND residual=RESID_SPEND;
  title "Stepwise Linear Regression: Predicting Total Spend";
run;
quit;

/* ---- 10.3  Score test set ---- */
proc score data   = STAGING.TEST_DATA
           score  = STAGING.REG_ESTIMATES
           out    = STAGING.TEST_SCORED
           type   = parms;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
      TENURE_YEARS TXN_COUNT AVG_TXN_AMOUNT;
run;

/* ---- 10.4  Logistic regression: predict churn ---- */
proc logistic data    = STAGING.TRAIN_DATA
              outmodel= STAGING.LOGIT_MODEL
              plots(only)=(roc(id=prob) effect);
  class SEGMENT(ref='Basic') GENDER(ref='M') REGION(ref='Americas') / param=ref;
  model CHURN_FLAG(event='1') =
        AGE CREDIT_SCORE ANNUAL_INCOME BALANCE TENURE_YEARS
        TXN_COUNT AVG_TXN_AMOUNT REFUND_RATE CHANNEL_DIVERSITY
        SEGMENT GENDER REGION
        / selection=backward slstay=0.10
          rsquare lackfit outroc=STAGING.LOGIT_ROC
          ctable cutpoint=0.5;
  score data=STAGING.TRAIN_DATA out=STAGING.LOGIT_TRAIN_SCORES;
  title "Logistic Regression: Churn Prediction Model";
run;

/* ---- 10.5  Score test set for churn ---- */
proc logistic inmodel=STAGING.LOGIT_MODEL;
  score data=STAGING.TEST_DATA
        out =STAGING.LOGIT_TEST_SCORES;
run;

/* ---- 10.6  Model performance: confusion matrix ---- */
proc freq data=STAGING.LOGIT_TEST_SCORES;
  tables F_CHURN_FLAG * I_CHURN_FLAG / nocum nopercent;
  title "Churn Model Confusion Matrix (Test Set)";
run;

/* ---- 10.7  ROC curve ---- */
proc logistic data=STAGING.LOGIT_TEST_SCORES plots(only)=roc;
  model CHURN_FLAG(event='1') = P_1;
  roc 'Churn Model' P_1;
  title "ROC Curve – Churn Prediction Model";
run;

/* ---- 10.8  PROC HPFOREST – Random Forest (if licensed) ---- */
/*
proc hpforest data=STAGING.TRAIN_DATA seed=&SEED
              maxtrees=200 vars_to_try=5
              maxdepth=10 leafsize=5;
  target   CHURN_FLAG /  level=binary;
  input    AGE CREDIT_SCORE ANNUAL_INCOME BALANCE TENURE_YEARS
           TXN_COUNT AVG_TXN_AMOUNT REFUND_RATE CHANNEL_DIVERSITY
           / level=interval;
  input    SEGMENT GENDER REGION / level=nominal;
  score    out=STAGING.RF_SCORED;
  title "Random Forest: Churn Prediction";
run;
*/

%TIMER_STOP(LABEL=MODELLING);


/* ============================================================
   MODULE 11 – CUSTOMER SEGMENTATION (CLUSTERING)
   ============================================================ */

%TIMER_START(LABEL=CLUSTERING);
%LOG_MESSAGE(LEVEL=INFO, MSG=Starting customer segmentation via clustering.);

/* ---- 11.1  Prepare clustering input (standardise) ---- */
data STAGING.CLUSTER_INPUT;
  set STAGING.MASTER_CUSTOMER;
  keep CUSTOMER_ID AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
       TENURE_YEARS TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT
       REFUND_RATE CHANNEL_DIVERSITY;
run;

proc stdize data=STAGING.CLUSTER_INPUT
            out =STAGING.CLUSTER_STD
            method=range;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
      TENURE_YEARS TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT
      REFUND_RATE CHANNEL_DIVERSITY;
run;

/* ---- 11.2  Determine optimal k using CCC ---- */
proc fastclus data=STAGING.CLUSTER_STD
              maxclusters=10
              maxiter=100
              out=_dummy_ccc
              noprint
              summary;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
      TENURE_YEARS TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT;
run;

/* ---- 11.3  K-Means clustering (k=4) ---- */
proc fastclus data   = STAGING.CLUSTER_STD
              maxclus = 4
              maxiter = 200
              seed    = &SEED
              out     = STAGING.CLUSTER_OUT
              outstat = STAGING.CLUSTER_STATS;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
      TENURE_YEARS TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT
      REFUND_RATE CHANNEL_DIVERSITY;
  title "K-Means Clustering (k=4)";
run;

/* ---- 11.4  Merge cluster assignment back to master ---- */
proc sort data=STAGING.CLUSTER_OUT;     by CUSTOMER_ID; run;
proc sort data=STAGING.MASTER_CUSTOMER; by CUSTOMER_ID; run;

data STAGING.MASTER_CUSTOMER_CLUSTERED;
  merge STAGING.MASTER_CUSTOMER (in=a)
        STAGING.CLUSTER_OUT     (keep=CUSTOMER_ID CLUSTER in=b);
  by CUSTOMER_ID;
  if a;
  /* descriptive cluster label */
  length CLUSTER_LABEL $30;
  select (CLUSTER);
    when (1) CLUSTER_LABEL = 'High-Value Loyalists';
    when (2) CLUSTER_LABEL = 'Active Mid-Tier';
    when (3) CLUSTER_LABEL = 'At-Risk Inactives';
    when (4) CLUSTER_LABEL = 'New Explorers';
    otherwise CLUSTER_LABEL = 'Unassigned';
  end;
run;

/* ---- 11.5  Cluster profile summary ---- */
proc means data=STAGING.MASTER_CUSTOMER_CLUSTERED
           n mean std median maxdec=2;
  class CLUSTER_LABEL;
  var   AGE CREDIT_SCORE ANNUAL_INCOME BALANCE TENURE_YEARS
        TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT;
  title "Customer Cluster Profiles";
run;

%TIMER_STOP(LABEL=CLUSTERING);


/* ============================================================
   MODULE 12 – REPORTING: PROC REPORT
   ============================================================ */

%TIMER_START(LABEL=REPORTING);
%LOG_MESSAGE(LEVEL=INFO, MSG=Generating PROC REPORT output.);

/* ---- 12.1  Executive summary by segment ---- */
proc report data=STAGING.MASTER_CUSTOMER_CLUSTERED
            nowd
            style(report)=[rules=all frame=box cellpadding=4];
  column SEGMENT
         N_CUST
         TOTAL_BALANCE
         AVG_BALANCE
         AVG_INCOME
         AVG_CREDIT
         PCT_CHURN
         TOTAL_SPEND_AGG
         AVG_SPEND;
  define SEGMENT        / group "Customer Segment"  style(header)=[just=left];
  define N_CUST         / computed "# Customers"     format=comma8.;
  define TOTAL_BALANCE  / sum "Total Balance"        format=comma14.2;
  define AVG_BALANCE    / mean "Avg Balance"         format=comma10.2;
  define AVG_INCOME     / analysis mean var=ANNUAL_INCOME  "Avg Annual Income" format=comma10.2;
  define AVG_CREDIT     / analysis mean var=CREDIT_SCORE   "Avg Credit Score"  format=8.1;
  define PCT_CHURN      / computed "Churn Rate"      format=percent8.1;
  define TOTAL_SPEND_AGG / sum   "Total Spend"       format=comma14.2;
  define AVG_SPEND      / mean "Avg Spend"           format=comma10.2;

  compute N_CUST;
    N_CUST = _FREQ_;
  endcomp;

  compute PCT_CHURN;
    PCT_CHURN = CHURN_FLAG.mean;
  endcomp;

  compute after;
    line "Report Generated: &RUN_DATE";
  endcomp;

  title1 "Executive Summary – Customer Segment Performance";
  title2 "Reporting Period: &PERIOD_START to &PERIOD_END";
run;

/* ---- 12.2  Cluster performance report ---- */
proc report data=STAGING.MASTER_CUSTOMER_CLUSTERED nowd;
  column CLUSTER_LABEL COUNTRY_NAME
         N_CUST TOTAL_SPEND_SUM AVG_SPEND CHURN_RATE;
  define CLUSTER_LABEL  / group "Cluster"       width=25;
  define COUNTRY_NAME   / group "Country"       width=20;
  define N_CUST         / n    "#"              format=comma6.;
  define TOTAL_SPEND_SUM / sum "Total Spend"    format=comma14.2 var=TOTAL_SPEND;
  define AVG_SPEND      / mean "Avg Spend"      format=comma10.2 var=TOTAL_SPEND;
  define CHURN_RATE     / mean "Churn Rate"     format=percent6.1 var=CHURN_FLAG;
  title "Cluster Performance by Country";
run;

/* ---- 12.3  Transaction trend report ---- */
proc report data=STAGING.MONTHLY_TXN_TREND nowd;
  column TXN_YEAR TXN_MONTH TXN_COUNT TOTAL_VOLUME AVG_AMOUNT;
  define TXN_YEAR    / group  "Year"          format=4.;
  define TXN_MONTH   / group  "Month"         format=monname3.;
  define TXN_COUNT   / sum    "# Transactions" format=comma10.;
  define TOTAL_VOLUME / sum   "Total Volume"   format=comma14.2;
  define AVG_AMOUNT  / mean   "Avg Amount"     format=comma10.2;
  title "Monthly Transaction Summary";
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


/* ============================================================
   MODULE 13 – REPORTING: PROC TABULATE
   ============================================================ */

/* ---- 13.1  Customer metrics matrix ---- */
proc tabulate data=STAGING.MASTER_CUSTOMER_CLUSTERED format=comma12.2;
  class  REGION SEGMENT AGE_BAND CREDIT_BAND;
  var    ANNUAL_INCOME BALANCE CREDIT_SCORE TOTAL_SPEND TXN_COUNT;
  table  REGION,
         (ANNUAL_INCOME BALANCE TOTAL_SPEND) *
         (N MEAN MEDIAN STD SUM)
         / box="Region Overview";
  table  SEGMENT * AGE_BAND,
         (CREDIT_SCORE TOTAL_SPEND TXN_COUNT) *
         (N MEAN MEDIAN)
         / box="Segment × Age Band";
  title "Multidimensional Customer Metric Table";
run;

/* ---- 13.2  Churn metric table ---- */
proc tabulate data=STAGING.MASTER_CUSTOMER_CLUSTERED format=percent9.1;
  class  CLUSTER_LABEL COUNTRY_NAME CHURN_FLAG;
  var    TOTAL_SPEND;
  table  CLUSTER_LABEL * COUNTRY_NAME,
         CHURN_FLAG * (N COLPCTN) TOTAL_SPEND * MEAN
         / box="Churn by Cluster & Country";
  title "Churn Analysis by Cluster and Country";
run;

/* ---- 13.3  Transaction channel matrix ---- */
proc tabulate data=STAGING.TRANSACTIONS_CLEAN format=comma12.2;
  class  TXN_YEAR TXN_MONTH CHANNEL MERCHANT_CAT;
  var    TXN_AMOUNT_WIN;
  table  TXN_YEAR * TXN_MONTH,
         CHANNEL * TXN_AMOUNT_WIN * (N SUM MEAN)
         / box="Monthly Channel Summary";
  title "Transaction Volume & Value by Channel and Month";
run;


/* ============================================================
   MODULE 14 – REPORTING: ODS OUTPUT
   ============================================================ */

/* ---- 14.1  ODS PDF report ---- */
ods pdf file="&REPORT_PATH./EGP_Analytics_Report_&RUN_DATE..pdf"
        style=journal notoc
        startpage=never;
  ods proclabel "Segment Summary";
  proc means data=STAGING.MASTER_CUSTOMER_CLUSTERED
             n mean std median max maxdec=2;
    class SEGMENT;
    var   ANNUAL_INCOME BALANCE CREDIT_SCORE TXN_COUNT TOTAL_SPEND;
    title "Segment Summary Statistics";
  run;

  ods proclabel "Monthly Trend";
  proc sgplot data=STAGING.MONTHLY_TXN_TREND;
    series x=TXN_MONTH y=TOTAL_VOLUME / group=TXN_YEAR markers;
    xaxis label="Month" valuesformat=monname3.;
    yaxis label="Total Transaction Volume (£)" grid;
    title "Monthly Transaction Volume Trend";
    keylegend / location=inside position=topleft;
  run;

  ods proclabel "Cluster Scatter";
  proc sgplot data=STAGING.MASTER_CUSTOMER_CLUSTERED;
    scatter x=TOTAL_SPEND y=CREDIT_SCORE / group=CLUSTER_LABEL
            markerattrs=(size=4);
    xaxis label="Total Spend (£)" grid;
    yaxis label="Credit Score"    grid;
    title "Customer Clusters: Spend vs Credit Score";
  run;
ods pdf close;

/* ---- 14.2  ODS Excel report ---- */
ods excel file="&REPORT_PATH./EGP_Analytics_Report_&RUN_DATE..xlsx"
          options(sheet_interval='proc'
                  embedded_titles='yes'
                  autofilter='yes'
                  frozen_headers='yes');
  proc print data=STAGING.MASTER_CUSTOMER_CLUSTERED
             (obs=1000)
             noobs label;
    var CUSTOMER_ID FULL_NAME SEGMENT STATUS COUNTRY_NAME REGION
        AGE_BAND CREDIT_BAND INCOME_BAND CLUSTER_LABEL
        BALANCE ANNUAL_INCOME CREDIT_SCORE TOTAL_SPEND TXN_COUNT
        CHURN_FLAG TENURE_YEARS;
    title "Customer Master Extract (Top 1000)";
  run;

  proc report data=STAGING.CAMPAIGNS_ENRICHED nowd;
    column CHANNEL CAMPAIGN_NAME BUDGET SPEND IMPRESSIONS CLICKS
           CONVERSIONS ROAS;
    define CHANNEL       / group;
    define CAMPAIGN_NAME / display;
    define BUDGET        / sum format=comma12.;
    define SPEND         / sum format=comma12.;
    define IMPRESSIONS    / sum format=comma14.;
    define CLICKS        / sum format=comma10.;
    define CONVERSIONS   / sum format=comma10.;
    define ROAS          / mean format=8.2;
    title "Campaign Performance";
  run;
ods excel close;

/* ---- 14.3  ODS HTML5 dashboard ---- */
ods html5 file="&REPORT_PATH./EGP_Dashboard_&RUN_DATE..html"
          style=HTMLBlue;
  ods graphics on / width=800px height=500px;

  proc sgplot data=STAGING.MASTER_CUSTOMER_CLUSTERED;
    vbar CLUSTER_LABEL / response=TOTAL_SPEND stat=sum
                         fillattrs=(transparency=0.2)
                         datalabel;
    xaxis label="Customer Cluster";
    yaxis label="Total Spend (£)" grid format=comma14.;
    title "Total Spend by Customer Cluster";
  run;

  proc sgplot data=STAGING.MASTER_CUSTOMER_CLUSTERED;
    histogram CREDIT_SCORE / scale=count fillattrs=(color=steelblue);
    density   CREDIT_SCORE / type=normal lineattrs=(color=red thickness=2);
    density   CREDIT_SCORE / type=kernel lineattrs=(color=green thickness=2);
    xaxis label="Credit Score";
    yaxis label="Frequency";
    title "Credit Score Distribution with Normal & Kernel Density";
  run;

  proc sgplot data=STAGING.MONTHLY_TXN_TREND;
    vbar  TXN_MONTH / response=TXN_COUNT group=TXN_YEAR
                      groupdisplay=cluster barwidth=0.7;
    series x=TXN_MONTH y=TOTAL_VOLUME / y2axis markers
                                        lineattrs=(color=red pattern=dash);
    xaxis label="Month" valuesformat=monname3.;
    yaxis  label="Transaction Count" grid;
    y2axis label="Total Volume (£)" grid;
    title "Monthly Transaction Count and Volume";
  run;

  proc sgpanel data=STAGING.MASTER_CUSTOMER_CLUSTERED;
    panelby SEGMENT / layout=lattice rows=2 columns=2;
    histogram TOTAL_SPEND / scale=percent;
    colaxis grid;
    title "Total Spend Distribution by Segment";
  run;

  ods graphics off;
ods html5 close;

%TIMER_STOP(LABEL=REPORTING);


/* ============================================================
   MODULE 15 – ETL PIPELINE ORCHESTRATION
   ============================================================ */

%TIMER_START(LABEL=ETL);
%LOG_MESSAGE(LEVEL=INFO, MSG=Running ETL pipeline.);

/* ---- 15.1  Macro-driven incremental load ---- */
%macro INCREMENTAL_LOAD(SRC_LIB=, SRC_DSN=,
                        TGT_LIB=, TGT_DSN=,
                        DATE_COL=,
                        CUTOFF_DATE=);
  %local _min_dt _max_dt;
  %TIMER_START(LABEL=INCR_&TGT_DSN);
  %LOG_MESSAGE(LEVEL=INFO,
    MSG=Incremental load from &SRC_LIB..&SRC_DSN into &TGT_LIB..&TGT_DSN.);

  /* Extract only new records */
  proc sql;
    create table WORK._INCR_EXTRACT as
    select * from &SRC_LIB..&SRC_DSN
    where  &DATE_COL >= "&CUTOFF_DATE"d;
  quit;

  %ROW_COUNT(LIB=WORK, DSN=_INCR_EXTRACT, OUTVAR=N_NEW_RECS);
  %LOG_MESSAGE(LEVEL=INFO, MSG=&N_NEW_RECS new records extracted.);

  /* Append to target */
  %if %sysfunc(exist(&TGT_LIB..&TGT_DSN)) %then %do;
    proc append base=&TGT_LIB..&TGT_DSN data=WORK._INCR_EXTRACT force; run;
  %end;
  %else %do;
    data &TGT_LIB..&TGT_DSN;
      set WORK._INCR_EXTRACT;
    run;
  %end;

  /* Deduplicate on primary key CUSTOMER_ID + DATE_COL */
  proc sort data=&TGT_LIB..&TGT_DSN nodupkey;
    by CUSTOMER_ID &DATE_COL;
  run;

  %TIMER_STOP(LABEL=INCR_&TGT_DSN);
%mend INCREMENTAL_LOAD;

%INCREMENTAL_LOAD(
  SRC_LIB    = STAGING,
  SRC_DSN    = CUSTOMERS_CLEAN,
  TGT_LIB    = OUTLIB,
  TGT_DSN    = CUSTOMERS_HISTORY,
  DATE_COL   = SIGNUP_DATE,
  CUTOFF_DATE= 01JAN2024
);

/* ---- 15.2  SCD Type 2 – Slowly Changing Dimension ---- */
%macro SCD2_MERGE(CURRENT_DSN=, INCOMING_DSN=,
                  KEY=, TRACK_COLS=,
                  EFF_DATE_COL=EFFECTIVE_DATE,
                  EXP_DATE_COL=EXPIRY_DATE,
                  CURR_FLAG_COL=IS_CURRENT);
  /* Step 1: Identify changed records */
  proc sql;
    create table WORK._SCD2_CHANGED as
    select n.*
    from   &INCOMING_DSN n
    left join &CURRENT_DSN c on n.&KEY = c.&KEY
              and c.&CURR_FLAG_COL = 1
    where  c.&KEY is null
        or &TRACK_COLS;  /* caller supplies changed-column expression */
  quit;

  /* Step 2: Expire old records */
  data &CURRENT_DSN;
    set &CURRENT_DSN;
    if &CURR_FLAG_COL = 1 then do;
      if &KEY in (select &KEY from WORK._SCD2_CHANGED) then do;
        &EXP_DATE_COL  = today() - 1;
        &CURR_FLAG_COL = 0;
      end;
    end;
  run;

  /* Step 3: Insert new versions */
  data WORK._SCD2_NEW;
    set WORK._SCD2_CHANGED;
    &EFF_DATE_COL  = today();
    &EXP_DATE_COL  = '31DEC9999'D;
    &CURR_FLAG_COL = 1;
  run;

  proc append base=&CURRENT_DSN data=WORK._SCD2_NEW force; run;

  %LOG_MESSAGE(LEVEL=INFO,
    MSG=SCD2 merge complete for &CURRENT_DSN – %trim(%ROW_COUNT) new versions.);
%mend SCD2_MERGE;

/* ---- 15.3  Surrogate key generation ---- */
%macro ADD_SURROGATE_KEY(DSN=, KEY_COL=SK_ID, START=1);
  data &DSN;
    set &DSN;
    &KEY_COL = _N_ + (&START - 1);
  run;
  %LOG_MESSAGE(LEVEL=INFO, MSG=Surrogate key &KEY_COL added to &DSN starting at &START.);
%mend ADD_SURROGATE_KEY;

%ADD_SURROGATE_KEY(DSN=STAGING.MASTER_CUSTOMER_CLUSTERED, KEY_COL=CUSTOMER_SK);

/* ---- 15.4  Build data mart fact table ---- */
proc sql;
  create table OUTLIB.FACT_TRANSACTIONS as
  select
    t.TXN_ID,
    c.CUSTOMER_SK,
    t.CUSTOMER_ID,
    t.TXN_DATE,
    t.TXN_YEAR,
    t.TXN_MONTH,
    t.TXN_QTR,
    t.TXN_TYPE,
    t.CHANNEL,
    t.MERCHANT_CAT,
    m.CATEGORY_GROUP,
    t.CCY,
    t.TXN_AMOUNT_WIN       as TXN_AMOUNT,
    t.IS_REFUND,
    c.SEGMENT,
    c.CLUSTER_LABEL,
    c.REGION,
    c.COUNTRY_NAME
  from STAGING.TRANSACTIONS_CLEAN t
  inner join STAGING.MASTER_CUSTOMER_CLUSTERED c on t.CUSTOMER_ID = c.CUSTOMER_ID
  left join  STAGING.REF_MERCHANT_CATEGORY     m on t.MERCHANT_CAT= m.MERCHANT_CAT
  order by t.TXN_DATE, t.TXN_ID;
quit;

/* ---- 15.5  Build dimension table – customer ---- */
data OUTLIB.DIM_CUSTOMER;
  set STAGING.MASTER_CUSTOMER_CLUSTERED;
  keep CUSTOMER_SK CUSTOMER_ID FULL_NAME EMAIL COUNTRY_CODE COUNTRY_NAME
       REGION CURRENCY SEGMENT TIER_LABEL STATUS GENDER
       AGE AGE_BAND CREDIT_SCORE CREDIT_BAND INCOME_BAND BALANCE_BAND
       ANNUAL_INCOME TENURE_YEARS CLUSTER_LABEL CHURN_FLAG
       SIGNUP_DATE LAST_TXN_DATE INTEREST_RATE CASHBACK_PCT;
run;

/* ---- 15.6  Calendar dimension ---- */
data OUTLIB.DIM_DATE;
  format DATE_KEY date9.;
  do DATE_KEY = '01JAN2020'D to '31DEC2030'D;
    YEAR       = year(DATE_KEY);
    QUARTER    = qtr(DATE_KEY);
    MONTH      = month(DATE_KEY);
    MONTH_NAME = put(DATE_KEY, monname10.);
    WEEK       = week(DATE_KEY);
    DOW        = weekday(DATE_KEY);
    DOW_NAME   = put(DATE_KEY, dayname10.);
    IS_WEEKEND = (DOW in (1,7));
    IS_LEAP    = ((mod(YEAR,4)=0 and mod(YEAR,100) ne 0)
                  or mod(YEAR,400)=0);
    FISCAL_YEAR = year(intnx('month', DATE_KEY, 3));  /* UK fiscal: Apr-Mar */
    FISCAL_QUARTER = ceil(mod(month(DATE_KEY) + 9, 12) / 3);
    output;
  end;
  format IS_WEEKEND IS_LEAP 1.;
run;

%TIMER_STOP(LABEL=ETL);


/* ============================================================
   MODULE 16 – AUDIT & LOGGING FRAMEWORK
   ============================================================ */

%TIMER_START(LABEL=AUDIT);
%LOG_MESSAGE(LEVEL=INFO, MSG=Writing audit trail.);

/* ---- 16.1  Collect pipeline statistics ---- */
data STAGING.PIPELINE_AUDIT;
  length STEP_NAME $60 STATUS $10 RECORDS_IN 8 RECORDS_OUT 8
         STEP_DTTM $20 PROJECT $40 VERSION $10;
  PROJECT  = "&PROJECT_NAME";
  VERSION  = "&PROJECT_VERSION";
  STEP_DTTM= "&RUN_DTTM";

  STEP_NAME="Customers Raw Ingested";        STATUS="SUCCESS"; RECORDS_IN=0;          RECORDS_OUT=&N_CUSTOMERS;    output;
  STEP_NAME="Transactions Raw Ingested";     STATUS="SUCCESS"; RECORDS_IN=0;          RECORDS_OUT=&N_TRANSACTIONS; output;
  STEP_NAME="Campaigns Raw Ingested";        STATUS="SUCCESS"; RECORDS_IN=0;          RECORDS_OUT=&N_CAMPAIGNS;    output;
  STEP_NAME="Duplicate Customer Check";      STATUS="SUCCESS"; RECORDS_IN=&N_CUSTOMERS; RECORDS_OUT=&N_DUPES;      output;
  STEP_NAME="Range Violation Check";         STATUS="WARN";    RECORDS_IN=&N_CUSTOMERS; RECORDS_OUT=&N_RANGE_VIOL; output;
  STEP_NAME="Orphan Transaction Check";      STATUS="WARN";    RECORDS_IN=&N_TRANSACTIONS; RECORDS_OUT=&N_ORPHAN;  output;
  STEP_NAME="Transaction Outlier Detection"; STATUS="INFO";    RECORDS_IN=&N_TRANSACTIONS; RECORDS_OUT=&N_OUTLIERS; output;
  STEP_NAME="Customer Feature Engineering";  STATUS="SUCCESS"; RECORDS_IN=&N_CUSTOMERS;    RECORDS_OUT=&N_CUSTOMERS; output;
  STEP_NAME="Transaction Aggregation";       STATUS="SUCCESS"; RECORDS_IN=&N_TRANSACTIONS; RECORDS_OUT=&N_CUSTOMERS; output;
  STEP_NAME="Train/Test Split";              STATUS="SUCCESS"; RECORDS_IN=&N_CUSTOMERS; RECORDS_OUT=&N_TRAIN;      output;
  STEP_NAME="K-Means Clustering (k=4)";      STATUS="SUCCESS"; RECORDS_IN=&N_CUSTOMERS; RECORDS_OUT=&N_CUSTOMERS;  output;
run;

/* ---- 16.2  Print audit trail ---- */
proc print data=STAGING.PIPELINE_AUDIT noobs label;
  var STEP_DTTM STEP_NAME STATUS RECORDS_IN RECORDS_OUT;
  label STEP_DTTM   ="Run Time"
        STEP_NAME   ="Pipeline Step"
        STATUS      ="Status"
        RECORDS_IN  ="Records In"
        RECORDS_OUT ="Records Out";
  title "Pipeline Execution Audit Trail";
run;

/* ---- 16.3  System information ---- */
data STAGING.SYS_INFO;
  length PARAMETER $40 VALUE $100;
  PARAMETER = "SAS Version";        VALUE = "&SYSVER";         output;
  PARAMETER = "Operating System";   VALUE = "&SYSSCP";         output;
  PARAMETER = "Project Name";       VALUE = "&PROJECT_NAME";   output;
  PARAMETER = "Project Version";    VALUE = "&PROJECT_VERSION"; output;
  PARAMETER = "Run Date";           VALUE = "&RUN_DATE";       output;
  PARAMETER = "Run DateTime";       VALUE = "&RUN_DTTM";       output;
  PARAMETER = "Customers Loaded";   VALUE = trim(left(&N_CUSTOMERS));    output;
  PARAMETER = "Transactions Loaded";VALUE = trim(left(&N_TRANSACTIONS)); output;
  PARAMETER = "Train Rows";         VALUE = trim(left(&N_TRAIN));        output;
  PARAMETER = "Test Rows";          VALUE = trim(left(&N_TEST));         output;
run;

proc print data=STAGING.SYS_INFO noobs;
  title "System & Run Information";
run;

/* ---- 16.4  Data lineage documentation ---- */
data STAGING.DATA_LINEAGE;
  length SOURCE_DSN $60 TARGET_DSN $60 TRANSFORM_DESC $200 SEQ 8;
  infile datalines dlm='|';
  input SEQ SOURCE_DSN $ TARGET_DSN $ TRANSFORM_DESC $;
datalines;
1|RAWDATA.CUSTOMERS_FILE|STAGING.CUSTOMERS_RAW|Raw file load – no transformation
2|STAGING.CUSTOMERS_RAW|STAGING.CUSTOMERS_CLEAN|Case standardisation / banding / imputation / derived features
3|STAGING.TRANSACTIONS_RAW|STAGING.TRANSACTIONS_CLEAN|Filter completed transactions / winsorise amounts / add time flags
4|STAGING.TRANSACTIONS_CLEAN|STAGING.CUST_TXN_AGG|Customer-level transaction aggregation via PROC SQL
5|STAGING.CUSTOMERS_CLEAN + STAGING.CUST_TXN_AGG|STAGING.MASTER_CUSTOMER|Left join enriched customer base + reference data
6|STAGING.MASTER_CUSTOMER|STAGING.CLUSTER_STD|Range standardisation for clustering
7|STAGING.CLUSTER_STD|STAGING.CLUSTER_OUT|K-Means clustering (k=4) via PROC FASTCLUS
8|STAGING.MASTER_CUSTOMER + STAGING.CLUSTER_OUT|STAGING.MASTER_CUSTOMER_CLUSTERED|Merge cluster assignment + label assignment
9|STAGING.MASTER_CUSTOMER_CLUSTERED|OUTLIB.DIM_CUSTOMER|Dimension table extract
10|STAGING.TRANSACTIONS_CLEAN + STAGING.MASTER_CUSTOMER_CLUSTERED|OUTLIB.FACT_TRANSACTIONS|Fact table join with surrogate keys
;
run;

proc print data=STAGING.DATA_LINEAGE noobs label;
  title "Data Lineage Registry";
run;

%TIMER_STOP(LABEL=AUDIT);


/* ============================================================
   MODULE 17 – ADDITIONAL ANALYTICS & UTILITY PROCEDURES
   ============================================================ */

/* ---- 17.1  RFM Scoring (Recency, Frequency, Monetary) ---- */
proc sql;
  create table STAGING.RFM_BASE as
  select
    CUSTOMER_ID,
    today() - max(TXN_DATE)      as RECENCY       label="Days Since Last Purchase",
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

/* ---- 17.2  Cohort Retention Analysis ---- */
proc sql;
  create table STAGING.COHORT_BASE as
  select
    c.CUSTOMER_ID,
    year(c.SIGNUP_DATE)  as COHORT_YEAR,
    qtr(c.SIGNUP_DATE)   as COHORT_QTR,
    year(t.TXN_DATE)     as TXN_YEAR_ACT,
    qtr(t.TXN_DATE)      as TXN_QTR_ACT,
    (year(t.TXN_DATE) - year(c.SIGNUP_DATE)) * 4
    + qtr(t.TXN_DATE) - qtr(c.SIGNUP_DATE) as COHORT_PERIOD
  from STAGING.CUSTOMERS_CLEAN c
  inner join STAGING.TRANSACTIONS_CLEAN t on c.CUSTOMER_ID = t.CUSTOMER_ID;
quit;

proc sql;
  create table STAGING.COHORT_RETENTION as
  select
    COHORT_YEAR,
    COHORT_QTR,
    COHORT_PERIOD,
    count(distinct CUSTOMER_ID) as ACTIVE_CUSTOMERS
  from STAGING.COHORT_BASE
  group by COHORT_YEAR, COHORT_QTR, COHORT_PERIOD;
quit;

proc print data=STAGING.COHORT_RETENTION(obs=40) noobs label;
  var COHORT_YEAR COHORT_QTR COHORT_PERIOD ACTIVE_CUSTOMERS;
  title "Customer Cohort Retention Matrix (First 40 rows)";
run;

/* ---- 17.3  Basket analysis – channel × merchant co-occurrence ---- */
proc freq data=STAGING.TRANSACTIONS_CLEAN noprint;
  tables CHANNEL * MERCHANT_CAT / sparse out=STAGING.CHANNEL_MERCH_XREF;
run;

proc report data=STAGING.CHANNEL_MERCH_XREF nowd;
  column CHANNEL MERCHANT_CAT COUNT PERCENT;
  define CHANNEL     / group "Channel" width=12;
  define MERCHANT_CAT / group "Merchant Category" width=20;
  define COUNT       / sum "# Transactions" format=comma10.;
  define PERCENT     / mean "% of Total" format=percent8.2;
  title "Channel × Merchant Category Cross-Reference";
run;

/* ---- 17.4  Cumulative distribution of spend (Pareto) ---- */
proc sort data=STAGING.RFM_BASE out=_pareto; by descending MONETARY; run;

data STAGING.PARETO_SPEND;
  set _pareto;
  CUM_SPEND    = sum(CUM_SPEND, MONETARY);
  CUM_CUST_PCT = _N_ / &N_CUSTOMERS;
run;

proc sql noprint;
  select max(CUM_SPEND) into :TOTAL_SPEND_ALL
  from   STAGING.PARETO_SPEND;
quit;

data STAGING.PARETO_SPEND;
  set STAGING.PARETO_SPEND;
  CUM_SPEND_PCT = CUM_SPEND / &TOTAL_SPEND_ALL;
  format CUM_CUST_PCT CUM_SPEND_PCT percent8.2;
run;

proc sgplot data=STAGING.PARETO_SPEND;
  series x=CUM_CUST_PCT y=CUM_SPEND_PCT / lineattrs=(color=navy thickness=2);
  refline 0.8 / axis=y lineattrs=(color=red pattern=dash)
                label="80% of Spend";
  xaxis label="Cumulative % of Customers" grid values=(0 to 1 by 0.1)
        valuesformat=percent6.;
  yaxis label="Cumulative % of Spend"    grid values=(0 to 1 by 0.1)
        valuesformat=percent6.;
  title "Pareto Curve – Customer Spend Concentration";
run;

/* ---- 17.5  Survival analysis stub (time to churn) ---- */
data STAGING.SURVIVAL_INPUT;
  set STAGING.MASTER_CUSTOMER_CLUSTERED;
  where not missing(DAYS_SINCE_TXN);
  TIME_TO_EVENT = DAYS_SINCE_TXN;
  EVENT         = CHURN_FLAG;
run;

proc lifetest data=STAGING.SURVIVAL_INPUT
              plots=(s(atrisk nocensor) h lls)
              notable;
  time  TIME_TO_EVENT * EVENT(0);
  strata SEGMENT;
  title "Kaplan-Meier Survival Curves by Segment (Time to Churn)";
run;

/* ---- 17.6  Time series – forecasting monthly volume ---- */
proc arima data=STAGING.MONTHLY_TXN_TREND;
  identify var=TOTAL_VOLUME(1) nlag=24
           stationarity=(adf=2);
  estimate p=1 q=1 method=ml;
  forecast lead=12 out=STAGING.ARIMA_FORECAST id=TXN_MONTH interval=month;
  title "ARIMA(1,1,1) – Monthly Transaction Volume Forecast";
run;
quit;

/* ---- 17.7  Decision tree (PROC HPSPLIT) ---- */
/*
proc hpsplit data=STAGING.TRAIN_DATA seed=&SEED
             maxdepth=6 leafsize=50;
  target   CHURN_FLAG / level=binary;
  input    AGE CREDIT_SCORE ANNUAL_INCOME BALANCE TENURE_YEARS
           TXN_COUNT TOTAL_SPEND / level=interval;
  input    SEGMENT GENDER REGION / level=nominal;
  code     file="&OUTPUT_PATH./decision_tree_score.sas";
  title    "Decision Tree: Churn Prediction";
run;
*/

/* ---- 17.8  Association rules (PROC HPASSOC) ---- */
/*
proc hpassoc data=STAGING.TRANSACTIONS_CLEAN
             minsupp=0.01 minconf=0.2 maxrules=50;
  transaction CUSTOMER_ID;
  item        MERCHANT_CAT;
  output out  =STAGING.ASSOC_RULES;
  title "Association Rules – Merchant Category Co-Purchase";
run;
*/

/* ---- 17.9  Credit risk scorecard (WOE / IV) ---- */
%macro WOE_ANALYSIS(DSN=, TARGET=, PREDICTORS=);
  %local i var;
  %let i = 1;
  %do %while(%scan(&PREDICTORS, &i, ' ') ne );
    %let var = %scan(&PREDICTORS, &i, ' ');
    proc sql;
      create table WORK._WOE_&var as
      select
        &var as BAND,
        sum(&TARGET)         as EVENTS,
        count(*) - sum(&TARGET) as NON_EVENTS,
        count(*)             as TOTAL
      from &DSN
      group by &var;
    quit;

    data WORK._WOE_&var;
      set WORK._WOE_&var;
      retain TOTAL_EVENTS TOTAL_NON;
      /* simplified WOE – would require totals passed in */
      WOE = log((EVENTS + 0.5) / (NON_EVENTS + 0.5));
      IV_COMPONENT = (EVENTS/(EVENTS+0.001) - NON_EVENTS/(NON_EVENTS+0.001)) * WOE;
    run;

    proc print data=WORK._WOE_&var noobs;
      title "WOE Analysis: &var vs &TARGET in &DSN";
    run;

    %let i = %eval(&i + 1);
  %end;
%mend WOE_ANALYSIS;

%WOE_ANALYSIS(
  DSN        = STAGING.MASTER_CUSTOMER_CLUSTERED,
  TARGET     = CHURN_FLAG,
  PREDICTORS = AGE_BAND CREDIT_BAND INCOME_BAND SEGMENT REGION
);

/* ---- 17.10  Campaign attribution – last-touch model ---- */
proc sql;
  create table STAGING.CAMPAIGN_ATTRIBUTION as
  select
    c.CAMPAIGN_ID,
    c.CAMPAIGN_NAME,
    c.CHANNEL,
    count(distinct t.CUSTOMER_ID)   as ATTRIBUTED_CUSTOMERS,
    sum(t.TXN_AMOUNT_WIN)           as ATTRIBUTED_REVENUE format=comma14.2,
    c.SPEND,
    calculated ATTRIBUTED_REVENUE / (c.SPEND + 0.01) as ATTR_ROAS format=8.2
  from STAGING.CAMPAIGNS_ENRICHED c
  inner join STAGING.TRANSACTIONS_CLEAN t
    on  t.TXN_DATE between c.START_DATE and c.END_DATE
    and t.CHANNEL = 'Online'          /* last-touch = online channel */
  group by c.CAMPAIGN_ID, c.CAMPAIGN_NAME, c.CHANNEL, c.SPEND;
quit;

proc report data=STAGING.CAMPAIGN_ATTRIBUTION nowd;
  column CHANNEL CAMPAIGN_NAME SPEND ATTRIBUTED_REVENUE ATTR_ROAS ATTRIBUTED_CUSTOMERS;
  define CHANNEL             / group  "Channel"        width=10;
  define CAMPAIGN_NAME       / display "Campaign"      width=25;
  define SPEND               / sum     "Spend (£)"     format=comma12.;
  define ATTRIBUTED_REVENUE  / sum     "Revenue (£)"   format=comma14.;
  define ATTR_ROAS           / mean    "ROAS"          format=8.2;
  define ATTRIBUTED_CUSTOMERS / sum    "# Customers"   format=comma8.;
  title "Campaign Attribution Report – Last-Touch Model";
run;

/* ---- 17.11  Macro-driven sensitivity analysis ---- */
%macro SENSITIVITY_TABLE(BASE_VALUE=, PCT_CHANGES=, LABEL=Metric);
  data WORK._SENS;
    length PCT_CHANGE 8 ADJUSTED_VALUE 8;
    BASE = &BASE_VALUE;
    do PCT = &PCT_CHANGES;
      PCT_CHANGE     = PCT;
      ADJUSTED_VALUE = BASE * (1 + PCT / 100);
      output;
    end;
    format ADJUSTED_VALUE comma14.2 PCT_CHANGE 8.1;
    drop BASE;
  run;
  proc print data=WORK._SENS noobs;
    title "Sensitivity Analysis: &LABEL";
  run;
%mend SENSITIVITY_TABLE;

%SENSITIVITY_TABLE(
  BASE_VALUE  = %sysevalf(&TXN_MEAN),
  PCT_CHANGES = -20 -10 -5 0 5 10 20 30 50,
  LABEL       = Average Transaction Amount
);

/* ---- 17.12  Macro loop: multi-segment model ---- */
%macro SEGMENT_MODELS(SEGMENTS=Premium Standard Basic Trial);
  %local i seg;
  %let i = 1;
  %do %while(%scan(&SEGMENTS, &i, ' ') ne );
    %let seg = %scan(&SEGMENTS, &i, ' ');
    %LOG_MESSAGE(LEVEL=INFO, MSG=Fitting model for segment: &seg);

    data WORK._SEG_DATA;
      set STAGING.TRAIN_DATA;
      where SEGMENT = "&seg";
    run;

    %let n_seg_obs = 0;
    %if %sysfunc(exist(WORK._SEG_DATA)) %then %do;
      %ROW_COUNT(LIB=WORK, DSN=_SEG_DATA, OUTVAR=n_seg_obs);
      %if &n_seg_obs > 50 %then %do;
        proc logistic data=WORK._SEG_DATA noprint;
          model CHURN_FLAG(event='1') =
                AGE CREDIT_SCORE ANNUAL_INCOME BALANCE TENURE_YEARS TXN_COUNT;
          output out=WORK._SEG_SCORES_&seg p=P_CHURN;
        run;
        %LOG_MESSAGE(LEVEL=INFO, MSG=Segment &seg model scored &n_seg_obs records.);
      %end;
      %else %do;
        %LOG_MESSAGE(LEVEL=WARN,
          MSG=Segment &seg has only &n_seg_obs obs – skipping model.);
      %end;
    %end;

    %let i = %eval(&i + 1);
  %end;
%mend SEGMENT_MODELS;

%SEGMENT_MODELS(SEGMENTS=Premium Standard Basic Trial);

/* ---- 17.13  Variance Inflation Factor checks ---- */
proc reg data=STAGING.TRAIN_DATA;
  model TOTAL_SPEND = AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
                      TENURE_YEARS TXN_COUNT AVG_TXN_AMOUNT
                      / vif tol;
  ods select ParameterEstimates;
  title "VIF / Tolerance Check – Multicollinearity Diagnostics";
run;
quit;

/* ---- 17.14  Principal Component Analysis ---- */
proc princomp data = STAGING.CLUSTER_STD
              out  = STAGING.PCA_SCORES
              n    = 5
              plots= all;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE
      TENURE_YEARS TXN_COUNT TOTAL_SPEND AVG_TXN_AMOUNT
      REFUND_RATE CHANNEL_DIVERSITY;
  title "Principal Component Analysis – Customer Features";
run;

proc sgplot data=STAGING.PCA_SCORES;
  scatter x=Prin1 y=Prin2 / group=SEGMENT markerattrs=(size=4);
  xaxis label="First Principal Component";
  yaxis label="Second Principal Component";
  title "PCA Scatter Plot: PC1 vs PC2 by Segment";
run;

/* ---- 17.15  Decision matrix – business rules engine ---- */
%macro BUSINESS_RULES_ENGINE(DSN=, OUTDSN=);
  data &OUTDSN;
    set &DSN;

    length ACTION $50 PRIORITY $10 REASON $100;

    /* Rule 1: High-value at-risk */
    if SEGMENT = 'Premium' and CHURN_FLAG = 1 and TOTAL_SPEND > 5000 then do;
      ACTION   = 'Retention Call – Priority';
      PRIORITY = 'High';
      REASON   = 'Premium churn risk with high spend history';
    end;
    /* Rule 2: Credit score deterioration */
    else if CREDIT_SCORE < 580 and CREDIT_BAND = 'Poor' then do;
      ACTION   = 'Risk Review';
      PRIORITY = 'High';
      REASON   = 'Credit score below acceptable threshold';
    end;
    /* Rule 3: Upsell opportunity */
    else if SEGMENT in ('Basic','Trial') and ANNUAL_INCOME > 50000
         and TXN_COUNT > 20 then do;
      ACTION   = 'Upsell to Standard/Premium';
      PRIORITY = 'Medium';
      REASON   = 'High income + engagement in lower tier';
    end;
    /* Rule 4: Cross-sell – no international transactions */
    else if CHANNEL_DIVERSITY = 1 and TOTAL_SPEND > 2000 then do;
      ACTION   = 'Cross-Sell Multi-Channel Product';
      PRIORITY = 'Medium';
      REASON   = 'Single channel customer with good spend';
    end;
    /* Rule 5: Dormant reactivation */
    else if DAYS_SINCE_TXN > 365 and STATUS ne 'Suspended' then do;
      ACTION   = 'Reactivation Campaign';
      PRIORITY = 'Low';
      REASON   = 'No transaction in over 12 months';
    end;
    /* Default */
    else do;
      ACTION   = 'Standard Servicing';
      PRIORITY = 'Low';
      REASON   = 'No specific action triggered';
    end;
  run;
%mend BUSINESS_RULES_ENGINE;

%BUSINESS_RULES_ENGINE(
  DSN   = STAGING.MASTER_CUSTOMER_CLUSTERED,
  OUTDSN= OUTLIB.CUSTOMER_ACTIONS
);

proc freq data=OUTLIB.CUSTOMER_ACTIONS;
  tables ACTION * PRIORITY / nocum nopercent;
  title "Business Rules Engine: Action Distribution";
run;

/* ---- 17.16  Export final deliverables ---- */
proc export data=OUTLIB.CUSTOMER_ACTIONS
            outfile="&OUTPUT_PATH./Customer_Actions_&RUN_DATE..csv"
            dbms=csv replace;
run;

proc export data=OUTLIB.FACT_TRANSACTIONS
            outfile="&OUTPUT_PATH./Fact_Transactions_&RUN_DATE..csv"
            dbms=csv replace;
run;

proc export data=STAGING.RFM_SCORED
            outfile="&OUTPUT_PATH./RFM_Scores_&RUN_DATE..csv"
            dbms=csv replace;
run;

/* ---- 17.17  Final model output table ---- */
proc sql;
  create table OUTLIB.MODEL_OUTPUT as
  select
    a.CUSTOMER_ID,
    a.FULL_NAME,
    a.SEGMENT,
    a.CLUSTER_LABEL,
    a.REGION,
    a.COUNTRY_NAME,
    a.AGE,
    a.CREDIT_SCORE,
    a.ANNUAL_INCOME,
    a.BALANCE,
    a.TOTAL_SPEND,
    a.TXN_COUNT,
    a.CHURN_FLAG,
    b.P_1                  as CHURN_PROB          format=8.4
                             label="Predicted Churn Probability",
    case when b.P_1 >= 0.5 then 1 else 0 end
                           as CHURN_PRED          label="Predicted Churn Flag",
    r.RFM_SEGMENT,
    r.R_SCORE,
    r.F_SCORE,
    r.M_SCORE,
    r.RFM_TOTAL,
    c.ACTION               as RECOMMENDED_ACTION,
    c.PRIORITY             as ACTION_PRIORITY,
    c.REASON               as ACTION_REASON
  from STAGING.MASTER_CUSTOMER_CLUSTERED a
  left join STAGING.LOGIT_TRAIN_SCORES   b on a.CUSTOMER_ID = b.CUSTOMER_ID
  left join STAGING.RFM_SCORED           r on a.CUSTOMER_ID = r.CUSTOMER_ID
  left join OUTLIB.CUSTOMER_ACTIONS      c on a.CUSTOMER_ID = c.CUSTOMER_ID
  order by b.P_1 desc;
quit;

proc print data=OUTLIB.MODEL_OUTPUT(obs=20) noobs label;
  title "Model Output – Top 20 Churn Risk Customers";
run;


/* ============================================================
   MODULE 18 – DATA QUALITY REMEDIATION
   ============================================================ */

/* ---- 18.1  Impute remaining missing values using PROC MI ---- */
proc mi data     = STAGING.CUSTOMERS_CLEAN
        out      = STAGING.CUSTOMERS_MI
        nimpute  = 5
        seed     = &SEED;
  mcmc;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE;
run;

/* pool results from 5 imputations */
proc mianalyze data=STAGING.CUSTOMERS_MI;
  modeleffects AGE CREDIT_SCORE ANNUAL_INCOME BALANCE;
  title "Multiple Imputation – Pooled Estimates";
run;

/* ---- 18.2  Post-imputation checks ---- */
proc means data=STAGING.CUSTOMERS_MI nmiss n mean std maxdec=2;
  var AGE CREDIT_SCORE ANNUAL_INCOME BALANCE;
  title "Post-Imputation Descriptive Statistics";
run;


/* ============================================================
   MODULE 19 – MACRO STRESS TESTING & VALIDATION
   ============================================================ */

%macro VALIDATE_MODEL_OUTPUT(DSN=, TARGET=, PRED_PROB=, PRED_FLAG=);
  /* Gini coefficient approximation */
  proc sql noprint;
    select count(*) into :N_VAL trimmed
    from   &DSN;
    select mean(&TARGET) into :BASE_RATE trimmed
    from   &DSN;
  quit;
  %LOG_MESSAGE(LEVEL=INFO,
    MSG=Validation set: &N_VAL obs  Base rate: &BASE_RATE);

  /* KS statistic */
  proc npar1way data=&DSN edf;
    class  &TARGET;
    var    &PRED_PROB;
    ods output KolmogorovSmirnovTest=WORK._KS_STAT;
    title "KS Statistic – Model Discrimination";
  run;

  /* Lift chart */
  proc rank data=&DSN out=WORK._LIFT_DATA groups=10 descending;
    var &PRED_PROB;
    ranks DECILE;
  run;

  proc sql;
    create table WORK._LIFT_SUMMARY as
    select
      DECILE + 1            as DECILE,
      count(*)              as N,
      sum(&TARGET)          as EVENTS,
      mean(&PRED_PROB)      as MEAN_PRED_PROB format=8.4,
      sum(&TARGET)/count(*) as ACTUAL_RATE    format=percent8.2,
      (sum(&TARGET)/count(*)) / &BASE_RATE
                            as LIFT           format=8.2
    from WORK._LIFT_DATA
    group by DECILE
    order by DECILE;
  quit;

  proc print data=WORK._LIFT_SUMMARY noobs label;
    title "Decile Lift Table – &DSN";
    label DECILE="Decile" N="# Obs" EVENTS="Events"
          ACTUAL_RATE="Actual Rate" LIFT="Lift";
  run;
%mend VALIDATE_MODEL_OUTPUT;

%VALIDATE_MODEL_OUTPUT(
  DSN       = STAGING.LOGIT_TRAIN_SCORES,
  TARGET    = CHURN_FLAG,
  PRED_PROB = P_1,
  PRED_FLAG = I_CHURN_FLAG
);


/* ============================================================
   MODULE 20 – FINAL SUMMARY & CLEANUP
   ============================================================ */

%TIMER_START(LABEL=CLEANUP);
%LOG_MESSAGE(LEVEL=INFO, MSG=Running cleanup.);

/* ---- 20.1  Drop temporary work datasets ---- */
%macro CLEANUP_WORK;
  proc datasets library=WORK nolist;
    delete _tmp_cols _txn_stats _pareto
           _dummy_ccc _INCR_EXTRACT
           _SCD2_CHANGED _SCD2_NEW
           _LIFT_DATA _LIFT_SUMMARY
           _KS_STAT _SENS
           _SEG_DATA _WOE_:
           _pareto;
    run;
  quit;
%mend CLEANUP_WORK;

%CLEANUP_WORK;

/* ---- 20.2  Persist key tables to permanent library ---- */
%macro PERSIST_TABLE(SRC_LIB=STAGING, SRC_DSN=, TGT_LIB=OUTLIB);
  %if %sysfunc(exist(&SRC_LIB..&SRC_DSN)) %then %do;
    data &TGT_LIB..&SRC_DSN;
      set &SRC_LIB..&SRC_DSN;
    run;
    %LOG_MESSAGE(LEVEL=INFO,
      MSG=Persisted &SRC_LIB..&SRC_DSN to &TGT_LIB..&SRC_DSN.);
  %end;
  %else
    %LOG_MESSAGE(LEVEL=WARN,
      MSG=Skipped persist – &SRC_LIB..&SRC_DSN not found.);
%mend PERSIST_TABLE;

%PERSIST_TABLE(SRC_DSN=MASTER_CUSTOMER_CLUSTERED);
%PERSIST_TABLE(SRC_DSN=PIPELINE_AUDIT);
%PERSIST_TABLE(SRC_DSN=DQ_AUDIT_SUMMARY);
%PERSIST_TABLE(SRC_DSN=RFM_SCORED);
%PERSIST_TABLE(SRC_DSN=COHORT_RETENTION);
%PERSIST_TABLE(SRC_DSN=MONTHLY_TXN_TREND);
%PERSIST_TABLE(SRC_DSN=CAMPAIGNS_ENRICHED);
%PERSIST_TABLE(SRC_DSN=CAMPAIGN_ATTRIBUTION);
%PERSIST_TABLE(SRC_DSN=PARETO_SPEND);

/* ---- 20.3  Final project summary ---- */
%LOG_MESSAGE(LEVEL=INFO, MSG=============================================);
%LOG_MESSAGE(LEVEL=INFO, MSG=EGP ANALYTICS PROJECT COMPLETE);
%LOG_MESSAGE(LEVEL=INFO, MSG=Project:   &PROJECT_NAME v&PROJECT_VERSION);
%LOG_MESSAGE(LEVEL=INFO, MSG=Run Date:  &RUN_DATE);
%LOG_MESSAGE(LEVEL=INFO, MSG=Customers: &N_CUSTOMERS);
%LOG_MESSAGE(LEVEL=INFO, MSG=Transactions: &N_TRANSACTIONS);
%LOG_MESSAGE(LEVEL=INFO, MSG=Campaigns:  &N_CAMPAIGNS);
%LOG_MESSAGE(LEVEL=INFO, MSG=Train Obs:  &N_TRAIN);
%LOG_MESSAGE(LEVEL=INFO, MSG=Test Obs:   &N_TEST);
%LOG_MESSAGE(LEVEL=INFO, MSG=============================================);

%TIMER_STOP(LABEL=CLEANUP);

/* ---- 20.4  Clear titles and footnotes ---- */
title;
footnote;

/* ---- 20.5  Deassign libraries ---- */
libname RAWDATA clear;
libname STAGING clear;
libname OUTLIB  clear;
libname LOGLIB  clear;

/* ============================================================
   END OF FILE: EGP_Analytics_Project.sas
   Version : &PROJECT_VERSION
   Lines   : ~2600
   Author  : Analytics CoE
   Modules : 20
   Macros  : 22
   Procs   : 50+
   ============================================================ */
