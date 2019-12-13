[6] 각 이름이 ‘s’로 끝나는 사원들의 이름과 업무를 아래의 예와 같이 출력하고자 한다. 출력 시 성과 이름은 첫 글자가 대문자, 업무는 모두 대문자(UPPER함수 사용)로 출력하고 머리글은 Employee JOBs로 표시하시오.
	□예 Sigal Tobias is a PU_CLERK
SELECT concat(first_name, ' ', last_name, ' is a ', UPPER(job_id)) as 'Employee JOBs.'
FROM employees
#WHERE last_name LIKE '%s';
WHERE substr(last_name, -1, 1) = 's';

[7] 모든 사원의 연봉을 표시하는 보고서를 작성하려고 한다. 보고서에 사원의 성과 이름(Name으로 별칭), 급여, 수당여부에 따른 연봉을 포함하여 출력하시오. 수당여부는 수당이 있으면 “Salary + Commission”, 수당이 없으면 “Salary only”라고 표시하고, 별칭은 적절히 붙인다. 또한 출력 시 연봉이 높은 순으로 정렬한다. 
	- IF, IFNULL
SELECT concat(first_name, ' ', last_name) as 'Name'
	, salary
    , (salary * 12) + (salary * 12 * IFNULL(commission_pct, 0)) as 'Annual Salary'
    , IF(commission_pct IS NOT NULL, 'Salary + Commission', 'Salary Only') as 'Salary Type'
FROM employees
ORDER BY salary DESC;

[8] 모든 사원들 성과 이름(Name으로 별칭), 입사일 그리고 입사일이 어떤 요일이였는지 출력하시오. 이때 주(week)의 시작인 일요일부터 출력되도록 정렬하시오.
	- DATE_FORMAT()
SELECT concat(first_name, ' ', last_name) as 'Name'
	, hire_date
	, DATE_FORMAT(hire_date, '%W') as 'Day of the week'
FROM employees
ORDER BY DATE_FORMAT(hire_date, '%w');

SELECT DATE_FORMAT(hire_date, '%W') as 'Day of the week'
	, COUNT(DATE_FORMAT(hire_date, '%W')) AS 'COUNt'
FROM employees
GROUP BY 1;
	
[9] 모든 사원은 직속 상사 및 직속 직원을 갖는다. 단, 최상위 또는 최하위 직원은 직속상사 및 직원이 없다. 소속된 사원들 중 어떤 사원의 상사로 근무 중인 사원의 총 수를 출력하시오.
select count(distinct manager_id)
from employees;

[10] 각 사원이 소속된 부서별로 급여 합계, 급여 평균, 급여 최대값, 급여 최소값을 집계하고자 한다. 계산된 출력값은 6자리와 세 자리 구분기호, $ 표시와 함께 출력하고 부서번호의 오름차순 정렬하시오. 단, 부서에 소속되지 않은 사원에 대한 정보는 제외하고 출력시 머리글은 별칭(alias) 처리하시오.
	- GROUP BY, SUM(), AVG(), MAX(), MIN()
	- FORMAT(값, 소수점 표현자리수)
select department_id
	, count(department_id) as 'COUNT'
	, concat('$', FORMAT(sum(salary), 0)) as 'Sum Salary'
    , concat('$', FORMAT(avg(salary), 2)) as 'Avg Salary'
    , concat('$', FORMAT(max(salary), 0)) as 'Max Salary'
    , concat('$', FORMAT(min(salary), 0)) as 'Min Salary'
from employees
where department_id is not null
group by department_id;	


-----------------------------------
-- 가장 많은 부하 직원을 가지고 있는 직원?
select max(cnt)
from 
	(select manager_id, count(manager_id) as cnt
	from employees
	group by manager_id) as result;















