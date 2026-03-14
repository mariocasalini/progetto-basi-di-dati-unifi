DELIMITER $$
DROP PROCEDURE IF EXISTS registraNuovaPersona $$
CREATE PROCEDURE registraNuovaPersona(
    IN pNome VARCHAR(20),
    IN pCognome VARCHAR(20),
    IN pDataNascita DATE,
    IN pSesso ENUM('M','F'),
    IN pNazionalita VARCHAR(20),
    IN pEmail VARCHAR(30),
    IN pTelefono VARCHAR(10),
    IN pRuolo VARCHAR(20),
    IN pTipoContratto ENUM('determinato','indeterminato'),
    IN pCompenso DECIMAL(6,2),
    IN pDataScadenza DATE
)
BEGIN
    DECLARE vCodPersona VARCHAR(45);
    DECLARE vBaseCod VARCHAR(45);
    DECLARE vCount INT;
    DECLARE vCodContratto INT;
    DECLARE vDataScadenzaEffettiva DATE;

    IF pTipoContratto = 'indeterminato' THEN
        SET vDataScadenzaEffettiva = NULL;
    ELSE
        SET vDataScadenzaEffettiva = pDataScadenza;
    END IF;

    INSERT INTO Contratto (DataFirma, DataScadenza, Tipo, Compenso)
    VALUES (CURRENT_DATE(), vDataScadenzaEffettiva, pTipoContratto, pCompenso);
    
    SET vCodContratto = LAST_INSERT_ID();

    SET vBaseCod = CONCAT(pNome, '.', pCognome);
    
    SELECT COUNT(*) INTO vCount 
    FROM Persona 
    WHERE CodPersona LIKE CONCAT(vBaseCod, '%');
    
    SET vCodPersona = CONCAT(vBaseCod, vCount + 1);

    INSERT INTO Persona (CodPersona, Nome, Cognome, DataNascita, Sesso, Nazionalita, Email, Telefono, Contratto)
    VALUES (vCodPersona, pNome, pCognome, pDataNascita, pSesso, pNazionalita, pEmail, pTelefono, vCodContratto);

    IF pRuolo = 'Cliente' THEN
        INSERT INTO Cliente (CodCliente) VALUES (vCodPersona);
    ELSEIF pRuolo = 'Produttore' THEN
        INSERT INTO Produttore (CodProduttore) VALUES (vCodPersona);
    ELSEIF pRuolo = 'Musicista' THEN
        INSERT INTO Musicista (CodMusicista) VALUES (vCodPersona);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ruolo non valido';
    END IF;

END $$

DROP PROCEDURE IF EXISTS creaNuovoProgetto $$
CREATE PROCEDURE creaNuovoProgetto(
    IN pTitolo VARCHAR(40),
    IN pGenere VARCHAR(20),
    IN pCodCliente VARCHAR(45),
    IN pCodProduttore VARCHAR(45)
)
BEGIN
    DECLARE vNewCodProgetto INT;
    
    INSERT INTO Progetto (Titolo, Genere, DataInizio, DataFine)
    VALUES (pTitolo, pGenere, CURRENT_DATE(), NULL);

    SET vNewCodProgetto = LAST_INSERT_ID();

    INSERT INTO Creazione (Progetto, Produttore, Cliente)
    VALUES (vNewCodProgetto, pCodProduttore, pCodCliente);

END $$

DROP PROCEDURE IF EXISTS prenotaSessione $$
CREATE PROCEDURE prenotaSessione(
    IN pData DATE,
    IN pOraInizio TIME,
    IN pOraFine TIME,
    IN pCodSala VARCHAR(15),
    IN pCodStudio VARCHAR(22),
    IN pCodProgetto INT,
    IN pCodProduttore VARCHAR(45)
)
BEGIN
    DECLARE vCount INT;
    DECLARE vTariffa DECIMAL(5,2);
    DECLARE vOre DECIMAL(4,2);
    DECLARE vCosto DECIMAL(7,2);

    IF pOraInizio < '08:00:00' OR pOraFine > '19:00:00' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Orario non valido: lo studio è aperto dalle 08:00 alle 19:00';
    END IF;

    SELECT COUNT(*) INTO vCount
    FROM Sessione
    WHERE Sala = pCodSala 
      AND Studio = pCodStudio 
      AND Data = pData
      AND (
          (pOraInizio >= oraInizio AND pOraInizio < oraFine) 
          OR
          (pOraFine > oraInizio AND pOraFine <= oraFine) 
          OR
          (pOraInizio <= oraInizio AND pOraFine >= oraFine)
      );

    IF vCount > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La sala selezionata è già occupata in questo orario';
    END IF;
    
    SELECT tariffaOraria INTO vTariffa FROM Sala WHERE codSala = pCodSala AND Studio = pCodStudio;
    SET vOre = TIMESTAMPDIFF(MINUTE, pOraInizio, pOraFine) / 60.0;
    SET vCosto = IFNULL(vOre * vTariffa, 0);

    INSERT INTO Sessione (Data, oraInizio, oraFine, Studio, Sala, Progetto, Produttore, costoSessione)
    VALUES (pData, pOraInizio, pOraFine, pCodStudio, pCodSala, pCodProgetto, pCodProduttore, vCosto);

END $$

DROP PROCEDURE IF EXISTS annullaSessione $$
CREATE PROCEDURE annullaSessione(IN pCodSessione INT)
BEGIN
    DECLARE vDataSessione DATE;

    SELECT Data INTO vDataSessione
    FROM Sessione
    WHERE codSessione = pCodSessione;

    IF vDataSessione IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Sessione non trovata';
    END IF;

    IF vDataSessione <= CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Impossibile annullare sessioni passate o odierne';
    ELSE
        DELETE FROM Sessione WHERE codSessione = pCodSessione;
    END IF;

END $$
DELIMITER ;

/*CALL registraNuovaPersona(
    'Giovanni', 'Verga', '1995-05-20', 'M', 'IT', 
    'gio.verga@email.com', '3339998877', 
    'Musicista',
    'determinato', 1200.00, '2026-01-01'
);

SELECT * FROM Persona WHERE Cognome = 'Verga';
SELECT * FROM Musicista WHERE codMusicista LIKE 'Giovanni.Verga%';

CALL creaNuovoProgetto(
    'Nuovo Album Jazz', 
    'Jazz', 
    'Andrea.Gallo1',    
    'Paolo.Verdi1'    
);

SELECT * FROM Progetto ORDER BY codProgetto DESC LIMIT 1;
SELECT * FROM Creazione ORDER BY Progetto DESC LIMIT 1;

CALL prenotaSessione(
    '2025-06-01',        
    '15:00:00',          
    '17:00:00',          
    'prove1',            
    'Aurora1',           
    1,                   
    'Paolo.Verdi1'       
);

SELECT * FROM Sessione ORDER BY codSessione DESC LIMIT 1;

INSERT INTO Sessione (Data, oraInizio, oraFine, Studio, Sala, Progetto, Produttore)
VALUES ('2030-01-01', '10:00', '12:00', 'Aurora1', 'prove1', 1, 'Paolo.Verdi1');

SET @idDaCancellare = LAST_INSERT_ID();

SELECT * FROM Sessione WHERE codSessione = @idDaCancellare;

CALL annullaSessione(@idDaCancellare);

SELECT * FROM Sessione WHERE codSessione = @idDaCancellare;*/