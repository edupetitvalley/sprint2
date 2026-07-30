-- Active: 1779265955794@@127.0.0.1@3306@sprint2db
-- Nivell 1 - Ex 1 
-- Creamos la base de datos
CREATE DATABASE IF NOT EXISTS transactions;
USE transactions;
-- Creamos la tabla company
CREATE TABLE IF NOT EXISTS company (
    id VARCHAR(15) PRIMARY KEY,company_name VARCHAR(255),
    phone VARCHAR(15),email VARCHAR(100),
    country VARCHAR(100),website VARCHAR(255)
);
-- Creamos la tabla transaction
CREATE TABLE IF NOT EXISTS transaction (
    id VARCHAR(255) PRIMARY KEY,
    credit_card_id VARCHAR(15) REFERENCES credit_card(id),
    company_id VARCHAR(20),user_id INT REFERENCES user(id),
    lat FLOAT,longitude FLOAT,
    timestamp TIMESTAMP,Aamount DECIMAL(10, 2),
    declined BOOLEAN,
    FOREIGN KEY (company_id) REFERENCES company(id) 
);


-- Inserts transactions y companies del dades introduir



-- --------- Nivell 1 Exercici 2 --------------------

-- Utilitzant JOIN realitzaràs les següents consultes:
select count(declined) from transaction
-- where declined = 0; -- 99763
where declined = 1; --declined 237
--  2.1   Llistat dels països que estan generant vendes.
-- países no solo en la tabla companies sino que también con transacciones efectuadas
select distinct c.country from company as c
join transaction as t on c.id = t.company_id
where t.declined = 0; 

--  2.2   Des de quants països es generen les vendes.
select count(distinct c.country) from company as c
join transaction as t on c.id = t.company_id; -- 15

--     Identifica la companyia amb la mitjana més gran de vendes.
select c.company_name, round(avg(t.amount), 2)
from company as c
join transaction as t on c.id = t.company_id
where t.declined = 0 -- 284.91
group by t.company_id
ORDER BY avg(t.amount) DESC
limit 1;
-- b-2222	Ac Fermentum Incorporated	284.87




-- ---------  Nivell 1  Exercici 3 -------------

-- Utilitzant només subconsultes (sense utilitzar JOIN):


-- 3.1  Mostra totes les transaccions realitzades per empreses d'Alemanya. 
SELECT * from transaction
where company_id in 
    (SELECT id from company where country = "Germany")
;



-- 3.2  Llista les empreses que han realitzat transaccions per    un amount superior a la mitjana de totes les transaccions.
SELECT distinct company_name from company 
WHERE id in 
    (select company_id from transaction
    where amount > (SELECT round(AVG(amount), 2) from transaction)
    )
ORDER BY company_name; -- 100 emprersas con amount > mitjana

-- SELECT round(AVG(amount), 2) from transaction; -- avg 259.02$



--  3.3   Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
-- Las consultas con NOT IN pueden comportarse de forma inesperada si la subconsulta devuelve valores NULL.
select company_name from company
where id not in (
    select DISTINCT company_id from transaction
) ORDER BY company_name
; -- no hay companies sin transacciones




-- ------------ Nivell 1 Exercici 4 ----------------
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'
--      identificar de manera única cada targeta i 
--      establir una relació adequada amb les altres dues taules ("transaction" i "company").
USE transactions;
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY, -- varchar15 tiene hasta 15 characteres
    iban VARCHAR(34) NOT NULL,
    pan VARCHAR(19) NOT NULL,
    pin VARCHAR(6) NOT NULL,
    cvv VARCHAR(4) NOT NULL,
    expiring_date CHAR(8) NOT NULL -- Guarda '12/29'
)

-- Després de crear la taula serà necessari que 
--      ingressis la informació del document denominat "dades_introduir_credit".

--fem els inserts de les targetes desde el fitxer N1-Ex.4__ datos_introducir_credit


-- també he hagut de modificar la taula transaction 
-- 			para q la credit_card_id sea foreign key
ALTER TABLE transaction 
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id); 

-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.


-- ----------- Nivell 1 Ex 5 ---------------

-- 5.1 El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
update credit_card 
set iban = "TR323456312213576817699999"
where id="CcU-2938";



-- 
-- ----------- Nivell 1 Ex 6 ---------------
-- Exercici 6
-- En la taula "transaction" ingressa una nova transacció amb la següent informació:

-- Id ,108B1D1D-5B23-A76C-55EF-C568E49A99DD ,credit_card_id ,CcU-9999 ,company_id ,b-9999 ,user_id ,9999 ,lat ,829.999 ,longitude ,-117.999 ,amount ,111.11 ,declined ,0 

-- Le pedimos los datos de la compañia q figura en la transaccion ya q aun no esta registrada en la tabla de compañias
INSERT INTO company ( id, company_name, phone, email, country, website
)
VALUES ( 'B-9999', 'Empresa Prueba S.L.', '+34931234567', 'contacto@empresaprueba.com', 'España', 'https://www.empresaprueba.com'
);

-- le pedimos tambien los datos de la targeta de credito
INSERT INTO credit_card ( id, iban, pan, pin, cvv, expiring_date
)
VALUES (
    'CcU-9999',
    'ES9121000418450200051332',
    '4532015112830366',
    '1234',
    '321',
    '08/24/25'
);

