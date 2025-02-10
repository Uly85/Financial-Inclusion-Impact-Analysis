# Project Name: Financial-Inclusion-Impact-Analysis
## Case Study: The Impact of Mobile Phone Usage on Borrowing Behavior and Indebtedness in Indonesia

## Overview

This study uses survey data to investigate the impact of mobile phone usage on borrowing behavior and indebtedness among individuals in Indonesia.
The study will utilize individual-level survey data incorporating demographic, financial access, and technology-related variables. 

Research Objectives
•	To analyze the relationship between mobile phone ownership and borrowing behavior.

•	To examine the role of digital financial services in shaping borrowing patterns.

•	To assess how much mobile phone usage influences financial decision-making and indebtedness.

•	To explore demographic differences in financial behavior related to mobile technology adoption.

## Data

The data is sourced from the Global Financial Inclusion (Global Findex) Database 2021 - WorlBank.

After cleaning, I performed the following steps:

1. Checked for missing values and handled them.
2. Converted variables to the appropriate format.
3. Generated new variables to assist in analysis.


## Analysis

1. Descriptive Analysis: Summarize borrowing behavior, indebtedness, and mobile phone usage trends by demographic groups.
2. Regression Analysis: Use logistic and linear regression models to identify the impact of mobile phone usage on borrowing behavior and indebtedness, controlling for demographic and economic factors.
3. Instrumental Variable Approach: To address endogeneity concerns, leverage exogenous variations in mobile phone access (e.g., network coverage expansions).
3. Robustness Checks: Conduct sensitivity analysis, alternative model specifications, and sub-group analyses.

## Expected Contributions
1. Provide empirical evidence on the link between mobile technology adoption and borrowing behavior in Indonesia.
2. Inform policymakers and financial institutions about potential risks associated with digital financial inclusion.
3. Contribute to the broader literature on financial access, digital finance, and economic well-being in developing economies.

## Code

The Stata code used for cleaning, analyzing, and visualizing the data is located in the `/do-files` folder.

## Notes

This project was developed as my effort to demonstrate my ability to use STATA and R for financial data analysis in just a few days, showcasing my research expertise in financial data analysis and regression modeling to investigate the causal impact of mobile banking on Borrowing Behavior and Indebtedness. The primary goal is to address a key challenge in financial inclusion studies: endogeneity bias, where mobile banking adoption may be influenced by unobserved factors such as financial literacy or economic status. To overcome this, the study applies an instrumental variable (IV) approach, leveraging 4G network availability as an exogenous instrument for mobile banking adoption. This method strengthens causal inference, ensuring that the estimated impact reflects a genuine relationship rather than spurious correlations.
