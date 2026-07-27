

-- Nivell 2
-- Exercici 1

-- Identifica els cinc dies que es va generar la quantitat més gran 
-- d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.
select avg(amount), date(timestamp) from transaction
group by date(timestamp)
order by avg(amount) desc
limit 5
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
where (t.amount >= 350 and t.amount <= 400)
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

