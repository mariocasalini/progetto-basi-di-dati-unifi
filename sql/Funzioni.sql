DROP FUNCTION IF EXISTS calcoloCostoSessione;
DROP FUNCTION IF EXISTS calcolaSpesaTotaleCliente;

DELIMITER $$
CREATE FUNCTION calcoloCostoSessione(codiceSessione INT)
RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
DECLARE Tariffa DECIMAL (5,2);
DECLARE Inizio TIME;
DECLARE Fine TIME;
DECLARE orePrenotate DECIMAL (4,2);
DECLARE costo DECIMAL (6,2);
SET tariffa = (
SELECT tariffaOraria
FROM Sala s
JOIN Sessione se ON se.Sala = codSala AND se.Studio = s.Studio
WHERE se.codSessione = codiceSessione);
SET Inizio = (SELECT oraInizio FROM Sessione s WHERE s.codSessione = codiceSessione);
SET Fine = (SELECT oraFine FROM Sessione s WHERE s.codSessione = codiceSessione);
SET orePrenotate = TIMESTAMPDIFF(SECOND, Inizio, Fine) / 3600.0;
SET costo = orePrenotate * tariffa;
IF costo IS NULL THEN 
SET costo =0;
END IF;
RETURN costo;
END $$
DELIMITER ;

/*SELECT codSessione, calcoloCostoSessione(codSessione) AS Costo
FROM Sessione;*/
DELIMITER $$
CREATE FUNCTION calcolaSpesaTotaleCliente(codiceCliente VARCHAR(45))
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
DECLARE Tot DECIMAL(8,2);
SET Tot = (SELECT SUM(costoTotale) FROM Progetto JOIN Creazione ON codProgetto = Progetto AND Cliente = codiceCliente);
IF Tot IS NULL THEN
SET Tot = 0;
END IF;
RETURN Tot;
END $$
DELIMITER ;

/*SELECT codCliente, calcolaSpesaTotaleCliente(codCliente) AS SpesaTotale
FROM Cliente;*/
