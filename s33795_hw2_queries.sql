-- 1. List names of employees who have been working in the CLERK position for more than 20 years.
-- Select ename, job, hiredate, TRUNC(MONTHS_BETWEEN(SYSDATE, hiredate)/12) AS years_worked
-- FROM emp
-- WHERE job = 'CLERK' AND MONTHS_BETWEEN(SYSDATE, hiredate)/12 > 20
-- ORDER BY hiredate;


-- . Find employees' data, hired on MANAGER position in NEW YORK or CHICAGO. Sort them by descending salaries.
SELECT e.ename, e.job, e.sal, e.hiredate, d.dname, d.loc
FROM emp e
Join dept d ON e.deptno = d.deptno
WHERE e.job = 'MANAGER'
And d.loc IN ('NEW YORK', 'CHICAGO')
ORDER BY e.sal DESC;


-- 3. List names and places of work of those employees whose salaries fall into the fourth grade. Sort them by places of work.
SELECT e.ename, d.loc, e.sal, s.grade
From emp e
  Join dept d On d.deptno = e.deptno
  Join salgrade s On e.sal Between s.losal and s.hisal
Where s.grade = 4
Order by d.loc, e.ename;


-- 4. Choose names of those employees who work in the same department as their managers. Next to the employee's name provide his manager's name and the name of the department.
SELECT e.ename As employee,
        m.ename As manager,
        d.dname As department
From emp e
Join emp m On e.mgr = m.empno
Join dept d On e.deptno = d.deptno
Where e.deptno = m.deptno
Order By d.dname, e.ename;


-- 5. Show positions (without repeating) of people with no commission. Sort the result by the number of letters in the job position.
Select Distinct job, LENGTH(RTRIM(job)) AS job_length
From emp
where comm IS NULL OR comm = 0
order by job_length;

-- 6. Create all pairs of employees' names who work in the same department. The names in these pairs should be different and the pairs should not repeat.
SELECT e1.ename AS employee1, 
       e2.ename AS employee2,
       d.dname AS department
FROM emp e1
JOIN emp e2 ON e1.deptno = e2.deptno
JOIN dept d ON e1.deptno = d.deptno
WHERE e1.empno < e2.empno        -- prevents duplicate pairs and self-pairs
ORDER BY d.dname, e1.ename;

-- 7. For every department show employee's name which is first in alphabetical order.
SELECT d.dname,
       MIN(e.ename) AS first_employee
FROM emp e
JOIN dept d ON e.deptno = d.deptno
GROUP BY d.dname
ORDER BY d.dname;

-- 8. Choose managers (employees working on position MANAGER) who have exactly two subordinates. List their work places and their salary grades to which their salaries belong.
SELECT m.ename AS manager,
       d.loc AS work_place,
       s.grade AS salary_grade,
       COUNT(*) AS num_subordinates
FROM emp m
JOIN emp e ON m.empno = e.mgr
JOIN dept d ON m.deptno = d.deptno
JOIN salgrade s ON m.sal BETWEEN s.losal AND s.hisal
WHERE m.job = 'MANAGER'
GROUP BY m.ename, d.loc, s.grade
HAVING COUNT(*) = 2;

-- 9. For each department, list the name of the employee with the longest last name in that department.

SELECT d.dname,
       e.ename AS longest_name,
       LENGTH(e.ename) AS name_length
FROM emp e
JOIN dept d ON e.deptno = d.deptno
WHERE LENGTH(e.ename) = (
    SELECT MAX(LENGTH(ename))
    FROM emp
    WHERE deptno = e.deptno
)
ORDER BY d.dname;

-- 10. Show department's name whose employees earn most (on aggregate) and the name of the department where employees earn least (on aggregate). Write the result in the form of one sentence:

SELECT 
    'Employees earn most in department ' || MAX_DEPT ||
    ' and least in department ' || MIN_DEPT ||
    '. The difference is ' || diff AS result
FROM (
    SELECT 
        MAX(CASE WHEN total_sal = max_total THEN dname END) AS MAX_DEPT,
        MAX(CASE WHEN total_sal = min_total THEN dname END) AS MIN_DEPT,
        MAX(total_sal) - MIN(total_sal) AS diff
    FROM (
        SELECT 
            d.dname,
            SUM(e.sal) AS total_sal,
            MAX(SUM(e.sal)) OVER () AS max_total,
            MIN(SUM(e.sal)) OVER () AS min_total
        FROM emp e
        JOIN dept d ON e.deptno = d.deptno
        GROUP BY d.dname
    ) t
) x;