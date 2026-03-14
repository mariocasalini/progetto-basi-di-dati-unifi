DROP TRIGGER IF EXISTS controlloPrenotazione_insert;
DROP TRIGGER IF EXISTS controlloPrenotazione_update;
DROP TRIGGER IF EXISTS aggiornamentoCostoProgetto_insert;
DROP TRIGGER IF EXISTS aggiornamentoCostoProgetto_update;
DROP TRIGGER IF EXISTS aggiornamentoCostoProgetto_delete;
DROP TRIGGER IF EXISTS controlloDurataTraccia;
DROP TRIGGER IF EXISTS controlloPartecipazioneSimultanea_produttore;
DROP TRIGGER IF EXISTS controlloPartecipazioneSimultanea_musicista;
DROP TRIGGER IF EXISTS controlloPartecipazioneSimultanea_cliente;
DROP TRIGGER IF EXISTS controlloDataScadenzaIndeterminato_insert;
DROP TRIGGER IF EXISTS controlloDataScadenzaIndeterminato_update;

DELIMITER $$

/* 1.1) controlloPrenotazione_insert: 
	  - prima di inserire una sessione lancia un errore se la sala é occupata. 
      - impedisce l’inserimento di sessioni fuori orario di apertura. 
*/
CREATE TRIGGER controlloPrenotazione_insert 
BEFORE INSERT ON Sessione FOR EACH ROW 	
BEGIN
	IF EXISTS (
		SELECT 1
        FROM Sessione s
        WHERE s.Studio = NEW.Studio
        AND s.Sala = NEW.Sala 
        AND s.Data = NEW.Data
		AND NEW.oraInizio < s.oraFine
		AND NEW.oraFine   > s.oraInizio
    ) THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'INSERT ERROR: la sala è già occupata in questo intervallo orario';
    END IF;
    
    IF (NEW.oraInizio < '08:00:00') THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'INSERT ERROR: la sessione inizia prima dell orario di apertura (08:00)';
    END IF;
    IF (NEW.oraFine > '19:00:00') THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'INSERT ERROR: la sessione finisce dopo l orario di chiusura (19:00)';
    END IF;
    IF (NEW.oraFine <= NEW.oraInizio) THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'INSERT ERROR: la sessione deve avere una durata positiva';
    END IF;
END $$



/* 1.2) controlloPrenotazione_update: 
	  - prima di modificare una sessione lancia un errore se la sala é occupata.
	  - impedisce l’aggiornamento di sessioni fuori orario di apertura. 
*/
CREATE TRIGGER controlloPrenotazione_update
BEFORE UPDATE ON Sessione FOR EACH ROW
BEGIN
IF EXISTS (
    SELECT 1
        FROM Sessione s
        WHERE s.Studio = NEW.Studio
        AND s.Sala = NEW.Sala 
        AND s.Data = NEW.Data
		AND NEW.oraInizio < s.oraFine
		AND NEW.oraFine > s.oraInizio
        AND OLD.codSessione <> s.codSessione
    ) THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'UPDATE ERROR: la sala è già occupata in questo intervallo orario';
    END IF;
    
    IF (NEW.oraInizio < '08:00:00') THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'UPDATE ERROR: la sessione inizia prima dell orario di apertura (08:00)';
    END IF;
    IF (NEW.oraFine > '19:00:00') THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'UPDATE ERROR: la sessione finisce dopo l orario di chiusura (19:00)';
    END IF;
    IF (NEW.oraFine <= NEW.oraInizio) THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'UPDATE ERROR: la sessione deve avere una durata positiva';
    END IF;
END $$



/* 2.1) aggiornamentoCostoProgetto_insert: 
	  dopo inserimento sessione aggiorna costo totale in progetto.
*/
CREATE TRIGGER aggiornamentoCostoProgetto_insert 
AFTER INSERT ON Sessione FOR EACH ROW 
BEGIN
	IF (NEW.Progetto IS NOT NULL) THEN
		UPDATE Progetto
		SET costoTotale = IFNULL(costoTotale, 0) + IFNULL(NEW.costoSessione, 0)
		WHERE codProgetto = NEW.Progetto;
    END IF;
END $$

/* 2.2) aggiornamentoCostoProgetto_update: 
	    se aggiorno una sessione aggiorna il costo del progetto a meno che non sia una sessione passata.
*/
CREATE TRIGGER aggiornamentoCostoProgetto_update
AFTER UPDATE ON Sessione FOR EACH ROW
BEGIN
    IF (OLD.Progetto IS NOT NULL) THEN
        UPDATE Progetto
        SET costoTotale = IFNULL(costoTotale, 0) - IFNULL(OLD.costoSessione, 0)
        WHERE codProgetto = OLD.Progetto;
    END IF;

    IF (NEW.Progetto IS NOT NULL) THEN
        UPDATE Progetto
        SET costoTotale = IFNULL(costoTotale, 0) + IFNULL(NEW.costoSessione, 0)
        WHERE codProgetto = NEW.Progetto;
    END IF;
