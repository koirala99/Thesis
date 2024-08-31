clear all 

*Importing the data for analysis*
import excel "C:\Users\lenovo\Desktop\Research\data\new_merger.xlsx", sheet("Sheet1") firstrow 

*Defining the dataset as a panel data set*
xtset ID Year_ID, yearly


*Summary stats
asdoc  summarize ln_Z_score CCAR Bank_Size NPL Net_Liquidity Inflation, replace

asdoc xtsum ln_Z_score CCAR Bank_Size NPL Net_Liquidity Inflation, replace

*Correlation table
asdoc pwcorr ln_Z_score CCAR Bank_Size NPL Net_Liquidity Inflation, star(0.05) replace

*Testing for normality of data using Shapiro-Wilk test*
asdoc swilk ln_Z_score CCAR Bank_Size NPL Net_Liquidity Inflation, replace  


/****************************************
       POOLED OLS REGRESSION
****************************************/

*Conducting a pooled ols regression of the dataset excluding the policy dummy*
regress ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A 


/****************************************
       TEST FOR MULTICOLLINEARITY
****************************************/

*Conducting a test for Multicollinerity with VIF test*
asdoc estat vif, replace
/* Interpretation of VIF test
 VIF < 10 then multicollinearity does not exists*/

 
 
/****************************************
       TEST FOR AUTOCORRELATION
****************************************/

*Coducting a test for Autocorrelation with Wooldridge test in Panel data*
xtserial ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A 

/* Interpretation of Wooldbridge test
H0: There exists no autocorrelaiton
H1: There exists autocorrelation*/

/****************************************
       FIXED EFFECTS MODEL REGRESSION
****************************************/

*Conducting a Fixed effects model regression*
xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A , fe

*saving the regression results*
estimates store fixed

/****************************************
   TEST FOR CROSS SECTIONAL DEPENDENCE
****************************************/

*Conducting test for Cross-sectional Independence of panel data*
asdoc xtcsd, frees, replace

/* Interpretation of test for cross-sectional independence
H0: Existance of cross-sectional independence
H1: Existance of Cross-sectional dependence*/

/****************************************
       RANDOM EFFECTS MODEL REGRESSION
****************************************/

*Conducting a Random effects model regression*
xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A , re

*saving the regression results*
estimates store random


/****************************************
       WHICH MODELS TO CHOOSE??
****************************************/


/*For Pooled Vs Fixed effects model just see the F test result at the end of the fixed effects regression
Interpretation
H0: Use pooled model
H1: Use Fixed Effects model*/

*Conduct Breusch and Pagan Lagrangian multiplier test to choose between random effects model and pooled regresion*
xttest0

/* Interpretation of Breusch and Pagan Lagrangian multiplier test
H0: Use the pooled OLS model
H1: Use the random effects model*/

*Conducting a Hausman test to choose between fixed and random effects model*
hausman fixed random, sigmamore

*Use sigmamore if the chi2 value is in negative*
*hausman fixed random, sigmamore

/* Interpretation of Hausman test
H0: Use the random effects model
H1: Use the fixed effects model*/


/***********************************************************
 RANDOM EFFECTS MODEL IS SUGGESTED FROM THE VARIOUS MODELS
***********************************************************/

*Conducting the random effects model*
xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A, re 
xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A, re robust


/**********************************
Graph for heteroscedasticity
***********************************/
xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A, re
predict res, e
predict fitted, xb
twoway (scatter res fitted), yline(0)

/****************************************
       TEST FOR HETEROSCEDASTICITY
****************************************/

*Conducting the test for heteroscedasticity in random effects model*
xtreghet ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A, ///
 id(ID) it(Year_ID)model(xtmlh) mhet(CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A) diag lmhet
*A lot of result is shown and it takes about 4 minutes to generate result
*But only required to look at the wald test generated as the end



/************************************************
      GENERATING A NESTED REGRESSION TABLE
*************************************************/

/*Nested regression table
Model1 = Pooled Model
Model2 = Fized Effects Model
Model3 = Random Effects Model
Model4 = Random Effects Model Robust Standard Error
*/

