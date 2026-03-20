-- ================================================
-- Telco Customer Churn Analysis - SQL Queries
-- Database: churn_db
-- Tool: PostgreSQL
-- ================================================


-- Query 1: Overall Churn Rate
SELECT 
    COUNT(*) AS total_customers,
    SUM(Churn) AS total_churned,
    ROUND(100.0 * SUM(Churn) / COUNT(*), 2) AS churn_rate_pct
FROM telco_churn;


-- Query 2: Churn Rate by Contract Type
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned,
    ROUND((100.0 * SUM(Churn) / COUNT(*))::NUMERIC, 2) AS churn_rate_pct
FROM telco_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- Query 3: Revenue Lost to Churn by Internet Service
SELECT 
    InternetService,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned,
    ROUND(SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END)::NUMERIC, 2) AS revenue_lost,
    ROUND((100.0 * SUM(Churn) / COUNT(*))::NUMERIC, 2) AS churn_rate_pct
FROM telco_churn
GROUP BY InternetService
ORDER BY revenue_lost DESC;


-- Query 4: Churn Rate by Payment Method
SELECT 
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned,
    ROUND((100.0 * SUM(Churn) / COUNT(*))::NUMERIC, 2) AS churn_rate_pct
FROM telco_churn
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;


-- Query 5: Churn Rate by Tenure Group
SELECT 
    tenure_group,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned,
    ROUND((100.0 * SUM(Churn) / COUNT(*))::NUMERIC, 2) AS churn_rate_pct
FROM telco_churn
GROUP BY tenure_group
ORDER BY churn_rate_pct DESC;


-- Query 6: Average Charges and Tenure - Churned vs Retained
SELECT 
    CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Retained' END AS customer_status,
    COUNT(*) AS total_customers,
    ROUND(AVG(MonthlyCharges)::NUMERIC, 2) AS avg_monthly_charges,
    ROUND(AVG(TotalCharges)::NUMERIC, 2) AS avg_total_charges,
    ROUND(AVG(tenure)::NUMERIC, 1) AS avg_tenure_months
FROM telco_churn
GROUP BY Churn
ORDER BY Churn DESC;


-- Query 7: Top 10 High Value Customers Lost
SELECT 
    customerID,
    Contract,
    PaymentMethod,
    MonthlyCharges,
    tenure,
    tenure_group
FROM telco_churn
WHERE Churn = 1 
    AND MonthlyCharges > 70 
    AND Contract = 'Month-to-month'
ORDER BY MonthlyCharges DESC
LIMIT 10;


-- Query 8: Window Function - Rank Customers by Spend Within Churn Segment
SELECT 
    customerID,
    MonthlyCharges,
    tenure,
    Contract,
    CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Retained' END AS customer_status,
    RANK() OVER (
        PARTITION BY Churn 
        ORDER BY MonthlyCharges DESC
    ) AS spend_rank
FROM telco_churn
ORDER BY Churn DESC, spend_rank
LIMIT 20;