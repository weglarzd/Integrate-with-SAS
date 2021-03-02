
/**********************************************
								 Michigan Data
**********************************************/

options validvarname=v7;
/*Path to Data and Program*/
%let path=C:\Users\danie\Documents\GVSU\Grad Year 2\COVID Grad Assist\Data files;
/*Library name where SAS data files are stored*/
libname dist "&path";

/* Upcase all character variables - https://support.sas.com/kb/39/525.html*/
%macro upcase_char();
	/* this array groups all the character variables together into one array*/
	array vars(*) _character_;
	do i=1 to dim(vars);
		/*use the UPCASE function to uppercase each value*/
		vars(i)=upcase(vars(i));
	end;
	drop i;
%mend;

/*Quite Large Data from Michigan State and MI Govt. Collab
Link to Dashboard: https://www.mischooldata.org/covid-dashboard/
*/
proc import out=mi_dash datafile="&path.\COVID19 Dashboard Downloadable File.xlsx"
		dbms=excel replace;
	getnames=yes;
	sheet="OUTPUTFILE";
run;

proc import out=district_lunch datafile="&path.\Check_Names_Updated.xlsx"
		dbms=excel replace;
	getnames=yes;
	sheet="CHECK_NAMES";
run;

data mi_dash;
	set mi_dash;
	%upcase_char();
run;

proc contents data=mi_dash varnum; run;

proc contents data=district_lunch varnum; run;

/*proc sort data=mi_dash;*/
/*	by DistrictName;*/
/*run;*/
/*proc sort data=district_lunch;*/
/*	by District;*/
/*run;*/
/**/
/*data complete_merge;*/
/*	merge mi_dash district_lunch(rename=(District=DistrictName));*/
/*	by DistrictName;*/
/*run;*/

proc sql;
create table complete_merge as
select *
from mi_dash as x, district_lunch as y
where x.DistrictName = y.District
order by x.DistrictName
;
quit;
/* Checked for no matches (all matched)
data no_matches;
	set complete_merge;
	if Start_Grade = "" then output;
	if SubmissionMonth = "" then output;
run;
*/

proc means data=complete_merge n sum maxdec=0;
	class SubmissionMonth FullyRemoteStudentPercentage;
	var sum_free_lunch sum_reduced_lunch total_enrolled;
run;

proc freq data=complete_merge;
table HybridPreKDaysofInPersonPerWeekR;
run;


/* Transpose data */
/*
- Row for each lunch status (free, reduced, and full)
- Move values in these columns to a count (number of students)
*/