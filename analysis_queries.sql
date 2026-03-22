CREATE database telecom_project ;
use telecom_project;
select * 
from telecom_project.infra_capacity_engineered
limit 10;

select count(*)
from telecom_project.infra_capacity_engineered;
describe telecom_project.infra_capacity_engineered;
#1)A business team wants to know which states have more customers.
SELECT
    state,
    COUNT(*) AS total_customers
FROM telecom_project.infra_capacity_engineered
GROUP BY state
ORDER BY total_customers DESC;

#2)Infrastructure teams want to know which states have higher traffic load.
SELECT
     STATE,
     AVG(TOTAL_TRAFFIC_MINUTES) AS AVG_TRAFFIC
     FROM telecom_project.infra_capacity_engineered
     GROUP BY STATE
     ORDER BY AVG_TRAFFIC DESC;
     
     #3)The company wants to know which states are more expensive.
SELECT
    state,
    AVG(total_cost) AS avg_cost
FROM telecom_project.infra_capacity_engineered
GROUP BY state
ORDER BY avg_cost DESC;

#4)The monitoring team wants to know how many records are Normal, Warning, and Critical.
select
    capacity_risk,
    count(*) As record_count
from telecom_project.infra_capacity_engineered
group by capacity_risk;
 
 #5)We want to know how many rows have Low, Medium, or High incident severity.
 select
      incident_level,
      count(*) record_count
from telecom_project.infra_capacity_engineered
group by incident_level;

#6)Show only states with many customers-We do not want to focus on tiny groups.

select
     state,
     count(*) As total_customers
from telecom_project.infra_capacity_engineered
group by state
having count(*) > 15 ;


#Step 10 — Use a CTE for cleaner SQL
#Sometimes business questions become big and messy, so we want a cleaner way to write SQL.
with State_traffic AS(
      Select
        state,
        avg(total_traffic_minutes) As avg_traffic
        from telecom_project.infra_capacity_engineered
        group by state
)
select
    state,
    avg_traffic
from state_traffic
order By avg_traffic desc;


#Telecom company wants to know:Churn Rate?- Out of total customers in a state- how many left the company
#SQL Query (CTE Style — Very Professional)
with churn_summary as (
     select
     state,
     count(*) As total_customers,
     sum( case when churn = 'true' then 1 Else 0 end) As churn_customers
     from telecom_project.infra_capacity_engineered
     group by state
)
select
    state,
    total_customers,
    churn_customers,
    churn_customers / total_customers As churn_rate
from churn_summary
order by churn_rate desc;

#Question 3 — Capacity Risk Distribution-How many customers/records fall into Normal, Warning, and Critical traffic risk?
 select
    case
    when total_traffic_minutes >= 700 Then 'Critical'
    when total_traffic_minutes >= 550 then 'Warning'
    else 'Normal'
End As capacity_risk,
count(*) As record_count
from telecom_project.infra_capacity_engineered
group by
	case
		when total_traffic_minutes >= 700 then 'Critical'
        when total_traffic_minutes >= 550 then 'Warning'
        Else 'Normal'
	End
order by record_count Desc;

with risk_lables as (
	select
		case
           when total_traffic_minutes >= 700 then 'Critical1'
           when total_traffic_minutes >= 550 then 'Warning1'
           else 'Normal1'
		End as capacity_risk
	from telecom_project.infra_capacity_engineered
)
select
	capacity_risk,
    count(*) as record_count
from risk_lables
group by capacity_risk
order by record_count Desc;

#Question 4 — Top 5 high-traffic states-Which states have the highest total network traffic?
select
    state,
    sum(total_traffic_minutes) As total_state_traffic
from telecom_project.infra_capacity_engineered
group by state
order by  total_state_traffic desc
limit 5;
    
#Next Level Version (CTE + Ranking — More Professional)
with state_traffic As (
	select
		state,
        sum(total_traffic_minutes) As total_state_traffic
	from telecom_project.infra_capacity_engineered
    group by state
)
select
	state,
    total_state_traffic
from state_traffic
order by total_state_traffic Desc
limit 5;

#Business Problem Infrastructure team wants to know:Rank states by total traffic load.

select
	state,
    sum(total_traffic_minutes) As total_state_traffic,
    Rank() over (
			order by sum(total_traffic_minutes) Desc
            ) as traffic_rank
from telecom_project.infra_capacity_engineered
group by state;
		
#Question 6 — High Risk States-Which states have a lot of risky traffic records?

select
	state,
    count(*) as risky_record_count
from telecom_project.infra_capacity_engineered
where capacity_risk in ( 'critical' , 'warning')
group by state
order by risky_record_count desc;

with risky_states as (
	select
		state
	from telecom_project.infra_capacity_engineered
    where capacity_risk In ('Critical' , 'Warning')
)
select
	state,
    count(*) As risky_record_count
from risky_states
group by state
order by risky_record_count desc;

#Question 7 — Cost Efficiency by State-Which states are more expensive for the amount of traffic they handle?

select
	state,
    avg(cost_per_minute) As avg_cost_per_minute
from telecom_project.infra_capacity_engineered
group by state
order by avg_cost_per_minute desc;

with state_cost_efficiency as (
	select
		state,
        avg(cost_per_minute) as avg_cost_per_minute
	from telecom_project.infra_capacity_engineered
    group by state
)
select
	state,
    avg_cost_per_minute
from state_cost_efficiency
order by avg_cost_per_minute desc;

	
    
        
     

    
    


    
    
     



