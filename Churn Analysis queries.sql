--  totals summary  for kpi  -- 

select count(distinct User_ID) as total_users 
from Customer_Subscription ;

select count(*) 
from Customer_Subscription 
where  Churn = 'yes' ;

select count(*) 
from Customer_Subscription 
where  Churn = 'no' ;

select count(*) , 
round(sum(case when Churn = "Yes" then 1 else 0 end) * 100.00 /  count(*) , 2 )as churned_rate , 
round(sum(case when Churn = "no" then 1 else 0 end) * 100.00 /  count(*) , 2 )as retained_rate 
from Customer_Subscription ;

-- churn by month, year -- 

select Signup_year, count(*) , 
sum(case when Churn = "Yes" then 1 else 0 end) as churned_users, 
sum(case when Churn = "No" then 1 else 0 end) as retained_users,
round(sum(case when Churn = "No" then 1 else 0 end) * 100.00 / count(*), 2) as churned_rate
from Customer_Subscription 
group by Signup_year ;

select Signup_year,  Signup_month_num, Signup_month,count(*) 
from Customer_Subscription 
where  Churn = 'yes' 
group by Signup_year,Signup_month_num,Signup_month 
ORDER BY Signup_year,Signup_month_num,Signup_month   asc ;

-- 2 churn based on plan type --

select Plan_type , count(Churn) ,
sum(case when Churn ="Yes"  then 1 else 0 end) as churned,
sum(case when churn = "No" then 1 else 0 end) as non_chunred,
round(sum(case when Churn ="Yes"  then 1 else 0 end) * 100.00 /count(*) ,2) as churned_rate , 
round(sum(case when churn = "No" then 1 else 0 end) * 100.00 / count(*) ,2) as non_churend_rate
from Customer_Subscription 
group by Plan_type 
order by count(Churn) desc ;


-- tenure months vs churn , is there a relation ?-- 
 
 select Tenure_months , count(*) as total_users, 
sum(case when Churn ="Yes"  then 1 else 0 end) as churned_users,
sum(case when churn = "No" then 1 else 0 end) as non_churned_users,
round(sum(case when Churn ="Yes"  then 1 else 0 end) * 100.00 /count(*) ,2) as churned_rate , 
round(sum(case when churn = "No" then 1 else 0 end) * 100.00 / count(*) ,2) as non_churend_rate
from Customer_Subscription 
group by Tenure_months 
 order by  Tenure_months asc;   -- no -- 

-- Any relation between payment failures and churn  -- 

 select payment_failures , count(*) as total_users, 
sum(case when Churn ="Yes"  then 1 else 0 end) as churned_users,
sum(case when churn = "No" then 1 else 0 end) as non_churned_users, 
round(sum(case when Churn ="Yes"  then 1 else 0 end) * 100.00 /count(*) ,2) as churned_rate , 
round(sum(case when churn = "No" then 1 else 0 end) * 100.00 / count(*) ,2) as non_churend_rate
from Customer_Subscription 
group by payment_failures 
 order by  payment_failures asc; 
 

-- Any relation between support tickets  and churn --

select  Support_tickets, count(*) as total_users, 
sum(case when Churn ="Yes"  then 1 else 0 end) as churned_users,
sum(case when churn = "No" then 1 else 0 end) as non_churned_users,
round(sum(case when Churn ="Yes"  then 1 else 0 end) * 100.00 /count(*) ,2) as churned_rate , 
round(sum(case when churn = "No" then 1 else 0 end) * 100.00 / count(*) ,2) as non_churend_rate
from Customer_Subscription 
group by Support_tickets
 order by  Support_tickets asc;


-- does users who havnet logined in for long time turning churn ?  -- 

select Last_login_days_ago, count(*) as total_users, 
sum(case when Churn ="Yes"  then 1 else 0 end) as churned_users,
sum(case when churn = "No" then 1 else 0 end) as non_churned_users,
round(sum(case when Churn ="Yes"  then 1 else 0 end) * 100.00 /count(*) , 2) as churned_rate,
round(sum(case when churn = "No" then 1 else 0 end) * 100.00 / count(*), 2) as non_chunred_rate
from Customer_Subscription 
group by Last_login_days_ago
 order by  Last_login_days_ago asc;  
 
