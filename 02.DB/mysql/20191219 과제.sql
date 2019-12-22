select  count(e1.employee_id)
from employees e1
where e1.employee_id not in 
(select distinct manager_id from employees 
where manager_id is not null);