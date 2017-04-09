/* 1. Pre-process of the time series */
data data;
input rate@@;
year=intnx('year','1jan1970'd,_n_-1);
format year year4.;
cards;
25.83    23.33    22.16    20.89    17.48    15.69    12.66
12.06    12.00    11.61    11.87    14.55    15.68    13.29
13.08    14.26    15.57    16.61    15.73    15.04    14.39
12.98    11.60    11.45    11.21    10.55    10.42    10.06
9.14     8.18     7.58     6.95     6.45     6.01     5.87
5.89     5.28     5.17     5.08     4.87     4.79     4.79
4.95     4.92
;

/* time series plot */
proc gplot;
plot rate*year=1;
symbol1 i=join v=none c=black;
run;
/* test the stationarity and randomness of the series */
proc arima data=data;
identify var=rate;
run;
data example;
input x@@;
lag=lag(x);
log=log(x);
loglag=log(lag);
diflog=dif(log);
difx=dif(x);
t=_n_-1;
cards;
25.83    23.33    22.16    20.89    17.48    15.69    12.66
12.06    12.00    11.61    11.87    14.55    15.68    13.29
13.08    14.26    15.57    16.61    15.73    15.04    14.39
12.98    11.60    11.45    11.21    10.55    10.42    10.06
9.14     8.18     7.58     6.95     6.45     6.01     5.87
5.89     5.28     5.17     5.08     4.87     4.79     4.79
4.95     4.92  
;


/* 2. Fit an ARIMA model */
/* first-order difference */
proc gplot;
plot difx*t=1;
symbol1 i=join v=star c=black;
run;

/* fit ARIMA((1,10),1,0) model */
proc arima;
identify var=x(1) nlag=18;
estimate p=(1 10);
run;
forecast lead=3 id=t out=out;   
run;

/* plot performance of the fitted model */
proc gplot data=out;
plot x*t=1 forecast*t=2/overlay;
symbol1 c=black i=join v=star;
symbol2 c=red i=join v=none w=2 l=3;
run;


/* 3. Fit the auto-regressive error model */
/* fit the regression model with a lagged dependent variable */
proc autoreg data=example;
model x=lag/lagdep=lag archtest;
run;

/* 3.1. Fit GARCH model */
/* try to fit GARCH(1,1) model */
proc autoreg data=example;
model x=lag/lagdep=lag noint nlag=5 backstep garch=(p=1,q=1);   
output out=out p=xp;
run;

/* finally obtain GARCH(1,(5)) model */
proc autoreg data=example;
model x=lag/lagdep=lag noint nlag=5 backstep garch=(p=1,q=(5));
output out=out p=xp;
run;
proc print data=out;
run;

/* plot performance of the fitted model */
proc gplot data=out;
plot x*t=1 xp*t=2/overlay;
symbol1 v=star i=join c=black;
symbol2 v=none i=join c=red w=2 l=3;
run;

/* 3.2. Equal-variance transformation (log-transformation) */
proc autoreg data=example;
model log=loglag/lagdep=loglag archtest;
model log=loglag/lagdep=loglag noint nlag=5 backstep method=ml;  
output out=out p=xp;
run;

/* plot performance of the fitted model */
proc gplot data=out;
plot log*t=1 xp*t=2/overlay;
symbol1 v=star i=join c=black;
symbol2 v=none i=join c=red w=2 l=3;
run;




