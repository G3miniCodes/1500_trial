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

/* Bundle note: the source continues at module 11.3 with
   "proc fastclus ... maxclus = 4 ..." -- MAXCLUS= is not a documented
   PROC FASTCLUS option (the real option is MAXCLUSTERS=, alias MAXC=),
   so this looks like a typo in the source script rather than a Jenner
   gap; Jenner correctly rejects it. This bundle stops after the 11.2
   CCC (optimal-k) determination step, which runs unmodified. */
