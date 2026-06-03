-- 2.9 Exercises
-- (on creating queries to the database)

-- For the sample database from the lecture write queries for the following tasks:

-- Set 1
select * from emp;
select * from dept;
select * from salgrade;

-- 1. List employees who earn more than 2000 and whose names do not begin with letter A. Sort them by employment date.
Select ename, sal, job from emp where sal > 2000 and ename Not like '%A' order by hiredate;

-- 2. Find employees' data, hired on MANAGER position in NEW YORK or CHICAGO. Sort them by descending salaries.
Select e.ename, e.sal, e.job, e.hiredate, d.loc from emp e Join Dept d On e.deptno = d.deptno where e.job='MANAGER' and d.loc In ('NEW YORK', 'CHICAGO') order by e.sal desc;


-- 3. List names and places of work of those employees whose salaries fall into the fourth grade. Sort them by places of work.

select e.ename, d.loc 
from emp e 
Join Dept d on e.deptno = d.deptno 
Join salgrade s on e.sal Between s.losal and s.hisal
where s.grade=4
order by d.loc;


-- 4. Choose names of those employees who work in the same department as their managers. Next to the employee's name provide his manager's name and the name of the department.
Select 
  e.ename as employee,
  m.ename as manager,
  d.dname as department
From emp e
Join emp m on e.mgr = m.empno
Join dept d on e.deptno = d.deptno
Where e.deptno = m.deptno
order by e.ename;


-- 5. Show positions (without repeating) of people with no commission. Sort the result by the number of letters in the job position.
Select
  Distinct job
from emp
where comm is Null
Order by Length(RTrim(job));


-- Hint: use Length(w) function - returning the length of a string w and RTrim(w) function - deleting from string w all blank spaces at its end.

-- 6. Create all pairs of employees' names who work in the same department. The names in these pairs should be different and the pairs should not repeat.
Select
  e1.ename as employee1,
  e2.ename as employee2
from emp e1
Join emp e2 on e1.deptno = e2.deptno
where e1.ename != e2.ename
order by e1.ename, e2.ename;
-- 7. For every department show employee's name which is first in alphabetical order.
Select 
  d.dname as Department,
  Min(e.ename)as first_employee
  from emp e
Join dept d on e.deptno = d.deptno
Group by d.dname
order by d.dname;
-- 8. Choose managers (employees working on position MANAGER) who have exactly two subordinates. List their work places and their salary grades to which their salaries belong.

select 
  e.ename as manager_name,
  d.loc as workplace,
  s.grade as salary_grade
from emp e 
join dept d on e.deptno=d.deptno
join salgrade s on e.sal between s.losal and s.hisal
where e.job = 'MANAGER'
  and (Select COUNT(*) from emp sub where sub.mgr = e.empno)=2
order by e.ename;

-- 9. Show department's name whose employees earn most (on aggregate) and the name of the department where employees earn least (on aggregate). Write the result in the form of one sentence:

Select 
  (Select d.dname from emp e join dept d on e.deptno = d.deptno group by d.dname order by sum(e.sal) desc fetch first 1 row only) as highest_earning_department,
  (Select d.dname from emp e join dept d on e.deptno = d.deptno group by d.dname order by sum(e.sal) asc fetch first 1 row only) as lowest_earning_department,
  (Select sum(sal) from emp where deptno = (Select deptno from emp group by deptno order by sum(sal) desc fetch first 1 row only)) - 
  (Select sum(sal) from emp where deptno = (Select deptno from emp group by deptno order by sum(sal) asc fetch first 1 row only)) as salary_difference
from dual;
-- Employees earn most in department ... and least in department ... The difference is ...


-- Set 2

-- 1. List employees who earn less than 1500 and whose names do not end with letter S. Sort them by employment date.
Select ename, job, sal
  from emp
  where sal < 1500 and ename Not like '%S'
  order by hiredate;
-- 2. Find employees' data, hired on MANAGER position in DALLAS or BOSTON. Sort them by descending salaries.
Select * from emp;
select * from dept;
select * from salgrade;

select e.ename, e.job, e.sal, d.loc
from emp e
Join dept d on e.deptno = d.deptno
where e.job = 'MANAGER' and d.loc IN ('DALLAS', 'BOSTON')
order by e.sal desc;
-- 3. List names and place of work of those employees whose salaries fall into the third grade. Sort them by name of department.
Select e.ename, d.dname, s.grade
from emp e
Join dept d on e.deptno = d.deptno
join salgrade s on e.sal Between s.losal and s.hisal
where s.grade = 3
order by d.dname;
-- 4. Choose names of those employees whose salaries fall into the same grade as their manager's salary. Next to employee's name show his manager's name and manager's salary grade.

-- 5. Show positions (without repeating) where no one received any commission. Sort the result by the number of letters in the job position.

-- 6. Create pairs of employees who have the same manager. The names in these pairs should be  different and the pairs should not repeat.

-- 7. For every department show employee's name which is last in alphabetical order.

-- 8. Choose managers (employees working on position MANAGER) who have exactly one subordinate. List their work places and the salary grades to which their salaries belong.

-- 9. Find department's name where employees earn most on average and the name of the department where employees earn least on average. Write the result in the form of one sentence:

-- Employees earn most in department ... and least in department ... The difference is ...

 