-- login data as a buckets -- 
 
 with login_recency as (
 select  Last_login_days_ago , churn , 
 case 
 when Last_login_days_ago <= 7 then "Active (0-7 days)"
 when Last_login_days_ago between 8 and 14 then "Recent (8-14 days)"
 when Last_login_days_ago between 15 and 30 then "Fading (15- 30 days)" 
 when Last_login_days_ago between 31 and 45 then "At risk (31- 45 days)" 
 else  "Dormant (45+ days)" 
 end as login_tiers
 from  Customer_Subscription 
 ) 
 select login_tiers, count(*) ,  
 sum(case when Churn = "Yes" then 1 else 0 end)  as churned ,
  sum(case when Churn = "no" then 1 else 0 end)  as not_churned
 from login_recency 
 group by login_tiers
 order by count(*) desc ;


  
-- does avg usgae hours influence churn -- 

select  Avg_weekly_usage_hours, count(Churn), 
sum(case when Plan_type = "Basic"  then 1 else 0 end) as basic_users,
sum(case when Plan_type = "Standard" then 1 else 0 end) as Standard_users,
sum(case when Plan_type = "Premium" then 1 else 0 end) as Premium_users
from Customer_Subscription 
group  by Avg_weekly_usage_hours 
order by Avg_weekly_usage_hours ;


-- AVG weekly hours in a bucket -- 

with avg_usage as (
select  Avg_weekly_usage_hours, churn ,
case 
when Avg_weekly_usage_hours > 20 then "High Usage (above 20 hrs)" 
when Avg_weekly_usage_hours between 10 and  20 then "good enough (10 - 20 hrs)" 
when Avg_weekly_usage_hours between 2 and  10 then  "lite Usage( 2- 10hrs)" else 
"low usage (less than 2 hrs)"
end as usage_tier
from Customer_Subscription 
order by Avg_weekly_usage_hours 
)
select  usage_tier , count(*) , 
sum(case when churn = "yes" then 1 else 0 end) as churned ,
sum(case when churn = "No" then 1 else 0 end) as non_churned , 
round(sum(case when churn = "yes" then 1 else 0 end) * 100.00 / count(*) , 2) as chunred_rate
from avg_usage
group by  usage_tier 
order by count(*) desc ;

-- validating if the all the factors togther confirm there is a pattern? -- 

with churn_factors as (
select User_ID, Churn 
from  Customer_Subscription
where  Support_tickets >= 4  and
       Payment_failures >= 2 and 
       Last_login_days_ago >= 20  and 
       Avg_weekly_usage_hours between 0 AND 10
   )    
	select  count(User_ID) ,  
    sum(case when churn = "yes" then 1 else 0 end) as churned ,
    sum(case when churn = "No" then 1 else 0 end) as non_churned ,
      round( sum(case when churn = "yes" then 1 else 0 end) * 100.00 / count(User_ID) , 2 ) As churned_rate
       from churn_factors
        ;
       
       
       -----
      -- Validating with plan types --
      
       with churn_factors as (
select User_ID, Churn, Plan_type
from  Customer_Subscription
where  Support_tickets >= 4  and
       Payment_failures >= 2 and 
       Last_login_days_ago >= 20  and 
       Avg_weekly_usage_hours between 0 AND 10
   )    
	select   Plan_type , count(User_ID) , 
    sum(case when churn = "yes" then 1 else 0 end) as churned ,
    sum(case when churn = "No" then 1 else 0 end) as non_churned ,
      round( sum(case when churn = "yes" then 1 else 0 end) * 100.00 / count(User_ID) , 2 ) As churned_rate
       from churn_factors
       group by Plan_type
        ;       
       
       ------
       -- High risk customers --
         with churn_factors as (
select User_ID, Plan_type, Support_tickets , Payment_failures , Last_login_days_ago ,     Avg_weekly_usage_hours
from  Customer_Subscription
where  Support_tickets >= 4  and
       Payment_failures >= 2 and 
       Last_login_days_ago >= 20  and 
       Avg_weekly_usage_hours between 0 AND 10
   )    
	select    User_ID  , Plan_type , 
  Support_tickets , Payment_failures , Last_login_days_ago ,     Avg_weekly_usage_hours
       from churn_factors ;
	
      ---- avg usage comparision for churned and retained -- 
       
       select  
       round(avg(case when Churn = "Yes" then  Avg_weekly_usage_hours end) ,2 ) as churned_usage ,
       round(avg(case when Churn = "No" then  Avg_weekly_usage_hours end) , 2 )as retained_usage
       from Customer_Subscription ;
       -----------
     