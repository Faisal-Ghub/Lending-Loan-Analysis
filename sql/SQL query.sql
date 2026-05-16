CREATE TABLE loan_data (
    id BIGINT,
    year INT,
    issue_d TEXT,
    final_d TEXT,
    emp_length_int NUMERIC,
    home_ownership TEXT,
    home_ownership_cat INT,
    income_category TEXT,
    annual_inc NUMERIC,
    income_cat INT,
    loan_amount NUMERIC,
    term TEXT,
    term_cat INT,
    application_type TEXT,
    application_type_cat INT,
    purpose TEXT,
    purpose_cat INT,
    interest_payments TEXT,
    interest_payment_cat INT,
    loan_condition TEXT,
    loan_condition_cat INT,
    interest_rate NUMERIC,
    grade TEXT,
    grade_cat INT,
    dti NUMERIC,
    total_pymnt NUMERIC,
    total_rec_prncp NUMERIC,
    recoveries NUMERIC,
    installment NUMERIC,
    region TEXT
);

-- Dataset first view
select * from loan_data
limit 8

--Total count of rows
SELECT COUNT(*) FROM loan_data

-- Distinct year
select distinct year from loan_data
order by year

-- List all unique values for key categorical variables like home_ownership, loan_condition, and purpose.

select home_ownership, count(*)
from loan_data
group by home_ownership
order by count(*) desc

select loan_condition , count(*) 
from loan_data
group by loan_condition 
order by count(*) desc

select purpose, count(*)
from loan_data
group by purpose
order by count(*) desc

-- Identify missing or null values 
--Identify missing or null values in critical columns (loan_amount, interest_rate, annual_inc, loan_condition, purpose).


SELECT
COUNT(*) FILTER (WHERE loan_amount IS NULL) AS loan_amount_nulls,
COUNT(*) FILTER (WHERE interest_rate IS NULL) AS interest_rate_nulls,
COUNT(*) FILTER (WHERE annual_inc IS NULL) AS annual_inc_nulls,
COUNT(*) FILTER (WHERE loan_condition IS NULL) AS loan_condition_nulls,
COUNT(*) FILTER (WHERE purpose IS NULL) AS purpose_nulls
FROM loan_data;


--Check duplicated rows
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY t.*) AS rn
    FROM loan_data t
) s
WHERE rn > 1;

--Standardize categorical values
update loan_data
set region = upper(region)

--Create a new column profitability that measures the difference between total_pymnt and loan_amount.
ALTER TABLE loan_data
ADD COLUMN profitability numeric;

UPDATE loan_data
SET profitability = total_pymnt - loan_amount;

-- Create a new column risk_flag
alter table loan_data
add column risk_flag int

UPDATE loan_data
SET risk_flag = case 
                when loan_condition = 'Bad Loan' 
				then 1 else 0
				end
--Create a new table called as lones_cleaned
CREATE TABLE loans_cleaned AS
SELECT *
FROM loan_data
WHERE id IS NOT NULL
  AND year IS NOT NULL
  AND issue_d IS NOT NULL
  AND final_d IS NOT NULL
  AND emp_length_int IS NOT NULL
  AND home_ownership IS NOT NULL
  AND annual_inc IS NOT NULL
  AND loan_amount IS NOT NULL
  AND term IS NOT NULL
  AND application_type IS NOT NULL
  AND purpose IS NOT NULL
  AND interest_rate IS NOT NULL
  AND grade IS NOT NULL
  AND dti IS NOT NULL
  AND total_pymnt IS NOT NULL
  AND total_rec_prncp IS NOT NULL
  AND recoveries IS NOT NULL
  AND installment IS NOT NULL
  AND region IS NOT NULL
  AND profitability IS NOT NULL
  AND risk_flag IS NOT NULL;


-- Create new column loan term

ALTER TABLE loans_cleaned
ADD COLUMN loan_term INT

UPDATE loans_cleaned
set loan_term = substring(term from 1 for 3)::INT


select * from loans_cleaned

--Create new column named as income_to_loan_ratio

alter table loans_cleaned
add column income_to_loan_ratio numeric

update loans_cleaned
set income_to_loan_ratio = round(annual_inc / loan_amount,2)


--Export clean data
COPY loans_cleaned
TO 'C:/Users/Acer/Desktop/Week 5/loan_cleaned.csv'
WITH (FORMAT CSV, HEADER);

