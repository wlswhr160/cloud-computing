-- 직업ID IT_PROG + 급여(SALARY)가 급여 테이블의 D레벨에 있는 직원 -> UNION(합집합)
SELECT employee_id, first_name, last_name, salary, job_id 
FROM hr.employees 
WHERE job_id LIKE '%IT%'
UNION
SELECT employee_id, first_name, last_name, salary, job_id 
FROM employees 
WHERE salary between (select lowest_sal from job_grades where grade_level='D') 
			     and (select highest_sal from job_grades where grade_level='D') ;
