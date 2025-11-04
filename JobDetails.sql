create database JobDetails;

use JobDetails;

CREATE TABLE DEPT (
    DEPTNO  INT PRIMARY KEY,
    DNAME   VARCHAR(50) NOT NULL,
    DLOC    VARCHAR(50)
);

CREATE TABLE PROJECT (
    PNO     INT PRIMARY KEY,
    PNAME   VARCHAR(50) NOT NULL UNIQUE,
    PLOC    VARCHAR(50)
);

CREATE TABLE EMPLOYEE (
    EMPNO   INT PRIMARY KEY,
    ENAME   VARCHAR(50) NOT NULL,
    MGR_NO  INT,
    HIREDATE DATE,
    SAL     DECIMAL(10, 2) NOT NULL,
    DEPTNO  INT,
    
    FOREIGN KEY (DEPTNO) REFERENCES DEPT(DEPTNO)
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Self-referencing FK for Manager
    FOREIGN KEY (MGR_NO) REFERENCES EMPLOYEE(EMPNO)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE INCENTIVES (
    EMPNO           INT,
    INCENTIVE_DATE  DATE,
    INCENTIVE_AMOUNT DECIMAL(10, 2),
    
    PRIMARY KEY (EMPNO, INCENTIVE_DATE),
    
    FOREIGN KEY (EMPNO) REFERENCES EMPLOYEE(EMPNO)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ASSIGNED_TO (
    EMPNO   INT,
    PNO     INT,
    JOB_ROLE VARCHAR(50),
    
    PRIMARY KEY (EMPNO, PNO),
    
    FOREIGN KEY (EMPNO) REFERENCES EMPLOYEE(EMPNO)
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    FOREIGN KEY (PNO) REFERENCES PROJECT(PNO)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO DEPT (DEPTNO, DNAME, DLOC) VALUES
(10, 'Admin', 'Bangalore'),
(20, 'Research', 'Mangalore'),
(30, 'Sales', 'Mysore'),
(40, 'Finance', 'Chennai'),
(50, 'HR', 'Hyderabad');

INSERT INTO PROJECT (PNO, PNAME, PLOC) VALUES
(101, 'Apollo', 'USA'),
(102, 'Shakti', 'India'),
(103, 'Astra', 'Bengaluru'),
(104, 'Quantum', 'Delhi'),
(105, 'Horizon', 'Mumbai');

INSERT INTO EMPLOYEE (EMPNO, ENAME, MGR_NO, HIREDATE, SAL, DEPTNO) VALUES
(7000, 'Sri', NULL, '2010-01-01', 50000.00, 10),
(7001, 'Akash', 7000, '2015-05-10', 35000.00, 30),
(7002, 'Vinay', 7000, '2016-08-15', 40000.00, 20),
(7003, 'Gita', 7000, '2018-03-20', 32000.00, 40),
(7004, 'Neha', 7000, '2020-11-25', 30000.00, 30);

INSERT INTO INCENTIVES (EMPNO, INCENTIVE_DATE, INCENTIVE_AMOUNT) VALUES
(7000, '2025-01-01', 5000.00),
(7001, '2025-01-01', 1000.00),
(7001, '2025-02-01', 500.00),  -- Composite Key Test
(7002, '2025-01-01', 1500.00),
(7003, '2025-01-01', 2000.00);

INSERT INTO ASSIGNED_TO (EMPNO, PNO, JOB_ROLE) VALUES
(7000, 101, 'Project Head'),
(7002, 102, 'Developer'),
(7004, 103, 'Tester'),
(7001, 104, 'Analyst'),
(7003, 105, 'Finance Lead');

-- Retrieve the employee members of all employees who work on projects located in Bengaluru, Hyderabad or Mysuru

SELECT a.EMPNO
FROM ASSIGNED_TO AS a
INNER JOIN PROJECT AS p ON p.PNO = a.PNO
WHERE p.PLOC IN ('Bengaluru', 'Mysuru', 'Hyderabad');

-- GET EMPLOYEE IDs of those employees who didn't receive incentives

select e.EMPNO, e.ENAME from EMPLOYEE e LEFT JOIN INCENTIVES i ON e.EMPNO = i.EMPNO WHERE i.EMPNO is NULL;

-- Find the employees name, number, dept, job role, department location and project locatin who are working for a project location same as their department location

select e.EMPNO, e.ENAME, e.DEPTNO, a.JOB_ROLE, d.DLOC, p.PLOC
FROM EMPLOYEE e
INNER JOIN DEPT d on e.DEPTNO = d.DEPTNO
INNER JOIN ASSIGNED_TO a ON a.EMPNO = e.EMPNO
INNER JOIN PROJECT p ON p.PNO = a.PNO
WHERE p.PLOC = d.DLOC;

-- list the names of the managers with the maximum employees

select m.ENAME, m.EMPNO, COUNT(e.EMPNO) as 'Employees' FROM EMPLOYEE e
INNER JOIN EMPLOYEE m ON m.EMPNO = e.MGR_NO
GROUP BY m.EMPNO, m.ENAME
HAVING COUNT(e.EMPNO) = (
SELECT MAX(t.Reportee_Count) 
FROM ( SELECT COUNT(ENAME) as Reportee_Count FROM EMPLOYEE WHERE MGR_NO is NOT NULL GROUP BY MGR_NO) as t
);

-- display those managers names whose salary is more than the average salary of his employees

SELECT m.ENAME, m.SAL, AVG(e.SAL) 'Reportee Salary Average'
FROM EMPLOYEE e INNER JOIN EMPLOYEE m ON m.EMPNO = e.MGR_NO GROUP BY m.EMPNO, m.ENAME, m.SAL HAVING m.SAL > AVG(e.SAL);

-- Find the employee details who got second maximum incentive in January 2025

select e.ENAME, e.EMPNO, i.INCENTIVE_AMOUNT
FROM EMPLOYEE e INNER JOIN INCENTIVES i ON i.EMPNO = e.EMPNO
WHERE i.INCENTIVE_DATE BETWEEN '2025-01-01' AND '2025-01-31' ORDER BY i.INCENTIVE_AMOUNT DESC LIMIT 1 OFFSET 1;

-- Displaythose emloyees who are working in the same department where their manager is working

SELECT e.ENAME, m.ENAME, e.DEPTNO
FROM EMPLOYEE e INNER JOIN EMPLOYEE m ON m.EMPNO = e.MGR_NO
WHERE e.DEPTNO = m.DEPTNO;