asdoc reg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A, nested replace dec(4) cnames(Model 1) title(Regression Analysis)
asdoc xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A , nested fe append dec(4) cnames(Model 2)
asdoc xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A , nested re append dec(4) cnames(Model 3)
asdoc xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation Covid CCAR_M_A, nested re robust append dec(4) cnames(Model 4)



/*************************
     NORMALITY PLOT
**************************/

*Plotting Histograms of all the variables Dummies excluded*
histogram NPL, normal graphregion(color(white)) yscale(off) xtitle(Non Performing Loan)
histogram Bank_Size, normal graphregion(color(white)) yscale(off) xtitle(Bank Size)
histogram Net_Liquidity, normal graphregion(color(white)) yscale(off) xtitle(Net Liquidity)
histogram CCAR, normal graphregion(color(white)) yscale(off) xtitle(Core Capital Adequacy Ratio)
histogram Inflation, normal graphregion(color(white)) yscale(off) xtitle(Inflation)
histogram ln_Z_score, normal graphregion(color(white)) yscale(off) xtitle("Z-Score(Financial Stability)")

*Code for combination of multiple histogram plots into a single combied graph*
graph combine "C:\Users\lenovo\Desktop\Research\data\figures\normality\Bank_Size_normal.gph" 
"C:\Users\lenovo\Desktop\Research\data\figures\normality\CCAR_normal.gph" 
"C:\Users\lenovo\Desktop\Research\data\figures\normality\Inflation_normal.gph" 
"C:\Users\lenovo\Desktop\Research\data\figures\normality\ln_Z_score_normal.gph" 
"C:\Users\lenovo\Desktop\Research\data\figures\normality\Net_Liquidity_normal.gph" 
"C:\Users\lenovo\Desktop\Research\data\figures\normality\NPL_normal.gph", graphregion(color(white)) title("Distribution of Varaibles")



/************************************************
     PLOTTING GRAPH FOR DISCUSSION SECTION
*************************************************/
*Defining the dataset as a panel data set*
xtset ID Y, yearly

*Plotting a combined line figure for all the ID of CCAR*
xtline CCAR, overlay ytitle("Core Capital Adequacy Ratio") xtitle("Year") legend(off) graphregion(color(white)) ///
 title("Year on Year CCAR") caption("Data Source: Key Performance Indicators, NRB") ///
 xline(2016, lpattern(dash)) yline(0.06, lpattern(bold))

*Plotting a combined line figure for all the ID of ln(Z score)*
xtline ln_Z_score, overlay ytitle("ln(Z score)") xtitle("Year") legend(off) graphregion(color(white)) ///
 title("Year on Year Financial Stability") caption("Source: Author's own Calculations") ///
 xline(2016, lpattern(dash)) 











*************************MIGHT NOT BE REQUIRED FROM NOW ON*****************************






/*******************************************************************************************
       CONDUCTING A FGLS REGRESSION TO ACCOUNT FOR AUTOCORRELATION AND HETEROSCEDASTICITY
********************************************************************************************/

*Defining the dataset as a panel data set is necessary before running FGLS*
xtset ID Year_ID, yearly

*To run the FGLS model free from heteroscedastacidity and autocorrelation for Random Effects
xtgls ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A





/************************************************
      GENERATING A NESTED REGRESSION TABLE
*************************************************/

/*Nested regression table
Model1 = Pooled Model
Model2 = Fized Effects Model
Model3 = Random Effects Model
Model4 = FGLS Model
*/

asdoc reg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A, nested replace dec(2) cnames(Model1) title(Regression Analysis)
asdoc xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A , nested fe append dec(2) cnames(Model2)
asdoc xtreg ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A , nested re append dec(2) cnames(Model3)
asdoc xtgls ln_Z_score CCAR_POLICY CCAR Bank_Size NPL Net_Liquidity Inflation ln_GDP Covid CCAR_M_A, nested append dec(2) cnames(Model4)
