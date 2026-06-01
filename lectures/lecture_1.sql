-- Create and test the following queries:

-- 1. Show employees who earn more than 2000 and whose surnames do not begin with the letter A. Sort the result by the date of employment.

-- 2. Show employees who earn less than 1500 and whose surnames do not end with the letter S. Sort the result by the date of employment.

-- 3. Show all positions (without repeating).

-- 4. Show all employees who have no commission.

-- 5. Show names of those employees who do not have a manager. Include their salaries and positions. Sort the result by salaries.

Select * from EMP; 

Select ename, sal, job from EMP
where sal > 2000 AND ename Not like 'A%'
Order by hiredate;


Select ename, sal, job from Emp where sal < 1500 And ename Not like '%S' order by hiredate;

select DISTINCT job from emp;

Select ename, sal, job from Emp where comm is Null;
select ename, sal, job from emp where mgr is Null;

-- 1. Show all employees who work as CLERK or ANALYST and earn more than 1000. Sort the result by salary in descending order.
Select ename, sal, job from emp where sal > 1000 And job in ('CLERK', 'ANALYST') order by sal desc;
-- 2. Show employees whose names start with the letter S and who were hired in the year 1981. Display their name, job, hire date, and salary. Sort by hire date.
Select ename, sal, job, hiredate from Emp where ename like 'S%' AND TO_CHAR(hiredate, 'YYYY') = '1981' order by hiredate;


-- 3. Show all employees who have a commission and whose commission is greater than their salary. Display name, salary, and commission.

select ename, sal, comm from Emp where comm is not null and comm > sal;
-- 4. Show all different job titles (positions) that exist in department number 30. Do not repeat the same position.
select DISTINCT job from emp e where e.deptno = 30;

-- 5. Show employees who do not work in department 20 and were hired after 01-JAN-82. Sort the result by department number, then by name.
select ename, sal, job from emp where deptno <> 20 AND hiredate > TO_DATE('01-JAN-82', 'DD-MON-YY') order by deptno, ename;
-- 6. Show the name, job, and salary of employees whose salary is between 1000 and 3000 (inclusive). Sort the result by salary ascending.
select ename, sal, job from emp where sal between 1000 and 3000 order by sal;

-- 7. Find all employees whose name contains the letter A (anywhere in the name) and who have a manager. Display name, job, manager ID, and department number.
select ename, job, mgr, deptno from emp where ename like '%A%' and mgr is not null;

-- 8. Show employees who either:

-- Have no commission, or
-- Earn less than 1200.
-- Display name, job, salary, and commission. Sort by salary descending.

-- 9. Show the names and salaries of employees who were hired in 1982. Sort the result from the most recently hired to the oldest.
select ename, sal from emp where hiredate between Date '1982-01-01' and Date '1982-12-31' order by hiredate desc;
-- 10. Show all employees who do not have the letter N in their name and work in department 10 or 30. Display name, job, department number, and salary. Sort by department number, then by name.
select ename, job, deptno, sal from emp where ename not like '%N%' and deptno In(10,30) order by deptno, ename;