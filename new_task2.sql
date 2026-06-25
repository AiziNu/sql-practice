-- Create and test the following queries (there is a maximum of 10 points for each task):

-- 1. List names of employees who have been working in the CLERK position for more than 20 years.
select * from emp;
select * from dept;
select * from salgrade;
select ename, trunc(months_between(sysdate, hiredate)/12) as years_worked
from emp
where job = 'CLERK' and months_between(sysdate, hiredate)/12 > 20
order by hiredate;
-- 2. Find employees' data, hired on MANAGER position in NEW YORK or CHICAGO. Sort them by descending salaries.
select e.ename, e.job, e.sal, e.hiredate
from emp e
join dept d on e.deptno = d.deptno
where e.job = 'MANAGER' and d.loc in ('NEW YORK', 'CHICAGO')
order by e.sal desc;
-- 3. List names and places of work of those employees whose salaries fall into the fourth grade. Sort them by places of work.
select e.ename, e.job, d.loc
from emp e
join dept d on e.deptno = d.deptno
join salgrade s on e.sal between s.losal and s.hisal
where s.grade = 4
order by d.loc;
-- 4. Choose names of those employees who work in the same department as their managers. Next to the employee's name provide his manager's name and the name of the department.
select e.ename as employee_name,
      m.ename as manager_name,
      d.dname as department_name
from emp e
join emp m on e.mgr = m.empno
join dept d on e.deptno = d.deptno
where e.deptno = m.deptno
order by d.dname, e.ename;
-- 5. Show positions (without repeating) of people with no commission. Sort the result by the number of letters in the job position.
select distinct ename, LENGTH(RTRIM(job)) AS job_length
from emp
where comm is null or comm = 0
order by job_length;
-- Hint: use Length(w) function - returning the length of a string w and RTrim(w) function - deleting from string w all blank spaces at its end.

-- 6. Create all pairs of employees' names who work in the same department. The names in these pairs should be different and the pairs should not repeat.
Select e1.ename as employee_1,
      e2.ename as employee_2,
      d.dname as depatrment
from emp e1
Join emp e2 on e1.deptno = e2.deptno
Join dept d on e1.deptno = d.deptno
where e1.empno < e2.empno
order by e1.ename;
-- 7. For every department show employee's name which is first in alphabetical order.
select d.dname,
      Min(e.ename) as first_employee_name
from dept d
Join emp e on d.deptno = e.deptno
Group by d.dname
order by d.dname;

-- 8. Choose managers (employees working on position MANAGER) who have exactly two subordinates. List their work places and their salary grades to which their salaries belong.
select m.ename as manager,
        s.grade,
        d.loc,
        Count(*) as num_subordinaries
from emp m
Join emp e on m.empno = e.mgr
join dept d on m.deptno = d.deptno
join salgrade s on m.sal between s.losal and s.hisal
where m.job = 'MANAGER'
group by m.ename, s.grade, d.loc
having COUNT(*) =2;
-- 9. For each department, list the name of the employee with the longest last name in that department.
select d.dname,
        e.ename as longest_name,
        Length(e.ename) as length_name
From dept d
Join emp e on d.deptno = e.deptno
where length(e.ename) = (
  select Max(LEngth(ename))
  from emp
  where deptno = e.deptno
)
order by d.dname;
-- 10. Show department's name whose employees earn most (on aggregate) and the name of the department where employees earn least (on aggregate). Write the result in the form of one sentence:
select 'Employees earn most in department ' || max_dept_sal || 
          ' and least in department ' || min_dept_sal ||
          '. The difference is ' || diff_sal as result
from(
    select max(case when total_sal = max_total then dname end) as max_dept_sal,
          max(case when total_sal = min_total then dname end ) as min_dept_sal,
          max(total_sal)- Min(total_sal) as diff_sal
          from(
            select d.dname,
                    Sum(e.sal) as total_sal,
                    Max(Sum(e.sal)) over () as max_total,
                    Min(sum(e.sal)) over () as min_total
            from emp e
            join dept d on e.deptno = d.deptno
            group by d.dname
          )dept_total
)final_result;

-- Employees earn most in department ... and least in department ... The difference is ...

-- Show the department name with the most employees and the department name with the least employees.
-- Write the result in the form of one sentence like this:
-- "Department X has the most employees and department Y has the least employees. The difference is Z."
select 'Department ' || max_num_dept_emp ||
        ' has the most employees and department ' || min_num_dept_emp ||
        ' has the least employees. The difference is ' || diff as result
        FROM(
          select max(case when total_emp = max_total_emp then dname end) as max_num_dept_emp,
                max(case when total_emp = min_total_emp then dname end) as min_num_dept_emp,
                max(total_emp)-min(total_emp) as diff
                from(
                  Select d.dname,
                          Count(*) as total_emp,
                          MAx(Count(*)) over () max_total_emp,
                          Min(Count(*)) over () min_total_emp
                  from emp e
                  join dept d on e.deptno = d.deptno
                  group by d.dname
                )dept_total
)final_result;