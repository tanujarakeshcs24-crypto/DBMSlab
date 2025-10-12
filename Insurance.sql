create database Insurance;
use Insurance;

create table Person (
	driver_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(20),
    address VARCHAR(30)
);

CREATE TABLE Car (
	reg_num VARCHAR(30) PRIMARY KEY,
    model VARCHAR(30),
    year int
);

create table Accident (
	report_num int PRIMARY KEY,
    accident_date date,
    location VARCHAR(20)
);

create table Owns (
	driver_id VARCHAR(10),
    reg_num VARCHAR(10),
    PRIMARY KEY(driver_id, reg_num),
    FOREIGN KEY(driver_id) REFERENCES Person(driver_id),
    FOREIGN KEY(reg_num) REFERENCES Car(reg_num)
);

CREATE TABLE Participated (
driver_id VARCHAR(10),
reg_num VARCHAR(10),
report_num INT,
damage_amount INT,
PRIMARY KEY(driver_id, reg_num, report_num),
FOREIGN KEY(driver_id) REFERENCES person(driver_id),
FOREIGN KEY(reg_num) REFERENCES car(reg_num),
FOREIGN KEY(report_num) REFERENCES accident(report_num)
);

insert into Person (driver_id,name,address) values
('A01', 'Richard', 'Srinivas Nagar'),
('A02', 'Pradeep', 'Rajaji nagar'),
('A03', 'Smith', 'Ashok nagar'),
('A04', 'Venu', 'N R Colony'),
('A05', 'Jhon', 'Hanumanth nagar');

insert into Car (reg_num,model,year) values
('KA052250', 'Indica', 1990),
('KA031181', 'Lancer', 1957),
('KA095477', 'Toyota', 1998),
('KA053408', 'Honda', 2008),
('KA041702', 'Audi', 2005);

insert into Owns (driver_id,reg_num) values
('A01', 'KA052250'),
('A02', 'KA053408'),
('A03', 'KA031181'),
('A04', 'KA095477'),
('A05', 'KA041702');

INSERT INTO Accident (report_num,accident_date,location) values
(11, '2003-01-01', 'Mysore Road'),
(12, '2004-02-02', 'South End Circle'),
(13, '2003-01-21', 'Bull Temple Road'),
(14, '2008-02-17', 'Mysore Road'),
(15, '2004-03-04', 'Kanakpura Road');

insert into Participated (driver_id,reg_num,report_num,damage_amount) values
('A01', 'KA052250', 11, 10000),
('A02', 'KA053408', 12, 50000),
('A03', 'KA095477', 13, 25000),
('A04', 'KA031181', 14, 3000),
('A05', 'KA041702', 15, 5000);

select report_num "No.", accident_date "Date", location from Accident;

select p.name "Name", d.damage_amount "Damages" from Person p, Participated d where (d.driver_id = p.driver_id) and (d.damage_amount >= 25000);

select p.name "Name", c.model "Car" from Person p, Car c, Owns o where (p.driver_id = o.driver_id) and (o.reg_num = c.reg_num);

select p.name "Name", a.accident_date "Date", a.location "Location", d.damage_amount "Damages" from Person p, Accident a, Participated d where (p.driver_id = d.driver_id) and (d.report_num = a.report_num);

select name from Person p, Owns o where (select count(reg_num) from Participated d where d.reg_num = o.reg_num and o.driver_id = p.driver_id) > 1;

select c.model from Car c where NOT EXISTS (select 1 from Participated p where p.reg_num = c.reg_num);

select * from Accident ORDER BY accident_date DESC limit 1;

select p.name, avg(d.damage_amount) "Average Damage" from Person p, Participated d where p.driver_id = d.driver_id group by d.driver_id;

update Participated p, Car c set p.damage_amount = 25000 where p.reg_num = c.reg_num and c.model = 'Audi';
select * from Participated;

select p.name, (d.damage_amount) "Damage" from Person p, Participated d where p.driver_id = d.driver_id order by d.damage_amount DESC limit 1;

select c.model, SUM(p.damage_amount) "Damage" from Car c, Participated p where p.reg_num = c.reg_num GROUP by p.reg_num;

create view ReportDamages AS
select count(*) "Total Accidents", sum(damage_amount) "Total Damage" from Participated;

SELECT * FROM ReportDamages;