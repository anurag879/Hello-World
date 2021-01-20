options validvarname=v7;
proc import datafile="/folders/myfolders/myprograms/TSAClaims2002_2017.csv"
            dbms=csv out=tsa.claims_cleaned replace;
            guessingrows=max;
run;

proc print data=tsa.claims_cleaned (obs=20);
run;
proc contents data=work.tsa_data varnum;
run;

proc freq data=tsa.claims_cleaned;
 tables claim_site claim_type / nocol nocum;
 tables Date_received Incident_date / nocol nocum;
 format date_received Incident_date date9.;
run;

proc sort data=tsa.claims_cleaned
     nodupkey out=tsa.claims_dupout ;   
     by _all_;
run;

proc sort data=tsa.claims_dupout;   
     by Incident_Date;
run;

data tsa_data;
  set tsa.claims_cleaned;
  if claim_type = "-" or claim_type = " " then Claim_type = "Unknown";
  if claim_site = "-" or claim_site = " " then Claim_site = "Unknown";
  length disposition $ 23;
  if disposition = "-" or disposition = " " then disposition = "Unknown";
  Statenames = propcase(Statename);
  State = upcase(State);
  format Date_Received date9.;
  format Incident_date date9.;
  if (Date_Received = " " or Incident_date = " ") or 
  (year(Date_Received) < 2002 and year(Incident_date) > 2017) or
  (Incident_date > Date_recieved)
  then Date_Issues = "Needs Review";
  drop country city;
  format Close_amount dollar10.2;
  format Date_received Incident_date ddmmmyy.;
run;

ods pdf file=claimReports pdftoc=1 style=meadow  startpage=no;
proc print data=tsa.claims_cleaned;
run;
ods pdf close;
