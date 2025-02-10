/* Stata Code for Data Cleaning, Exploration, and Econometric Analysis */


/* Step 1: Load Data */
clear all
set more off

use "/Users/uli/Documents/Stata/Project/Data/micro_idn.dta", clear
summarize


/* Step 2: Keep Only Relevant Columns */
keep female age educ inc_q emp_in urbanicity_f2f /* Demographic Variables: */ account_fin account_mob fin5 fin7 fin8 fin8a fin8b fin13c fin20 fin22a fin22b fin22c borrowed fin24 fin24a /* Financial Access & Usage */ mobileowner internetaccess anydigpayment merchantpay_dig /* Technology & Digital Finance */


/* Step 3: Data Cleaning - Renaming Columns */
rename female gender /* 1:female, 3:male */
rename educ education_level 
rename inc_q income_quintile 
rename emp_in employment_status 
rename urbanicity_f2f rural_residence 
rename fin5 mobile_access_account 
rename fin7 has_credit_card 
rename fin8 used_credit_card
rename fin8a used_credit_card_instore
rename fin8b paid_credit_card_full
rename fin13c borrowed_mobile_money
rename fin20 borrowed_medical_purpose
rename fin22a borrowed_financial_institution
rename fin22b borrowed_family_friends
rename fin22c borrowed_savings_club
rename fin24 main_source_emergency_funds 
rename fin24a difficulty_emergency_funds /*in 30 days*/
rename mobileowner owns_mobile_phone
rename internetaccess internet_access
rename anydigpayment made_digital_payment
rename merchantpay_dig digital_merchant_payment

/* Save new dataset */
save "borrow_behavior_clean.dta", replace


/* Step 4: Summary Statistics */
summarize


/* Step 5: Check missing values */
misstable summarize


/* Step 6: Handle Missing Values */
// replace borrowed = 0 if missing(borrowed)
foreach var of varlist gender age education_level income_quintile employment_status rural_residence account_fin account_mob mobile_access_account has_credit_card used_credit_card used_credit_card_instore paid_credit_card_full borrowed_mobile_money borrowed_medical_purpose borrowed_financial_institution borrowed_family_friends borrowed_savings_club owns_mobile_phone internet_access made_digital_payment digital_merchant_payment {
    capture confirm numeric variable `var'
    if _rc == 0 {
        replace `var' = . if `var' == -999   // Handle missing values coded as -999
    }
    else {
        replace `var' = "" if `var' == " "   // Handle missing values for string variables
    }
}

/* Step 7: Generate Key Variables */
* Create a binary variable for borrowing (1 if borrowed from any source, 0 otherwise)
gen borrowed_binary = (borrowed_financial_institution == 1 | borrowed_family_friends == 1 | borrowed_savings_club == 1 | borrowed_mobile_money == 1)


/* Step 8: Exploratory Data Analysis */
tabulate owns_mobile_phone borrowed_binary, chi2
tabulate borrowed_binary internet_access, chi2
tabstat borrowed owns_mobile_phone internet_access, statistics(mean sd)

graph bar (mean) borrowed_binary, over(owns_mobile_phone) title("Borrowing Rate by Mobile Ownership")
graph bar (mean) borrowed_binary, over(internet_access) title("Borrowing Rate by Internet Access")

/* Step 9: Correlation Matrix */
pwcorr borrowed_binary owns_mobile_phone internet_access, sig

* Correlation matrix
correlate owns_mobile_phone internet_access account_mob

/* Step 10: OLS Regression: Borrowing behavior as a function of mobile phone ownership and internet access */
reg borrowed_binary owns_mobile_phone internet_access education_level income_quintile employment_status rural_residence

/* Bar Chart for Coefficients with Confidence Intervals */

// Store regression results
matrix b = e(b)'        // Extract coefficients
matrix V = e(V)         // Extract variance-covariance matrix

// Extract variances as a column vector
matrix diagV = vecdiag(V)'  // Transpose to column vector

// Compute standard errors correctly
matrix se = J(rowsof(diagV), 1, .)  // Initialize se matrix
forvalues i = 1/`=rowsof(diagV)' {
    matrix se[`i',1] = sqrt(diagV[`i',1])  // Compute square root manually
}

