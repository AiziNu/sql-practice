-- Create and test the following queries (there is a maximum of 12,5 points for each task):

-- 1. Create a view listing all locations (Loc) along with the number of departments in that location and the number of employees employed in those departments.
create or replace view list_emp_loc as
select d.loc,
        Count(distinct d.deptno) as num_depts,
        Count(e.empno) as nums_employes
from dept  d
join emp e on d.deptno = e.deptno
group by d.loc
order by d.loc;
select * from list_emp_loc;
-- 2. Create a view where all data are collected concerning the person who uses the view. The data should come from table Emp and from the other tables Dept and Salgrade. We assume that the user's identifier is available through the constant user (see the result of the query: SELECT User FROM Dual;) is the same as the value Ename. First create a row in table Emp with your own identifier as Ename. Write SELECT statement which displays the content of the created view.
select * from emp;
SELECT USER FROM dual;
UPDATE emp 
SET ename = 'S33795'
WHERE empno = 3375;

COMMIT;
rollback;


DELETE FROM emp 
WHERE ename = 'S33795' 
  AND empno != 3375;   -- keep the one with empno 3375
COMMIT;

create or replace view v_my_info as
select e.ename,
      e.job,
      e.sal, e.comm,
      e.hiredate,
      d.dname as department,
      d.loc as location,
      s.grade as salary_grade
from emp e
Join dept d on e.deptno = d.deptno
join salgrade s on e.sal between s.losal and s.hisal
where e.ename = USER;
select * from v_my_info;
-- 3. Write a view which displays table names which you own. List them along with the number of columns and number of rows.
create or replace view table_user_own as
select
      t.table_name,
      Count(c.column_name) as num_colums,
      t.num_rows
from user_tables t
left join user_tab_columns c on t.table_name = c.table_name
group by t.table_name, t.num_rows
order by t.table_name;
select * from table_user_own;
-- 4. Identify external levels (actors/roles) in a database for a company selling products. For every external level define set of required views. Below there is a logical database schema for this company:

-- Employees(Emp_id, Name, Surname, Birth_date, Address)

-- Employment(Emp_id, Start_date, Position, End_date, Salary)

-- Products(Product_id, Name, Price)

-- Clients(Client_id, Name, Surname, Address)

-- Sales(Sales_id, Client_id, Product_id, Quantity, Date, Emp_id)

-- (Actors/Roles) in the Company:

-- Customer – Wants to see their own orders and products
-- Salesperson – Wants to see their sales and clients
-- Manager – Wants to see overall sales performance
-- Administrator – Full access to all data
-- View for Customer
create or replace view customer_purchases as
select p.Product_id,
      p.name as product_name,
      s.quantity,
      s.date,
      p.price * s.quantity as total_amount
from sales s
join product p on s.Product_id = p.Product_id
where s.client_id = (select client_id from client where name = USER)

create or replace view salesPErson_sales as
select s.sales_id,
      c.name as client_name,
      p.name as product_name,
      s.quantity,
      s.date
from sales s
join product p on s.Product_id = p.Product_id
join client c on s.client_id = c.client_id
where s.emp_id = (select emp_id from Employees where name = USER )


create or replace view manager_performance as
select e.name as employee,
        Count(s.sales_id) as total_sale,
        Count(s.quantity * p.price) as total_revenue
from sales s
join product p on s.Product_id = p.Product_id
Join employees e on s.emp_id = e.emp_id
Group by e.name
order by e.name

-- 5. A plane seat reservation application works in the following way. Having a specified flight and number of seats to be reserved application starts a database transaction checking if it is possible to reserve the required number of seats. If it is possible, it makes the reservation and executes COMMIT of the transaction. Next it sends an email to the customer confirming this reservation. Write SQL statements constituting this transaction. On what level of isolation should the transaction be executed for the application to work properly?
Begin transaction;

select available_seats
from flight 
where flight_id = :flight_id
for update;

update flight
set available_seat = :available_seat - :number_of_seats
where flight_id = :flight_id;

commit;
-- 6. An application transferring money between bank accounts works in the following way. Having account numbers and the money amount to be transferred, application checks if there are accounts with the given numbers and then checks if the balance of the first account allows to make the transfer of a given value. If these conditions are met the requested amount of money is taken from one account and is added to the other. Write SQL statements forming this transaction. On what level of isolation should the transaction be executed for the application to work properly?
Begin transaction;

select balance
from accounts
where account_no = :from_account
for update;

Update accounts
set balance = balance - :amount_to_transfer
where account_no = :from_account;

update accounts
set balance = balance + :amount_to_transfer
where account_no = :to_account;


COMMIT;

-- 7. For a database containing customer orders consider the possibility of using clusters of tables.

create cluster customer_order_cluster(CustomerId Number(10))

create table Customers(
  CustomerID Number(10) primary key
  Name Varchar2(100)
  Address Varchar(100)
) Cluster customer_order_cluster(CustomerID);

Create table Orders(
  OrderID Number(10) primary Key,
  CustomerId NUMBER(10) REFERENCES Customers(CustomerId),
  OrderDate DATE,
  TotalAmount NUMBER(12,2)
)Cluster customer_order_cluster(CustomerID)

CREATE INDEX idx_customer_orders 
ON CLUSTER customer_order_cluster

-- 8. Prepare script which creates a database schema for customers and their orders of products. Define data correctness conditions in the form of declarative integrity constraints and referential actions.
