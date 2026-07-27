
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