-- ahora ya podemos hacer el insert de la transaccion
INSERT INTO transaction 
(id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES 
('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,829.999,-117.999,CURRENT_TIMESTAMP,111.11,0);




-- Exercici 7
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.


alter table credit_card drop column pan;




-- Active: 1779265955794@@127.0.0.1@3306@sprint2db
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
    where declined=0
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

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__products.csv' 
INTO TABLE products 
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
    id VARCHAR(15) PRIMARY KEY,
    user_id VARCHAR(15) not NULL,
    iban VARCHAR(34) NOT NULL,
    pan VARCHAR(19) NOT NULL,
    pin VARCHAR(6) NOT NULL,
    cvv VARCHAR(4) NOT NULL,
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date CHAR(8) NOT NULL, -- mm/dd/yy
    card_type VARCHAR(25) NOT NULL,
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




-- Nivell 2
-- Exercici 1

-- Identifica els cinc dies que es va generar la quantitat més gran 
-- d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.
select SUM(amount), date(timestamp) from transaction
group by date(timestamp)
order by SUM(amount) desc
limit 5
;

select sum(amount), date(timestamp),
 RANK() OVER (
    ORDER BY sum(amount) DESC
    ) AS ranking
from transaction
group by date(timestamp)
order by sum(amount) desc
-- limit 5
;



-- Exercici 2
-- Presenta el nom, telèfon, país, data i amount, 
-- d'aquelles empreses que van realitzar transaccions amb
-- un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
-- 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
-- Ordena els resultats de major a menor quantitat.
select co.company_name, co.phone, co.country, date(t.timestamp),t.amount
from transaction as t
join company as co on co.id = t.business_id
where (t.amount between 350 and 400)
	and date(t.timestamp) in ('2015-04-29', '2018-07-20', '2024-03-13')
order by t.amount;



-- Exercici 3
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa  que es requereixi, per la qual cosa et demanen la informació sobre 
-- la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de 
-- les empreses on especifiquis si tenen igual o més de 400 transaccions o menys.
select co.company_name, count(t.business_id) as count_transactions,
CASE
    WHEN count(t.business_id) > 400 THEN "Más"
    WHEN count(t.business_id) = 400 THEN "Igual"
    ELSE "Menos"
END as "400 Transacc"
from transaction as t
join company as co on co.id = t.business_id
group by t.business_id;


-- Exercici 4
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD 
-- de la base de dades.
select * FROM transaction
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";
DELETE FROM transaction
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";


-- Exercici 5
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la 
-- següent informació: Nom de la companyia. Telèfon de contacte. País de residència. 
-- Mitjana de compra realitzat per cada companyia. 
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
-- Exercici 5
create view VistaMarketing as 
	select co.company_name, co.phone, co.country, round(avg(t.amount), 2) as AVG_amount
	from transaction as t
	join company as co on t.business_id = co.id
	group by t.business_id
	order by avg_amount desc;
select * from VistaMarketing;

-- drop view VistaMarketing;


-- Nivell 3
-- Exercici 1
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat 
-- en si les tres últimes transaccions han estat declinades aleshores és inactiu, 
-- si almenys una no és rebutjada aleshores és actiu. 


select card_id, sum(declined) as numDeclined
, CASE 
    WHEN (sum(declined) < 3) THEN "ACTIVE"  
    ELSE  "INACTIVE" 
    END as "STATE CARD"	
 from (
	SELECT card_id, date(timestamp) ,
		ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY TIMESTAMP DESC) AS row_num, declined
		FROM transaction
					) as sub
where row_num <= 3
group by card_id
order by sum(declined) desc;

-- CREATE TABLE IF NOT EXISTS credit_card_state (
 --    id VARCHAR(15) PRIMARY KEY,
--     iban VARCHAR(34) NOT NULL,
--     pan VARCHAR(19) NOT NULL,
--     expiring_date CHAR(8) NOT NULL
-- );


-- Partint d’aquesta taula respon:
-- 👉 Quantes targetes estan actives?

-- Exercici 2

-- Crea una taula amb la qual puguem unir les dades de l'arxiu de products.csv amb la base de dades creada (ja que fins ara no podíem fer-ho), tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- 👉 Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

-- Recursos
-- Objectius

--     Construir una base de dades relacional senzilla amb MySQL.
--     Realitzar consultes únicament amb JOIN..
--     Crear subconsultes SQL per a mostrar informació sense l'ús de JOIN.


ALTER TABLE products MODIFY COLUMN priceDollars VARCHAR(20);
ALTER TABLE products MODIFY COLUMN costDollars VARCHAR(20);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


UPDATE products SET priceDollars = REPLACE(priceDollars, '$', '');
UPDATE products SET costDollars = REPLACE(costDollars, '$', '');

update transaction set product_ids = replace(product_ids, " ,", ",")

update transaction set product_ids = replace(product_ids, ", ", ",");
-- 👉 Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
use sprint2db;
CREATE TABLE transaction_products (
    transaction_id VARCHAR(255) NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (transaction_id, product_id)
);

-- subconsulta para obtener los datos con los que rellenar la tabla puente
-- SELECT
--     t.card_id, t.id,
--     t.product_ids,
--     p.id
-- FROM transaction t
-- CROSS JOIN products p
-- WHERE FIND_IN_SET(p.id, t.product_ids)
-- ;

-- ¿qué comando DML permite insertar el resultado de un SELECT dentro de una tabla existente?
INSERT INTO transaction_products(transaction_id, product_id) 
	SELECT t.id,
		p.id
	FROM transaction t
	CROSS JOIN products p
	WHERE FIND_IN_SET(p.id, t.product_ids)
;

DESCRIBE transaction_products;

SELECT product_id, count(product_id) as unidades_vendidas from transaction_products
GROUP BY product_id
ORDER BY unidades_vendidas DESC;