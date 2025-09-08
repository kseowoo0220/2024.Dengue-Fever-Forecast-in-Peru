# Dengue Fever Forecast in Peru - Insights for Public Health Policy

This project applies a **Vector Autoregression (VAR) model** to forecast dengue fever incidence in Peru.  
The goal is to provide policymakers with actionable insights for **targeted interventions** and **resource allocation** in high-risk districts.

## Overview
Dengue fever remains a pressing public health concern in Peru, particularly in outbreak-prone areas.  
This study leverages epidemiological and environmental data to forecast dengue case counts across 53 districts, aiming to guide prevention strategies and optimize healthcare responses.

## Data
- **Observations:** 62,752  
- **Variables:** 12 (year, epidemiological week, dengue cases, environmental factors, etc.)  
- **Time span:** 2001 (week 1) – 2023 (week 36)  
- **Geographic coverage:** 53 districts  
- **Data quality:** No missing values  

## Methods
1. **Preprocessing**
   - Combined year + epidemiological week to establish temporal patterns  
   - Normalized dengue cases using population data → incidence rates  
   - Adjusted for seasonal trends  

2. **Model**
   - Vector Autoregression (VAR) fitted per district  
   - Significance level: 0.05  
   - Forecasts incidence → converted back to case counts  

3. **Evaluation**
   - Root Mean Square Percentage Error (RMSPE)  
   - Excluded zero-case districts for fairness  
   - Adjusted training window to handle anomalies (e.g., Napo district outliers post-2020)  

## Results
- **High-risk districts:** Inahuaya, Alto Nanay, Capelo → consistently predicted hotspots  
- **Model performance:**  
  - Average RMSPE = **1.19** across non-zero districts  
  - Outperforms benchmarks from comparable studies  
- **Visualization:** District-level maps show hotspots in red (high cases) vs yellow (low cases)  

## Key Insights
- Immediate interventions are needed in **high-incidence hotspots** to prevent outbreaks.  
- Districts with low dengue counts should maintain **preventive measures** to sustain progress.  
- Limitations: RMSPE less suitable for zero-case districts; alternative evaluation metrics needed.  
- Future work: Explore **Conditional Auto-Regressive (CAR) models** or **neural networks** for improved forecasting.  

---
