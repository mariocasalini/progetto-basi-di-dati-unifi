/* 1. Visualizzare nome, cognome e compenso di tutte le persone che hanno 
   sottoscritto un contratto di tipo 'Indeterminato'.*/
SELECT P.Nome, P.Cognome, C.Compenso
FROM Persona P
JOIN Contratto C ON P.Contratto = C.codContratto
WHERE C.Tipo = 'indeterminato';

/* 2. Trovare titolo e genere dei progetti supervisionati dal produttore 'Paolo Verdi'.*/
SELECT Pe.Nome, Pe.Cognome, GROUP_CONCAT(Pr.Titolo SEPARATOR ', ') AS ProgettiSupervisionati
FROM Progetto Pr
JOIN Creazione Cr ON Pr.codProgetto = Cr.Progetto
JOIN Produttore Prod ON Cr.Produttore = Prod.codProduttore
JOIN Persona Pe ON Prod.codProduttore = Pe.codPersona
WHERE Pe.Nome = 'Paolo' AND Pe.Cognome = 'Verdi'
GROUP BY Pe.Nome, Pe.Cognome;

/* 3. Contare quanti strumenti sono registrati nel sistema per ogni categoria 
   (es. quante chitarre, quante batterie, ecc.).*/
SELECT Categoria, COUNT(*) AS NumeroStrumenti
FROM Strumento
GROUP BY Categoria;

/* 4. Elencare le sessioni di lavoro che sono durate più di 2 ore, mostrando la data e la durata calcolata, ordinate dalla più recente alla meno recente.*/
SELECT Data, TIMEDIFF(oraFine, oraInizio) AS DurataEffettiva
FROM Sessione
WHERE TIMESTAMPDIFF(HOUR, oraInizio, oraFine) > 2
ORDER BY Data DESC;

/* 5. Visualizzare il nome degli studi che hanno un numero sessioni superiore alla media delle sessioni per studio.*/
SELECT St.Nome, COUNT(S.codSessione) AS TotaleSessioni
FROM Studio St
JOIN Sessione S ON St.codStudio = S.Studio
GROUP BY St.Nome
HAVING TotaleSessioni > (
    SELECT AVG(NumSessioni)
    FROM (
        SELECT COUNT(codSessione) as NumSessioni
        FROM Sessione
        GROUP BY Studio
    ) AS MediaSessioni 
);

/* 6. Elencare nome e cognome dei musicisti che hanno suonato strumenti della categoria 'Tastiere', ma solo se il loro contratto prevede 
un compenso superiore alla media dei compensi.*/
SELECT DISTINCT P.Nome, P.Cognome
FROM Persona P
JOIN Musicista M ON P.codPersona = M.codMusicista
JOIN Contratto C ON P.Contratto = C.codContratto
JOIN Utilizzo U ON M.codMusicista = U.Musicista
JOIN Strumento S ON U.Strumento = S.codStrumento
WHERE S.Categoria = 'Tastiere'
AND C.Compenso > (
    SELECT AVG(C2.Compenso)
    FROM Contratto C2
    JOIN Persona P2 ON C2.codContratto = P2.Contratto
    JOIN Musicista M2 ON P2.codPersona = M2.codMusicista
);