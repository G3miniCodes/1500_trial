/* cap input rows for the captured run */
options obs=100;

/* the upstream script assigns RAWDATA/STAGING/OUTLIB/LOGLIB under
   %let BASE_PATH = /data/analytics (a machine-local path in the
   original repo); this bundle points BASE_PATH at a relative
   ./sasdata tree instead and pre-creates the subdirectories the
   script's libname statements expect to find. */
options dlcreatedir;
libname sasdata "./sasdata";
libname sasdata "./sasdata/raw";
libname sasdata "./sasdata/staging";
libname sasdata "./sasdata/output";
libname sasdata "./sasdata/logs";
