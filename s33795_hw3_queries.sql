-- 1. Create a view listing all locations (Loc) along with the number of departments in that location and the number of employees employed in those departments.

CREATE OR REPLACE VIEW v_locations AS
SELECT d.loc, COUNT(DISTINCT d.deptno) as num_departments, COUNT(e.empno) as num_employees
FROM dept d
LEFT JOIN emp e ON d.deptno = e.deptno
group by d.loc
Order by d.loc

-- DROP VIEW v_locations;
-- Select * from V_LOCATIONS;

-- 2. Create a view where all data are collected concerning the person who uses the view. The data should come from table Emp and from the other tables Dept and Salgrade. We assume that the user's identifier is available through the constant user (see the result of the query: SELECT User FROM Dual;) is the same as the value Ename. First create a row in table Emp with your own identifier as Ename. Write SELECT statement which displays the content of the created view.
Select * from emp;

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (9999, USER, 'ENGINEER', 7839, SYSDATE, 6000, Null, 10);
Commit;


CREATE OR REPLACE VIEW v_my_info AS
Select e.ename, e.job, e.sal, e.hiredate,d.dname as department, d.loc as location, s.grade as salary_grade
From emp e 
JOIN dept d on e.deptno = d.deptno
Left join SALGRADE s on e.sal Between s.losal and s.HISAL
where e.ename = USER;

Select * FROM V_MY_INFO;


-- 3. Write a view which displays table names which you own. List them along with the number of columns and number of rows.\
CREATE OR REPLACE VIEW v_my_tables AS
SELECT t.table_name,
      (Select COUNT(*) From user_tab_columns where table_name = t.table_name) As num_columns,
       t.num_rows
From user_tables t
Order by t.table_name;

SELECT * from v_my_tables;

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
CREATE OR REPLACE VIEW v_customer_purchases as
SELECT s.sales_id,
       p.name as product_name,
       s.quantity,
       s.date,
       p.price * s.quantity as total_amount
FROM sales s
Join products p On s.product_id = p.product_id
Where s.client_id = (SELECT client_id FROM clients WHERE name = USER);


CREATE OR REPLACE VIEW v_salesperson_sales as
SELECT s.sales_id,
       c.name as client_name,
       p.name as product_name,
       s.quantity,
       s.date
FROM sales s
Join clients c On s.client_id = c.client_id
Join products p On s.product_id = p.product_id
Where s.emp_id = (SELECT emp_id FROM employees WHERE name = USER);


CREATE OR REPLACE VIEW v_manager_overview as
SELECT e.name as employee,
       COUNT(s.sales_id) as total_sales,
       Count(p.price * s.quantity) as total_revenue
FROM sales s
Join employees e On s.emp_id = e.emp_id
Join products p On s.product_id = p.product_id
Group by e.name
Order by total_revenue DESC;


-- 5. A plane seat reservation application works in the following way. Having a specified flight and number of seats to be reserved application starts a database transaction checking if it is possible to reserve the required number of seats. If it is possible, it makes the reservation and executes COMMIT of the transaction. Next it sends an email to the customer confirming this reservation. Write SQL statements constituting this transaction. On what level of isolation should the transaction be executed for the application to work properly?

-- we dont have table flights we assume that we have in Db table with those schema models flights (
--     flight_id       NUMBER PRIMARY KEY,
--     flight_number   VARCHAR2(20),
--     available_seats NUMBER
-- );

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

Select available_seats
FROM flights
where flight_id = :flight_id
FOR UPDATE;

UPDATE flights
Set available_seats = available_seats - :number_of_seats
Where flight_id = :flight_id;

COMMIT;

-- 6. An application transferring money between bank accounts works in the following way. Having account numbers and the money amount to be transferred, application checks if there are accounts with the given numbers and then checks if the balance of the first account allows to make the transfer of a given value. If these conditions are met the requested amount of money is taken from one account and is added to the other. Write SQL statements forming this transaction. On what level of isolation should the transaction be executed for the application to work properly?

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT balance 
FROM accounts 
WHERE account_no = :from_account
FOR UPDATE;

UPDATE accounts 
SET balance = balance - :amount_to_transfer
WHERE account_no = :from_account;

UPDATE accounts 
SET balance = balance + :amount_to_transfer
WHERE account_no = :to_account;

COMMIT;

-- 7. For a database containing customer orders consider the possibility of using clusters of tables.

SELECT * FROM orders o
JOIN order_items i ON o.order_id = i.order_id 
WHERE o.order_id = 123;

-- 8. Prepare script which creates a database schema for customers and their orders of products. Define data correctness conditions in the form of declarative integrity constraints and referential actions.

--  Customers Table
CREATE TABLE customers (
    customer_id   NUMBER        PRIMARY KEY,
    name          VARCHAR2(50)  NOT NULL,
    surname       VARCHAR2(50)  NOT NULL,
    address       VARCHAR2(150),
    email         VARCHAR2(100),
    phone         VARCHAR2(20)
);

--  Products Table
CREATE TABLE products (
    product_id    NUMBER        PRIMARY KEY,
    name          VARCHAR2(100) NOT NULL,
    price         NUMBER(10,2)  NOT NULL CHECK (price > 0),
    stock         NUMBER(6)     DEFAULT 0 CHECK (stock >= 0)
);

--  Orders Table
CREATE TABLE orders (
    order_id      NUMBER        PRIMARY KEY,
    customer_id   NUMBER        NOT NULL,
    order_date    DATE          DEFAULT SYSDATE,
    status        VARCHAR2(20)  DEFAULT 'Pending',
    CONSTRAINT fk_orders_customer 
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE          -- If customer is deleted, their orders are also deleted
);

-- Order_Items Table (bridge table between orders and products)
CREATE TABLE order_items (
    order_id      NUMBER        NOT NULL,
    product_id    NUMBER        NOT NULL,
    quantity      NUMBER(5)     NOT NULL CHECK (quantity > 0),
    unit_price    NUMBER(10,2)  NOT NULL,
    CONSTRAINT pk_order_items 
        PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_oi_order 
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_oi_product 
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