END $$


/* 2.3) aggiornamentoCostoProgetto_delete: 
	    se cancello una sessione scala il costo del progetto a meno che non sia una sessione passata.
*/
CREATE TRIGGER aggiornamentoCostoProgetto_delete
AFTER DELETE ON Sessione FOR EACH ROW
BEGIN
	IF (OLD.Progetto IS NOT NULL) THEN
		IF (TIMESTAMP(OLD.Data, OLD.oraFine) >= NOW()) THEN
			UPDATE Progetto
            SET costoTotale = IFNULL(costoTotale, 0) - IFNULL(OLD.costoSessione, 0)
            WHERE codProgetto = OLD.Progetto;
        END IF;
	END IF;
END $$



/* 3) controlloDurataTraccia:
	  impedisce inserimento di una traccia con durata minore o uguale a 0
*/
CREATE TRIGGER controlloDurataTraccia
BEFORE INSERT ON Traccia FOR EACH ROW
BEGIN
    -- Durata non deve essere NULL o <= 0
    IF ((NEW.Durata IS NULL) OR (NEW.Durata <= 0)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'INSERT ERROR: la durata della traccia deve essere un valore positivo';
    END IF;
END $$



/* 4.1) controlloPartecipazioneSimultanea_produttore:
	    verifica che un produttore non sia in due sessioni contemporaneamente.
*/
CREATE TRIGGER  controlloPartecipazioneSimultanea_produttore
BEFORE INSERT ON Sessione FOR EACH ROW
BEGIN
    IF EXISTS (
		SELECT 1
        FROM Sessione s
        WHERE s.Produttore = NEW.Produttore
        AND s.Data = NEW.Data
        AND NEW.oraInizio < s.oraFine
        AND NEW.oraFine > s.oraInizio
    ) THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'INSERT ERROR: il produttore è già impegnato in un altra sessione';
	END IF;
END $$



/* 4.2) controlloPartecipazioneSimultanea_musicista:
	    verifica che un musicista non sia in due sessioni contemporaneamente.
*/
CREATE TRIGGER controlloPartecipazioneSimultanea_musicista
BEFORE INSERT ON Utilizzo FOR EACH ROW
BEGIN
	IF (NEW.Sessione IS NULL) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'ERROR: deve essere specificata una sessione';
    END IF;
    IF EXISTS (
		SELECT 1
        FROM Utilizzo u
        JOIN Sessione s1 ON s1.codSessione = u.Sessione
        JOIN Sessione s2 ON s2.codSessione = NEW.Sessione
        WHERE u.Musicista = NEW.Musicista
              AND u.Sessione <> NEW.Sessione       
              AND s1.Data = s2.Data                
              AND s1.oraInizio < s2.oraFine       
              AND s1.oraFine   > s2.oraInizio
    ) THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'INSERT ERROR: il musicista è già impegnato in un altra sessione';
    END IF;
END $$



/* 4.3) controlloPartecipazioneSimultanea_cliente:
	    verifica che un cliente non sia in due sessioni contemporaneamente.
*/
CREATE TRIGGER controlloPartecipazioneSimultanea_cliente
BEFORE INSERT ON Richiesta FOR EACH ROW
BEGIN
	IF (NEW.Sessione IS NULL) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'ERROR: deve essere specificata una sessione';
    END IF;
	IF EXISTS (
            SELECT 1
            FROM Richiesta r
            JOIN Sessione s1 ON s1.codSessione = r.Sessione   
            JOIN Sessione s2 ON s2.codSessione = NEW.Sessione 
            WHERE r.Cliente = NEW.Cliente
              AND r.Sessione <> NEW.Sessione
              AND s1.Data = s2.Data
              AND s1.oraInizio < s2.oraFine
              AND s1.oraFine   > s2.oraInizio
        ) THEN 
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'INSERT ERROR: il cliente è già impegnato in un altra sessione';
        END IF;
END $$



/* 5.1) controlloDataScadenzaIndeterminato_insert: 
	  se tipo nel contratto inserito é indeterminato forza data scadenza null.
*/
CREATE TRIGGER controlloDataScadenzaIndeterminato_insert
BEFORE INSERT ON Contratto FOR EACH ROW
BEGIN
	IF (NEW.Tipo = 'indeterminato') THEN
		SET NEW.dataScadenza = NULL;
	END IF;
END $$



/* 5.2) controlloDataScadenzaIndeterminato_update:
       se tipo nel contratto aggiornato é indeterminato forza data scadenza null.
*/
CREATE TRIGGER controlloDataScadenzaIndeterminato_update
BEFORE UPDATE ON Contratto
FOR EACH ROW
BEGIN
    IF (NEW.Tipo = 'indeterminato') THEN
        SET NEW.dataScadenza = NULL;
    END IF;
END $$

DELIMITER ;