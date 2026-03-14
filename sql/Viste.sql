DROP VIEW IF EXISTS calendarioGiornaliero;
DROP VIEW IF EXISTS salePiuRichieste;
DROP VIEW IF EXISTS contrattiInScadenza;
DROP VIEW IF EXISTS agendaProduttori;

CREATE VIEW calendarioGiornaliero AS 
SELECT oraInizio, oraFine, Sala, Studio, Titolo AS Progetto, 
CONCAT(pers.Nome, ' ', pers.Cognome) AS produttoreResponsabile
FROM Sessione s
JOIN Progetto p ON Progetto = codProgetto
JOIN Produttore prod ON codProduttore = Produttore
JOIN Persona pers ON codPersona = codProduttore
WHERE Data = CURDATE();

CREATE VIEW salePiuRichieste AS
SELECT Sala, s.Studio, COUNT(codSessione) AS numeroPrenotazioni
FROM Sessione s
JOIN Sala sa ON codSala = Sala AND sa.Studio = s.Studio
GROUP BY Sala, s.Studio
ORDER BY numeroPrenotazioni;

CREATE VIEW contrattiInScadenza AS 
SELECT codPersona, dataScadenza
FROM Persona p
JOIN Contratto c ON Contratto = codContratto
WHERE dataScadenza IS NOT NULL AND dataScadenza BETWEEN 
CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

CREATE VIEW agendaProduttori AS
SELECT CONCAT(Nome, ' ', Cognome) AS Produttore, Titolo AS Progetto, dataInizio, dataFine
FROM Produttore prod
JOIN Persona per ON prod.codProduttore = per.codPersona
JOIN Creazione c ON prod.codProduttore = c.Produttore
JOIN Progetto p ON c.Progetto = p.codProgetto
WHERE p.dataFine >= CURDATE()
ORDER BY Produttore, dataFine;