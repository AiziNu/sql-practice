-- Homework - Database Systems Lecture 1
-- 1. Show employees who earn more than 2000 and whose surnames do not begin with the letter A. Sort the result by the date of employment.

SELECT * FROM EMP;

SELECT ename, sal, hiredate
FROM emp
WHERE sal > 2000
  AND ename NOT LIKE 'A%'
ORDER BY hiredate;

-- 2. Show employees who earn less than 1500 and whose surnames do not end with the letter S. Sort the result by the date of employment.

SELECT ename, sal, hiredate
FROM emp
WHERE  sal < 1500
  AND ename NOT LIKE '%S'
ORDER BY hiredate;


-- 3. Show all positions (without repeating).
SELECT DISTINCT job
FROM emp
ORDER BY job;


-- 4. Show all employees who have no commission.
SELECT ename, sal, comm
From emp
WHERE comm IS NULL OR comm = 0
ORDER BY ename;

-- 5. Show names of those employees who do not have a manager. Include their salaries and positions. Sort the result by salaries.
SELECT ename, sal, job
FROM emp
WHERE mgr IS NULL
ORDER BY sal;

-- 6. Show employees' data, hired on MANAGER position in department 10 or 20. Sort them by descending salaries.

SELECT ename, job, deptno, sal, hiredate
FROM emp
WHERE job = 'MANAGER' AND deptno IN (10,20)
ORDER BY sal DESC;

-- 7. Show employees hired in 1982 whose salary is outside the 1000 and 2000 range.
SELECT ename, sal, hiredate
FROM emp
WHERE hiredate BETWEEN TO_DATE('1982-01-01', 'YYYY-MM-DD') AND TO_DATE('1982-12-31', 'YYYY-MM-DD') AND (sal < 1000 OR sal > 2000)
ORDER BY hiredate;



-- 8. Insert one row into each table. Do this in the correct order, assuming referential integrity constraints are in place on the tables.
-- First DEPT (no dependencies)
INSERT INTO dept (deptno, dname, loc)
VALUES(50, 'IT SUPPORT', 'WARSAW');

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (9999, 'AIZI', 'ANALYST', 7839, SYSDATE, 4200, NULL, 50);

INSERT INTO salgrade (grade, losal, hisal)
VALUES (6, 10000, 20000);

-- BONUS (no FK constraints)
INSERT INTO bonus (ename, job, sal, comm)
VALUES ('AIZI', 'ANALYST', 4200, 0);

INSERT INTO dummy (dummy)
VALUES (1);

COMMIT;

SELECT * FROM dept WHERE deptno = 50;
SELECT * FROM emp WHERE empno = 9999;


-- 9. Increase the salary of every employee in department 10 by 20%.
UPDATE emp
SET sal = sal * 1.2
WHERE deptno = 10;

COMMIT;

SELECT ename, deptno, sal
FROM emp
WHERE deptno = 10;

-- 10. Remove employees with last names that contain five letters.
DELETE FROM emp
WHERE LENGTH(ename) = 5;

COMMIT;


SELECT ename FROM emp;