// Compute confidence intervals (95%)
matrix ci_lower = b - 1.96 * se
matrix ci_upper = b + 1.96 * se

// Convert matrices into a dataset
//clear
svmat b, name(coeff)
svmat ci_lower, name(ci_l)
svmat ci_upper, name(ci_u)

// Generate variable names dynamically
gen varname = ""
local names "Owns Mobile Phone Internet Access Age Education Level Income Quintile Employment Status Rural Residence"

// Assign variable names dynamically
local i = 1
foreach name in `names' {
    replace varname = "`name'" if _n == `i'
    local ++i
}

// Drop constant term (_cons) if included
drop if varname == ""

// Sort data by coefficients (optional)
gsort coeff

// Create numeric index for plotting
gen varindex = _n  

// Bar chart with error bars
twoway (bar coeff varindex, color(blue)) ///
       (rcap ci_l ci_u varindex) ///
       , xlabel(1/`=_N', valuelabel angle(45)) ///
       xtitle("Predictor Variables") ytitle("Coefficient Estimate") ///
       title("Bar Chart of Coefficients with 95% Confidence Intervals") ///
       legend(off)

graph export coef_plot.png, replace

	   
/* Step 11: Logistic Regression: Probability of borrowing */
logit borrowed_binary owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence

/*  
ROC Curve (Receiver Operating Characteristic Curve) : evaluates the model's classification performance,
to plots the True Positive Rate (Sensitivity) against the False Positive Rate (1 - Specificity).
*/

* Predict probabilities
predict pred_probs

* Generate ROC Curve: 
roctab borrowed pred_probs, graph

* Alternative command for a smoother ROC curve
lroc, title("ROC Curve for Logistic Regression Model")

/* Odds Ratio Plot: visualizes the effect size of each predictor in the logistic regression model. */
* Run Logistic Regression again to store results
logit borrowed_binary owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence


//ssc install coefplot

* Create an odds ratio plot
coefplot, ///
    drop(_cons) ///
    xlabel(, angle(45)) ///
    title("Odds Ratios with 95% Confidence Intervals") ///
    xline(1, lcolor(red)) ///
    ytitle("Predictors") ///
    mcolor(blue) msymbol(O) ///
    ciopts(lcolor(black))

	
/* Step 12: OLS Regression Model */
reg borrowed main_source_emergency_funds difficulty_emergency_funds owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence


/* Step 13: Logistic Regression Model */
logit borrowed main_source_emergency_funds difficulty_emergency_funds owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence

/*  
ROC Curve (Receiver Operating Characteristic Curve) : evaluates the model's classification performance,
to plots the True Positive Rate (Sensitivity) against the False Positive Rate (1 - Specificity).
*/

* Predict probabilities
predict pred_probs_em

* Generate ROC Curve: 
roctab borrowed pred_probs_em, graph

* Alternative command for a smoother ROC curve
lroc, title("ROC Curve for Logistic Regression Model")

/* Odds Ratio Plot: visualizes the effect size of each predictor in the logistic regression model. */
* Run Logistic Regression again to store results
logit borrowed main_source_emergency_funds difficulty_emergency_funds owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence

//ssc install coefplot

* Create an odds ratio plot
coefplot, ///
    drop(_cons) ///
    xlabel(, angle(45)) ///
    title("Odds Ratios with 95% Confidence Intervals") ///
    xline(1, lcolor(red)) ///
    ytitle("Predictors") ///
    mcolor(blue) msymbol(O) ///
    ciopts(lcolor(black))
	
	
/* Step 14: Instrumental Variable Regression (IV) */
* Assuming 4G network availability as an instrument for mobile phone ownership
generate network_4G_Cov = (owns_mobile_phone == 1 & internet_access == 1)
// Check instrument validity:
correlate owns_mobile_phone network_4G_Cov

//regress owns_mobile_phone network_4G_Cov internet_access age education_level income_quintile employment_status rural_residence

ivregress 2sls borrowed_binary (owns_mobile_phone = network_4G_Cov) internet_access age education_level income_quintile employment_status rural_residence

/* Scatter Plot with Fitted Regression Line */
	   
twoway (scatter borrowed_binary owns_mobile_phone, mcolor(blue) msymbol(O)) ///
       (lfitci borrowed_binary owns_mobile_phone, lcolor(red%50) fintensity(50)), ///
       title("Instrumented Mobile Phone Ownership vs Borrowing Behavior") ///
       xtitle("Instrumented Mobile Phone Ownership") ///
       ytitle("Borrowing Behavior (Binary)") ///
       legend(order(1 "Observed Data" 2 "Fitted Regression Line with CI"))
	   
/* Use jitter to reduce overplotting (useful for binary variables) */
twoway (scatter borrowed_binary owns_mobile_phone, jitter(2) mcolor(blue) msymbol(O)) ///
       (lfit borrowed_binary owns_mobile_phone, lcolor(red) lwidth(medium)), ///
       title("Instrumented Mobile Phone Ownership vs Borrowing Behavior") ///
       xtitle("Instrumented Mobile Phone Ownership") ///
       ytitle("Borrowing Behavior (Binary)") ///
       legend(order(1 "Observed Data" 2 "Fitted Regression Line"))


/* Step 15: Endogeneity using IV Regression */
* Checking if mobile phone ownership is endogenous
estat endogenous

/* Perform IV Regression and Save Residuals */
* IV Regression: Using 4G network availability as an instrument
ivregress 2sls borrowed_binary (owns_mobile_phone = network_4G_Cov) ///
          internet_access age education_level income_quintile ///
          employment_status rural_residence

* Generate residuals from the IV regression
predict iv_residuals, resid

/* Plot Histogram of Residuals */
* Histogram of IV regression residuals
histogram iv_residuals, normal ///
    title("Histogram of Residuals from IV Regression") ///
    xtitle("Residuals") ytitle("Frequency") ///
    color(blue%60) width(0.1)

/* (a) Overlay Kernel Density for Smoothness */
histogram iv_residuals, normal kdensity ///
    title("Histogram of Residuals from IV Regression") ///
    xtitle("Residuals") ytitle("Frequency") ///
    color(blue%60) width(0.1) ///
    legend(order(2 "Kernel Density" 3 "Normal Distribution"))

/* (b) Perform Skewness and Kurtosis Tests for Normality */
sktest iv_residuals

/* (c) Q-Q Plot for Residuals */
qnorm iv_residuals

/* Step 16: Overall Conclusions Visualization */

/* 1. Coefficient Plot with Confidence Intervals (All Models) */
* Install coefplot if not already installed
* ssc install coefplot

* Run OLS regression
reg borrowed_binary owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence

estimates store ols_model

* Run logistic regression
logit borrowed_binary owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence

estimates store logit_model

* Run IV regression
ivregress 2sls borrowed_binary (owns_mobile_phone = network_4G_Cov) ///
          internet_access age education_level income_quintile employment_status rural_residence
		  
estimates store iv_model

* Coefficient plot with confidence intervals
coefplot ols_model logit_model iv_model, ///
    drop(_cons) ///
    xlabel(,angle(45)) ///
    title("Coefficient Plot with 95% Confidence Intervals") ///
    legend(order(1 "OLS" 2 "Logit" 3 "IV Regression"))

/* 2. ROC Curve for Logistic Regression Performance */
* Generate predicted probabilities from logistic regression
logit borrowed_binary owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence

predict logit_pred, pr

* Generate ROC curve
roctab borrowed_binary logit_pred, graph
graph display, title("ROC Curve for Logistic Regression")

	
/* 3. Scatter Plot of Predicted vs. Actual Borrowing Behavior */
* Generate predicted values from OLS regression
logit borrowed_binary owns_mobile_phone internet_access age education_level income_quintile employment_status rural_residence

predict ols_pred

* Scatter plot of actual vs predicted borrowing behavior
scatter borrowed_binary ols_pred, ///
    mcolor(blue) msize(small) ///
    title("Scatter Plot: Predicted vs Actual Borrowing") ///
    xlabel(0(0.2)1) ylabel(0(0.2)1) ///
    xline(0.5, lcolor(red)) yline(0.5, lcolor(red)) ///
    legend(off)

