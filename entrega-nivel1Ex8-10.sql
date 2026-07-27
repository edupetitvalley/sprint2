-- Exercici 8
-- Descarrega els arxius CSV que trobaràs a l'apartat de recursos:
--     • american_users.csv 
--     • european_users.csv 
--     • companies.csv 
--     • credit_cards.csv 
--     • transactions.csv 
-- Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
-- La taula de products.csv l'utilitzarem més endavant.




-- Exercici 9
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules. 

CREATE DATABASE IF NOT EXISTS sprint2db;
USE sprint2db;

-- primer creo i despres Uneixo taules users euro amb users america
CREATE TABLE IF NOT EXISTS users_america (
    id VARCHAR(15) PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(100),
    phone VARCHAR(25),
    email VARCHAR(255),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(15),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(20)
);


CREATE TABLE IF NOT EXISTS users_europe (
    id VARCHAR(15) PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(100),
    phone VARCHAR(25),
    email VARCHAR(255),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(15),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(20)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__american_users.csv' 
INTO TABLE american_users 
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__european_users.csv' 
INTO TABLE european_users 
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

-- 1010 american users
-- 3990 euro users

-- en principio habia creado la tabla users eu y amer formato DATE a pesar q los valores estan en texto "Sep 26, 1957"
-- asi q cambio las columnas de  birthdate a texto para que se puedan insertar con su actual formato y luego hacer la conversion con `STR_TO_DATE()`:
alter table users_america modify column birth_date text;
alter table users_europe modify column birth_date text;

-- creo columna nueva birth_date_DATE formato DATE para pegar las fechas despues de convertirlas a DATE desde birth_date
ALTER TABLE users_america
ADD COLUMN birth_date_DATE date;
ALTER TABLE users_europe
ADD COLUMN birth_date_DATE date;

--conversion de las fechas en texto de birth_date a formato DATE en birth_date_DATE
update users_america
set birth_date_DATE = STR_TO_DATE(birth_date, '%b %d, %Y') ;
select * from users_america limit 10; 
update users_europe
set birth_date_DATE = STR_TO_DATE(birth_date, '%b %d, %Y') ;

-- elimno las cols con el formato original de fecha 
alter table users_america drop column birth_date;
alter table users_europe drop column birth_date;

-- cambio el nombre de la nueva columna con formato DATE al nombre de la columna q eliminé en el paso anterior
alter table users_america rename column birth_date_DATE to birth_date;
alter table users_europe rename column birth_date_DATE to birth_date;

-- ordeno las cols de users europe y america para q coincidan con users all y poder juntarlas mas facilmente
ALTER TABLE users_america MODIFY birth_date date AFTER email;
ALTER TABLE users_europe MODIFY birth_date date AFTER email;


-- taula per juntar les taules america i europe (amb nou field region)
CREATE TABLE IF NOT EXISTS users_all (
    id VARCHAR(15) PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(100),
    phone VARCHAR(25),
    email VARCHAR(255),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(15),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(20),
    region VARCHAR(50)
);

-- copiar la tabla users america en users all rellenando field region america
INSERT INTO users_all (
   id,name,surname,phone,email,birth_date,country,
   city,postal_code,address,signup_date,user_segment,income_band,region
)
SELECT
    id,name,surname,phone,email,birth_date,country,
    city,postal_code,address,signup_date,user_segment,income_band,
    'America'
FROM users_america;

-- copiar la tabla users europe en users all rellenando field region europe
INSERT INTO users_all (
   id,name,surname,phone,email,birth_date,country,
   city,postal_code,address,signup_date,user_segment,income_band,region
)
SELECT
    id,name,surname,phone,email,birth_date,country,
    city,postal_code,address,signup_date,user_segment,income_band,
    'Europe'
FROM users_europe;


-- creo la tabla transaction en la nueva DB sptint2db
CREATE TABLE IF NOT EXISTS transaction (
	id VARCHAR(255) PRIMARY KEY,
	card_id VARCHAR(15),
	business_id VARCHAR(20),
	product_ids INT, 
	timestamp TIMESTAMP,
	amount DECIMAL(10, 2),
	declined BOOLEAN,
	user_id VARCHAR(15),
	lat FLOAT,
	longitude FLOAT,
    discount_amount DECIMAL(10,2),
	tax_amount DECIMAL(10,2),
	shipping_amount DECIMAL(10,2),
	channel VARCHAR(20),
	campaign_id VARCHAR(50),
	device_type VARCHAR(20),
	is_international BOOLEAN,
	decline_reason VARCHAR(100),
	distance_km DECIMAL(10,2),
	FOREIGN KEY (card_id) REFERENCES credit_card(id),
	FOREIGN KEY (business_id) REFERENCES company(id),
	FOREIGN KEY (product_ids) REFERENCES products(id),
	FOREIGN KEY (user_id) REFERENCES users_all(id)
);
-- infile transaction
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__transactions.csv'
INTO TABLE transaction
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;





-- ------- consulta resultado nivel 1 Exercici 9
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
select id, name, surname from users_all
where id In (
	select user_id from transaction
	group by user_id
	having count(user_id) > 80
			);



-- Exercici 10
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

  CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__companies.csv' 
INTO TABLE companies 
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;



CREATE TABLE IF NOT EXISTS credit_card (
-- id,
    id VARCHAR(15) PRIMARY KEY,
-- user_id,
    user_id VARCHAR(15) not NULL,
-- iban,
    iban VARCHAR(34) NOT NULL,
-- pan,
    pan VARCHAR(19) NOT NULL,
-- pin,
    pin VARCHAR(6) NOT NULL,
-- cvv,
    cvv VARCHAR(4) NOT NULL,
-- track1,
    track1 VARCHAR(100),
--     %B8383712448554646^WovsxejDpwiev^86041142?7,
-- track2,
    track2 VARCHAR(100),
--    %B7653863056044187=8007163336?3,
-- expiring_date,
    expiring_date CHAR(8) NOT NULL, -- mm/dd/yy
-- card_type,
    card_type VARCHAR(25) NOT NULL,
-- card_renewal_flag
    card_renewal_flag BOOLEAN
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- 5000 rows


CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    priceDollars DECIMAL(10, 2) NOT NULL,
    colour VARCHAR(7),
    weight DECIMAL(10, 2),
    warehouse_id VARCHAR(50),
    category VARCHAR(100),
    brand VARCHAR(100),
    costDollars DECIMAL(10, 2),
    launch_date DATE
);

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_3;


ALTER TABLE transaction
MODIFY COLUMN product_ids VARCHAR(255);

-- 1. Vacía la tabla para empezar limpio
TRUNCATE TABLE products;

SHOW VARIABLES LIKE 'secure_file_priv';

ALTER TABLE transaction MODIFY product_ids VARCHAR(255) AFTER declined;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__transactions.csv'
INTO TABLE transaction
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select * from products;
select count(distinct(user_id)) from transaction; -- 5000 distinct users en t


---------------------------------------------


-- --------- Nivel 1 Exercici 10
-- Mostra la mitjana d'amoun per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
ALTER TABLE transaction
DROP FOREIGN KEY `transaction_ibfk_1`;
-- Error Code: 1701. Cannot truncate a table referenced in a foreign key constraint (`sprint2db`.`transaction`, CONSTRAINT `transaction_ibfk_1`)


CREATE TABLE IF NOT EXISTS credit_card (
-- id,
    id VARCHAR(15) PRIMARY KEY,
-- user_id,
    user_id VARCHAR(15) not NULL,
-- iban,
    iban VARCHAR(34) NOT NULL,
-- pan,
    pan VARCHAR(19) NOT NULL,
-- pin,
    pin VARCHAR(6) NOT NULL,
-- cvv,
    cvv VARCHAR(4) NOT NULL,
-- track1,
    track1 VARCHAR(100),
--     %B8383712448554646^WovsxejDpwiev^86041142?7,
-- track2,
    track2 VARCHAR(100),
--    %B7653863056044187=8007163336?3,
-- expiring_date,
    expiring_date CHAR(8) NOT NULL, -- mm/dd/yy
-- card_type,
    card_type VARCHAR(25) NOT NULL,
-- card_renewal_flag
    card_renewal_flag BOOLEAN
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- 5000 rows



ALTER TABLE transaction
ADD CONSTRAINT card_id_fk
FOREIGN KEY (card_id)
REFERENCES credit_card(id);

describe credit_card;

-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, 
-- utilitza almenys 2 taules.
select avg(amount), card_id from transaction -- cada card_id tiene un iban unico FK en credit card
where business_id = (select id from company where company_name = 'Donec Ltd') -- b-2242(Donec)
group by card_id;





-- un mismo user puede hacer compras con difrentes business_id, a q se debe?
-- Un mismo cliente puede comprar en muchas empresas distintas. 
select count(distinct iban) from credit_card; -- 5000 iban en credit card
select count(distinct id) from credit_card; -- 5000 id_card tb

select count(distinct user_id) from credit_card; -- 5000 iser_id
-- group by iban;


-- consulta ex 10 nivel 1
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit 
-- a la companyia Donec Ltd, utilitza almenys 2 taules.
select cr.iban, avg(t.amount) as "AVG(iban)",co.company_name 
from credit_card as cr -- 5000 iban en credit card
join transaction as t on t.user_id = cr.user_id
join company as co on t.business_id = co.id
where co.company_name = "Donec Ltd" -- 449 transaccions donec
group by cr.iban -- 371 ibans donec
;


