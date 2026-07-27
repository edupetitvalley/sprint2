-- Active: 1779265955794@@127.0.0.1@3306@transactions
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

--  2.1   Llistat dels països que estan generant vendes.
-- países no solo en la tabla companies sino que también con transacciones efectuadas
select distinct c.country from company as c
join transaction as t on c.id = t.company_id; 

--  2.2   Des de quants països es generen les vendes.
select count(distinct c.country) from company as c
join transaction as t on c.id = t.company_id; --15

--     Identifica la companyia amb la mitjana més gran de vendes.
select c.company_name, round(avg(t.amount), 2)
from company as c
join transaction as t on c.id = t.company_id
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
