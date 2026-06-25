-- Practice Tasks (do them one by one)
-- Task 1 (Easy):
-- Write a query that shows:

-- Employee name (ename)
-- Salary (sal)
-- Hire date (hiredate)
-- Position (job)

-- For all employees who:

-- Earn between 1000 and 3000 (inclusive)
-- Were hired in 1981
-- Are NOT in department 30

-- Sort by salary descending.

-- Task 2 (Medium):
-- Write a query that shows employees who have no manager (mgr IS NULL) or have commission greater than 0.
-- Include: name, job, salary, commission.
-- Sort by commission descending, then by salary descending.

select e.ename, e.sal, e.hiredate, e.job
from emp e
join dept d on e.deptno = d.deptno
where e.hiredate between TO_DATE('1981-01-01', 'YYYY-MM-DD') AND TO_DATE('1981-12-31', 'YYYY-MM-DD')
and (e.sal > 1000 or e.sal <=3000) and d.deptno = 30
order by e.sal desc;

select * from emp;
select * from dept;

select ename, job, sal, comm
from emp
where mgr is null OR comm > 0;
-- Show employee name, department name (dname), and location (loc) for all employees. Even if some employees have no department (though in this schema all do).
select e.ename, d.dname, d.loc
from emp e
join dept d on e.deptno = d.deptno
order by e.ename;
-- Task 4:
-- Show each employee’s name and their manager’s name (use self-join). Include employees who have no manager (show NULL for manager name).
select e.ename, m.ename as Manager
from emp e 
Left join emp m on e.mgr = m.empno
order by e.ename;
-- Write a query that shows all departments with the number of employees in each (even if 0 employees).
select d.dname, COUNT(e.ename) as Number_employees
from dept d
left join emp e on d.deptno = e.deptno
group by d.ename;
-- Show only departments that have 3 or more employees.
select d.dname, COUNT(e.ename) as Number_employees
from dept d
left join emp e on d.deptno = e.deptno
group by d.dname
HAVING COUNT(e.empno) >= 3;

-- Task 10
-- Show each job title and:

-- Number of employees in that position
-- Total salary for that position
-- Average salary

-- Sort by number of employees descending.
select job, count(empno) as num_employees, Sum(sal) as total_salary, AVG(sal)
from emp
group by job  
order by num_employees DESC;
-- Task 11
-- Show only job titles that have more than 2 employees and average salary higher than 2000.
select job, count(empno) as num_employees, AVG(sal) as avarage_sal
from emp
group by job
having count(empno) > 2 and AVG(sal) > 2000
order by num_employees desc;

-- Show all employees who earn more than the overall average salary in the company.
select ename, sal 
from emp 
where sal > (select avg(sal) from emp)
order by sal desc;

-- Show all employees who earn more than the average salary in their own department.
select e1.ename, e1.sal, e1.deptno
from emp e1
where e1.sal > (select AVG(e2.sal) from emp e2 where e2.deptno = e1.deptno)
order by e1.sal desc;

-- Create a view called v_employee_info that shows:

-- Employee name (ename)
-- Job
-- Department name (dname)
-- Salary
-- Salary grade (from salgrade)
create or replace view v_employee_info as
select e.ename, e.job, d.dname, e.sal, s.grade
from emp e
Left join dept d On e.deptno = d.deptno
join salgrade s on e.sal between s.losal and s.hisal

select * from v_employee_info;

-- Task A (Procedure):
-- Create a simple procedure called increase_salary that increases the salary of a given employee by a given percentage.
-- Parameters: p_empno, p_percent
create or replace procedure increase_salary(
  p_empno Number,
  p_percent NUMBER
) is
begin
    update emp
    set sal= sal*(1+p_percent /100)
    where empno = p_empno;
    commit;
end;
/

-- Create a function get_employee_salary that returns the salary of a given employee (p_empno).
create or replace function get_employee_salary(p_empno number)
return Number is
v_salary Number;
begin
    select sal INTO v_salary from emp where empno = p_empno;
    return v_salary;
end;
/ 
-- Create a procedure called delete_employee that:

-- Takes p_empno as parameter
-- Deletes the employee with that empno
create or replace procedure delete_employee(p_empno Number) is
begin
    delete from emp where empno = p_empno;
    commit;
end;
/
-- Practice 2 (Function)
-- Create a function called get_department_name that:

-- Takes p_deptno as parameter
-- Returns the department name (dname) for that department
create or replace function get_department_name(p_deptno Number)
return VARCHAR2 is
v_dname VARCHAR2(50);
begin
    select dname Into v_dname
    from dept
    where deptno = p_deptno;
    return v_dname;
end;
/

-- Practice 3 (Procedure - a bit harder)
-- Create a procedure called transfer_employee that:

-- Takes p_empno and p_new_deptno
-- Changes the employee's department to the new one
create or replace procedure transfer_employee(
  p_empno Number,
  p_new_deptno Number
)is
begin
    update emp
    set e.deptno = p_new_deptno
    where empno = p_empno;
    commit;
end;
/

select e.ename, e.sal, m.ename as manager, m.sal as manager_sal
from emp e
Join emp m on e.mgr = m.empno
where e.sal > m.sal;