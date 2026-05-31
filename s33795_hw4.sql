-- A hairdresser needs a database with information about customers, services, reservations, employees and their shifts. Based on this information we are supposed be able to:

-- 1.(10p) Design database schema in the third normal form.
-- Main entities: Cusomers, Services, Reservations, Employees, Shifts, Payments

CREATE TABLE Customers(
    customer_id NUMBER PRIMARY KEY,
    full_name VARCHAR2(50) NOT NULL,
    phone VARCHAR2(20),
    email VARCHAR2(100),
    discount NUMBER(5,2) DEFAULT 0,
    CONSTRAINT chk_discount CHECK (discount BETWEEN 0 AND 100)
);
CREATE TABLE Employees(
    employee_id NUMBER PRIMARY KEY,
    full_name VARCHAR2(50) NOT NULL,
    position VARCHAR2(50)
);
Create TABLE Services(
    service_id NUMBER PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    price NUMBER(10,2) NOT NULL CHECK (price > 0)
);
Create Table Reservations(
    reservation_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    employee_id NUMBER NOT NULL,
    reservation_date DATE NOT NULL,
    status VARCHAR2(20) DEFAULT 'Scheduled',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Reservation_Services (
    id NUMBER PRIMARY KEY,
    reservation_id NUMBER,
    service_id NUMBER,
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);
CREATE TABLE Shifts (
    shift_id NUMBER PRIMARY KEY,
    employee_id NUMBER,
    shift_date DATE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
CREATE TABLE Receipts (
    receipt_id NUMBER PRIMARY KEY,
    reservation_id NUMBER,
    total_amount NUMBER,
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
);
INSERT INTO Customers VALUES (1, 'John Smith', '123', 'john@mail.com', 0);
INSERT INTO Employees VALUES (1, 'Anna', 'Hairdresser');
INSERT INTO Services VALUES (1, 'Haircut', 50);
COMMIT;
-- 2. Program PL/SQL procedure for the following task:

-- 2.1.(5p) insert a new customer;
CREATE OR REPLACE PROCEDURE add_customer (
    p_customer_id NUMBER,
    p_full_name VARCHAR2,
    p_phone VARCHAR2,
    p_email VARCHAR2
) IS BEGIN
    INSERT INTO Customers (customer_id, full_name, phone, email) 
    VALUES (p_customer_id, p_full_name, p_phone, p_email);
END;
/
Begin add_customer(1, 'John Doe', '123-456-7890', 'aizi@email.com');
end;
/
SELECT * FROM Customers;


-- 2.2.(10p) make a customer reservation to order a service to a particular hairdresser;
CREATE SEQUENCE res_serv_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE make_reservation(
    p_reservation_id NUMBER,
    p_customer_id NUMBER,
    p_employee_id NUMBER,
    p_reservation_date DATE,
    p_service_id NUMBER
) IS BEGIN
    INSERT INTO Reservations
    VALUES (p_reservation_id, p_customer_id, p_employee_id, p_reservation_date,'Booked');

    INSERT INTO Reservation_Services
    VALUES (res_serv_seq.NEXTVAL, p_reservation_id, p_service_id);
END;
/

BEGIN
    make_reservation(1001,1, 1, DATE '2026-04-28', 1);
END;
/

-- 2.3.(10p) check how many times a given person has been a customer during the last two years;
CREATE OR REPLACE FUNCTION count_visit(
  p_customer_id NUMBER
) RETURN NUMBER
IS
  v_count NUMBER;
BEGIN
  SELECT(COUNT(*)) INTO v_count FROM RESERVATIONS WHERE customer_id = p_customer_id
  and reservation_date >= ADD_MONTHS(SYSDATE, -24);
  RETURN v_count;

END;
/

-- 2.4.(5p) give a given customer a discount;
CREATE OR REPLACE PROCEDURE give_discount(
  p_customer_id NUMBER,
  p_discount NUMBER
)
IS
BEGIN
  UPDATE Customers
  SET discount = p_discount
  WHERE customer_id = p_customer_id;
END;
/
BEGIN
    give_discount(1, 15);
END;
/
-- 2.5.(10p) prepare a receipt for the service;
CREATE OR REPLACE PROCEDURE prepare_receipt(
    p_reservation_id NUMBER
) IS
  v_total_amount NUMBER;
BEGIN
    SELECT SUM(se.price * (1 - c.discount / 100)) INTO v_total_amount
    FROM Reservation_Services rs 
    JOIN Services se ON rs.service_id = se.service_id
    Join Reservations r On rs.reservation_id = r.reservation_id
    Join CUSTOMERS c On r.CUSTOMER_ID = c.CUSTOMER_ID
    where rs.reservation_id = p_reservation_id;

    insert into Receipts (receipt_id, reservation_id, total_amount)
    values (p_reservation_id, p_reservation_id, v_total_amount);
END;
/

-- 2.6.(10p) calculate salary for all employees (based on the fulfilled services);
CREATE OR REPLACE FUNCTION calculate_salary (
    p_employee_id NUMBER
) RETURN NUMBER
IS
  v_salary NUMBER;
  BEGIN
    SELECT NVL(SUM(s.price * (1 - c.discount / 100)),0) INTO v_salary
    FROM Reservations r
    JOIN Reservation_Services rs ON r.reservation_id = rs.reservation_id
    JOIN Services s ON rs.service_id = s.service_id
    JOIN Customers c ON r.customer_id = c.customer_id
    WHERE r.employee_id = p_employee_id AND r.status = 'Completed';

    RETURN v_salary;
  END;
/
-- 2.7.(20p) One of the hairdressers is sick. For each of the services assigned to him or her find a replacement - first we should look for those hairdressers that have a shift scheduled for that day.
CREATE OR REPLACE PROCEDURE find_replacement(
    p_employee_id NUMBER
) IS
BEGIN
    For r IN (
      Select reservation_id, reservation_date
      from Reservations
      where employee_id = p_employee_id
    )
    loop
      Declare
        v_replacement_id NUMBER;
        BEGIN
          SELECT employee_id INTO v_replacement_id
          FROM Shifts
          WHERE shift_date = r.reservation_date
            AND employee_id != p_employee_id
            AND ROWNUM = 1;

          UPDATE Reservations
          SET employee_id = v_replacement_id
          WHERE reservation_id = r.reservation_id;
        end;
    end loop;
END;
/


-- 3.(20p) Tasks related to triggers

CREATE OR REPLACE TRIGGER trg_check_reservation
BEFORE INSERT ON Reservations
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM CUSTOMERS
  WHERE customer_id = :NEW.customer_id;

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Customer does not exist');
  END IF;
END;
/

-- In the hairdresser database replace declarative referential integrity constraints by constraints defined by triggers.