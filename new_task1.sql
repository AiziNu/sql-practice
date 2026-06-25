-- Create and test the following queries (there is a maximum of 10 points for each task):

-- 1. Show employees who earn more than 2000 and whose surnames do not begin with the letter A. Sort the result by the date of employment.

Select ename, job, hiredate, sal
From emp 
Where sal > 2000 and ename not like 'A%'
order by hiredate;

-- 2. Show employees who earn less than 1500 and whose surnames do not end with the letter S. Sort the result by the date of employment.
Select ename, job, hiredate, sal
From emp 
Where sal < 1500 and ename not like '%S'
order by hiredate;

-- 3. Show all positions (without repeating).
Select DISTINCT job
from emp
order by job;
-- 4. Show all employees who have no commission.
select ename, job, sal, comm
from emp 
where comm is null or comm = 0
order by comm;
-- 5. Show names of those employees who do not have a manager. Include their salaries and positions. Sort the result by salaries.
select ename, job, sal
From emp 
where mgr is null
order by sal;
-- 6. Show employees' data, hired on MANAGER position in department 10 or 20. Sort them by descending salaries.
select e.ename, e.job, e.sal, e.hiredate
from emp e
join dept d on e.deptno = d.deptno
where e.job = 'MANAGER' and d.deptno in(10,20)
order by e.sal desc;
-- 7. Show employees hired in 1982 whose salary is outside the 1000 and 2000 range.
select ename, job, sal, hiredate
from emp e
where hiredate between Date '1982-01-01' and Date '1982-12-31' 
      and (sal < 1000 OR sal > 2000)
order by hiredate;
select * from dept;
select * from emp;
select * from salgrade;
-- 8. Insert one row into 3 tables (EMP, DEPT, SALGRADE). Pracownik wstawiany do tabeli EMP ma mieć DEPTNO = 50 i SAL = 10000. Do this in the correct order, assuming referential integrity constraints are in place on the tables.
insert into dept values(50, 'IT', 'WARSAW');
insert into emp(empno, ename,job,mgr, hiredate,sal, comm, deptno)
            values(3375, 'AIZI', 'IT_TECH', 7902, SYSDATE,4000, 200, 50);
insert into salgrade(grade,losal,hisal)
values(6, 10000, 12000);
-- 9. Increase the salary of every employee in department 10 by 20%.
update emp
set sal = sal*1.2
where deptno = 10;
commit;
select ename, job, sal
from emp 
where deptno = 10;
-- -- 10. Remove employees with last names that contain five letters.
delete from emp
where LENGTH(ename) = 5;
commit;
ROLLBACK;