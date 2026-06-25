-- 3.16 Exercises
-- Create a view listing all locations (Loc) along with the number of departments in that location and the number of employees employed in those departments.

create view list_of_locations As
select d.loc, COUNT(DISTINCT d.Deptno) AS num_departments, Count(e.empno) as num_empoyees
from dept d
LEft join emp e on d.deptno = e.deptno
Group by d.loc
order by d.loc;

select * from list_of_locations;
-- Create a view where all data are collected concerning the person who uses the view. The data should come from table Emp and from the other tables Dept and Salgrade. We assume that the user's identifier is available through the constant user (see the result of the query: SELECT User FROM Dual;) is the same as the value Ename. First create a row in table Emp with your own identifier as Ename. Write SELECT statement which displays the content of the created view.
select * from emp;
Create or replace view my_personal_info as 
select e.empno, e.ename, e.job, e.hiredate, e.sal, e.comm, d.dname, d.loc, s.grade
  from emp e 
  Join dept d on e.deptno = d.deptno
  join salgrade s on e.sal between s.losal and s.hisal
  where e.ename = USER;

select * from my_personal_info;
-- Write a view which displays table names which you own. List them along with the number of columns and number of rows.
Create or replace view my_tables as
select table_name, num_rows, num_cols
from user_tables
join (select table_name, count(*) as num_cols from user_tab_columns group by table_name
) cols on user_tables.table_name = cols.table_name;
select * from my_tables;

-- Identify external levels in a database for a company selling products. For every external level define set of required views. Below there is a logical database schema for this company:
-- Employees(Emp_id, Name, Surname, Birth_date, Address)
-- Employment(Emp_id, Start_date, Position, End_date, Salary)
-- Products(Product_id, Name, Price)
-- Clients(Client_id, Name, Surname, Address)
-- Sales(Sales_id, Client_id, Product_id, Quantity, Date, Emp_id)
-- In the database schema from Exercise 4 the following changes were done. The table Categories(Cat_id, Name) was added and the column Cat_id was added to table Products getting Products(Product_id, Name, Price) The table Bonus(Emp_id, Date, Bonus) was added. Analyze what changes are needed to the definitions of earlier identified views.
-- A plane seat reservation application works in the following way. Having a specified flight and number of seats to be reserved application starts a database transaction checking if it is possible to reserve the required number of seats. If it is possible, it makes the reservation and executes COMMIT of the transaction. Next it sends an email to the customer confirming this reservation. Write SQL statements constituting this transaction. On what level of isolation should the transaction be executed for the application to work properly?
-- An application transferring money between bank accounts works in the following way. Having account numbers and the money amount to be transferred, application checks if there are accounts with the given numbers and then checks if the balance of the first account allows to make the transfer of a given value. If these conditions are met the requested amount of money is taken from one account and is added to the other. Write SQL statements forming this transaction. On what level of isolation should the transaction be executed for the application to work properly?
-- For a database containing customer orders consider the possibility of using clusters of tables.
