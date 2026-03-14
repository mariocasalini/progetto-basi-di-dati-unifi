-- Imposta l'orario della sessione a una data specifica fissa fino a che non si chiude MYSQL Workbench
SET TIMESTAMP = UNIX_TIMESTAMP('2025-12-01 12:00:00');

INSERT INTO Studio
(codStudio, Nome, Via, Civico, Citta, CAP, email, telefono)
VALUES
('Aurora1','Aurora','Via Verdi','12','Milano','20121','info@aurorastudio.it','0287654321'),
('Echo1','Echo','Via Dante','5','Bologna','40121','contatti@echolab.it','0511234567'),
('Nova1','Nova','Via Roma','20','Torino','10121','studio@novarecords.it','0117654321');


INSERT INTO Sala
(codSala, Studio, Tipologia, tariffaOraria, livTrattamentoAcustico)
VALUES
('prove1','Aurora1','prove',50.00,'alto'),
('registrazione1','Aurora1','registrazione',70.00,'basso'),
('prove1','Echo1','prove',60.00,'medio'),
('prove2','Echo1','prove',65.00,'alto'),
('consulenza1','Nova1','consulenza',45.00,'medio');


INSERT INTO Progetto
(codProgetto, Titolo, Genere, dataInizio, dataFine, costoTotale)
VALUES
(1, 'Cuore di latta','Rock','2025-10-01','2026-03-30', 340.00),
(2, 'Dolce Amaro','Pop','2025-11-15','2026-05-15', 375.00),
(3, 'Anima','Elettronica','2025-11-01','2026-02-01', 90.00),
(4, 'Podcast True Crime','Podcast','2025-09-01','2026-09-30', 0.00);


INSERT INTO Contratto
(CodContratto,dataFirma,dataScadenza,Tipo,Compenso)
VALUES
(1,'2024-12-15','2025-12-15','determinato',3000.00),
(2,'2024-11-15', NULL,'indeterminato',2800.00),
(3,'2024-12-28','2025-12-28','determinato',8000.00),
(4,'2024-09-20', NULL,'indeterminato',5200.00),
(5,'2025-01-10','2026-01-10','determinato',2800.00),
(6,'2024-08-10', NULL,'indeterminato',5200.00),
(7,'2025-02-15','2026-02-15','determinato',4500.00),
(8,'2024-11-01', NULL,'indeterminato',1500.00);


INSERT INTO Persona
(codPersona, Nome, Cognome, dataNascita, Sesso, Nazionalita,
 Email, Telefono, Contratto)
VALUES
('Marco.Rossi1','Marco','Rossi','1990-03-12','M','IT',
 'marco.rossi@example.com','3331112233', 1),
('Lucia.Bianchi1','Lucia','Bianchi','1992-07-08','F','IT',
 'lucia.bianchi@example.com','3332223344', 2),
('Paolo.Verdi1','Paolo','Verdi','1985-01-25','M','IT',
 'paolo.verdi@example.com','3333334455', 3),
('Francesca.Neri1','Francesca','Neri','1983-05-30','F','IT',
 'francesca.neri@example.com','3334445566', 4),
('Andrea.Gallo1','Andrea','Gallo','1988-09-14','M','IT',
 'andrea.gallo@example.com','3335556677', 5),
('Chiara.Fontana1','Chiara','Fontana','1995-11-22','F','IT',
 'chiara.fontana@example.com','3336667788', 6),
('Luca.Moretti1','Luca','Moretti','1993-02-18','M','IT',
 'luca.moretti@example.com','3337778899', 7),
('Giulia.Ferri1','Giulia','Ferri','1994-04-05','F','IT',
 'giulia.ferri@example.com','3338889900', 8);


INSERT INTO Musicista (codMusicista) VALUES
('Marco.Rossi1'),
('Lucia.Bianchi1'),
('Luca.Moretti1'),
('Giulia.Ferri1');

INSERT INTO Produttore (codProduttore) VALUES
('Paolo.Verdi1'),
('Francesca.Neri1');

INSERT INTO Cliente (codCliente) VALUES
('Andrea.Gallo1'),
('Chiara.Fontana1');


INSERT INTO Sessione
(codSessione, Data, oraInizio, oraFine, Studio, Sala, Progetto, Produttore, costoSessione)
VALUES
(1, '2025-12-01', '09:00', '11:00', 'Aurora1', 'prove1', 1, 'Paolo.Verdi1', 100.00),
(2, '2025-12-01', '11:30', '13:30', 'Aurora1', 'prove1', 1, 'Paolo.Verdi1', 100.00),
(3, '2025-12-01', '15:00', '18:00', 'Aurora1', 'registrazione1', 1, 'Paolo.Verdi1', 210.00),
(4, '2025-12-02', '09:00', '12:00', 'Echo1', 'prove1', 2, 'Francesca.Neri1', 180.00),
(5, '2025-12-02', '14:00', '17:00', 'Echo1', 'prove2', 2, 'Francesca.Neri1', 195.00),
(6, '2025-12-03', '10:00', '12:00', 'Nova1', 'consulenza1', 3,'Paolo.Verdi1', 90.00);



INSERT INTO Traccia
(codTraccia, Nome, Versione, Tipo, Durata)
VALUES
(1,'Luci di Città', '1.0','jam',210),
(2,'Luci di Città', '1.1','jam',205),
(3,'Onda', '1.0', 'take', 240),
(4,'La notte', '1.0','mix',180),
(5,'La notte', '1.1','master',195),
(6,'Emozioni', '1.0','take', 185);


INSERT INTO Registrazione
(Traccia, Sessione)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6);


INSERT INTO Strumento
(codStrumento, Nome, Categoria)
VALUES
('Chitarra1','Chitarra','Corde'),
('Basso1','Basso','Corde'),
('Batteria1','Batteria','Percussioni'),
('Piano1','Piano','Tastiere'),
('Sintetizzatore1','Sintetizzatore','Tastiere');


INSERT INTO Utilizzo
(Sessione, Musicista, Strumento)
VALUES
(1,'Marco.Rossi1','Chitarra1'),
(1,'Lucia.Bianchi1','Basso1'),
(2,'Lucia.Bianchi1','Basso1'),
(2,'Giulia.Ferri1','Batteria1'),
(3,'Luca.Moretti1','Piano1'),
(3,'Marco.Rossi1','Chitarra1'),
(4,'Marco.Rossi1','Chitarra1'),
(4,'Giulia.Ferri1','Batteria1'),
(5,'Lucia.Bianchi1','Basso1'),
(6,'Luca.Moretti1','Sintetizzatore1');


INSERT INTO Richiesta
(Cliente, Sessione)
VALUES
('Andrea.Gallo1', 1),
('Andrea.Gallo1', 2),
('Andrea.Gallo1', 3),
('Chiara.Fontana1', 4),
('Chiara.Fontana1', 5),
('Andrea.Gallo1', 6);


INSERT INTO Creazione
(Progetto, Produttore, Cliente)
VALUES
(1, 'Paolo.Verdi1','Andrea.Gallo1'),
(2, 'Francesca.Neri1','Chiara.Fontana1'),
(3, 'Paolo.Verdi1','Andrea.Gallo1');