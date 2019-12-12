[1] 사원정보(EMPLOYEE) 테이블에서 사원번호, 이름, 급여, 업무, 입사일, 상사의 사원
번호를 출력하시오. 이때 이름은 성과 이름을 연결하여 Name이라는 별칭으로 출력하시오.
select employee_id, concat(first_name, ' ', last_name) as Name, salary, job_id, hire_date, manager_id
from employees;

[2] HR 부서에서 예산 편성 문제로 급여 정보 보고서를 작성하려고 한다. 사원정보
(EMPLOYEES) 테이블에서 급여가 $7,000~$10,000 범위 이외인 사람의 성과 이름(Name으로 별칭) 및 급여를 급여가 작은 순서로 출력하시오.
select concat(first_name, ' ', last_name) as Name, salary
from employees
where salary NOT between 7000 and 10000
order by salary;

[3] 사원의 이름(last_name) 중에 ‘e’ 및 ‘o’ 글자가 포함된 사원을 출력하시오. 이때 머리글은 ‘e and o Name’라고 출력하시오.
select last_name as 'e AND o Name'
from employees
where last_name LIKE '%e%' and last_name LIKE '%o%';

[4] HR 부서에서는 급여(salary)와 수당율(commission_pct)에 대한 지출 보고서를 작성하려고 한다. 이에 수당을 받는 모든 사원의 성과 이름(Name으로 별칭), 급여, 업무, 수당율을 출력하시오. 이때 급여가 큰 순서대로 정렬하되, 급여가 같으면 수당율이 큰 순서대로 정렬하시오.
select concat(first_name, ' ', last_name) as Name, salary, job_id, commission_pct, (salary * commission_pct) as bonus
from employees
where commission_pct is not null
order by salary DESC, commission_pct DESC;
