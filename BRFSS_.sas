

*Analysis of BRFSS data

Outcome variable:CVDINFR4 ((Ever told) you had a heart attack, also called a myocardial infarction?)

Explanatory variable of interest:EXERANY2 (During the past month, other than your regular job, did you participate in any
 physical activities or exercises such as running, calisthenics, golf, gardening, or walking for exercise?)

Numeric variable:SLEPTIM1 (On average, how many hours of sleep do you get in a 24-hour period?)

Categorical variables (>2 levels):AGEGROUP (Age groups: 45-54 yrs, 55-64, 65yrs or older) _BMI5CAT (Body Mass Index) SMOKDAY2 (Do you now smoke
 cigarettes every day, some days, or not at all?)
*/
;

LIBNAME a "/home/u60771138/BRFSS";

OPTIONS FMTSEARCH=(a.p25format);

*/we use "data" , "set" and "keep" functions to geberate the dataset
*/
;
DATA a2;
set a.p25;
keep CVDCRHD4 CVDINFR4 _BMI5CAT AGEGROUP EXERANY2 SLEPTIM1 SMOKDAY2 ;
RUN;

PROC PRINT DATA=a2;
RUN; 

*check normality for continous variables;

PROC UNIVARIATE DATA = a2 NORMAL;
VAR SLEPTIM1;
CLASS CVDINFR4;
RUN;

*run the wilcoxin test as the variable not normal;

PROC NPAR1WAY DATA= a2 WILCOXON;
 VAR SLEPTIM1;
 CLASS CVDINFR4;
RUN;

*Distribution of categorical variables;

PROC FREQ DATA=a2;
   TABLES CVDCRHD4*CVDINFR4 _BMI5CAT*CVDINFR4 AGEGROUP*CVDINFR4 SMOKDAY2*CVDINFR4 EXERANY2*CVDINFR4  / NOROW NOPERCENT CHISQ EXPECTED;
RUN;

*Simple logistic regression for odds ratio;

PROC LOGISTIC DATA = a2;
MODEL CVDINFR4 = SLEPTIM1;                               *Yes=1, N0=2;
RUN;

PROC LOGISTIC DATA = a2;
CLASS CVDCRHD4 (REF="Yes")/ PARAM = REF;                 *Yes=1, N0=2;
MODEL CVDINFR4 (EVENT="Yes")= CVDCRHD4;
RUN;

PROC LOGISTIC DATA = a2;
CLASS _BMI5CAT (REF="Underweight")/ PARAM = REF;          *1=Underweight  2=Normal weight  3=Overweight  4=obese; 
MODEL CVDINFR4 (EVENT="Yes")= _BMI5CAT;
RUN;

PROC LOGISTIC DATA = a2;
CLASS AGEGROUP (REF="Age 45 - 54")/ PARAM = REF;           
MODEL CVDINFR4 (EVENT="Yes")= AGEGROUP;
RUN;

PROC LOGISTIC DATA = a2;
CLASS SMOKDAY2 (REF="Every day")/ PARAM = REF;             *1=Every day 2=Some days 3=Not at all ;
MODEL CVDINFR4 (EVENT="Yes")= SMOKDAY2;
RUN;

PROC LOGISTIC DATA = a2;
CLASS EXERANY2 (REF="Yes")/ PARAM = REF;
MODEL CVDINFR4 (EVENT="Yes")= EXERANY2;                    *Yes=1, No=2;
RUN;


*collinearity;

PROC REG DATA = a2;
 MODEL CVDINFR4 = EXERANY2 CVDCRHD4 _BMI5CAT AGEGROUP SLEPTIM1 SMOKDAY2/VIF;
RUN;


*multinomial logistic regression model selection;

*Stepwise selection;

PROC LOGISTIC DATA = a2;
 CLASS CVDCRHD4 (REF= "Yes") AGEGROUP (REF= "Age 45 - 54") SMOKDAY2 (REF="Every day") _BMI5CAT EXERANY2 (REF= "Yes")/ PARAM= REF;
 MODEL CVDINFR4 (EVENT = "Yes") = EXERANY2 CVDCRHD4 _BMI5CAT AGEGROUP SLEPTIM1 SMOKDAY2/ SELECTION=STEPWISE INCLUDE=1;
RUN;

*Forward selection;

PROC LOGISTIC DATA = a2;
 CLASS CVDCRHD4 (REF= "Yes") AGEGROUP (REF= "Age 45 - 54") SMOKDAY2 (REF="Every day") _BMI5CAT EXERANY2 (REF= "Yes")/ PARAM= REF;
 MODEL CVDINFR4 (EVENT = "Yes") = EXERANY2 CVDCRHD4 _BMI5CAT AGEGROUP SLEPTIM1 SMOKDAY2/ SELECTION=FORWARD INCLUDE=1;
RUN;

*Backward selection;

PROC LOGISTIC DATA = a2;
 CLASS CVDCRHD4 (REF= "Yes") AGEGROUP (REF= "Age 45 - 54") SMOKDAY2 (REF="Every day") _BMI5CAT EXERANY2 (REF= "Yes")/ PARAM= REF;
 MODEL CVDINFR4 (EVENT = "Yes") = EXERANY2 CVDCRHD4 _BMI5CAT AGEGROUP SLEPTIM1 SMOKDAY2/ SELECTION=BACKWARD INCLUDE=1;
RUN;

* evaluate the FINAL MODEL;
PROC LOGISTIC DATA = a2 PLOTS = (ROC INFLUENCE DFBETAS);
 CLASS EXERANY2 (REF="Yes") AGEGROUP (REF= "Age 45 - 54") CVDCRHD4/ PARAM= REF;
 MODEL CVDINFR4 (EVENT = "Yes") = EXERANY2 CVDCRHD4 AGEGROUP/ RSQUARE LACKFIT;
RUN;

