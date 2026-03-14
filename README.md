# 🎛️ Record Label DBMS: Gestione DataBase Studi di Registrazione

Questo progetto presenta la progettazione e l'implementazione in **MySQL** di un Database Management System (DBMS) relazionale per una grande etichetta discografica. 

Il sistema gestisce a 360 gradi l'operatività aziendale: anagrafiche del personale (tramite ereditarietà), contrattualistica, prenotazione delle sale di registrazione, allocazione degli strumenti e monitoraggio in tempo reale dei costi di progetto.

L'obiettivo principale del progetto è dimostrare come implementare **logiche di business complesse**, vincoli di dominio rigidi e **denormalizzazioni controllate** direttamente a livello di database, garantendo la massima integrità dei dati senza dipendere dal livello applicativo (Backend).

---

## 🚀 Competenze Tecniche Evidenziate

Questo database non è un semplice archivio di dati, ma un sistema reattivo. Ecco le architetture e le tecniche SQL avanzate implementate:

### 1. Gestione dell'Integrità e Prevenzione Conflitti (Triggers)
Il sistema utilizza **11 Trigger** per far rispettare i vincoli aziendali:
* **Controllo Sovrapposizioni Temporali:** I trigger `controlloPrenotazione_insert` e `_update` bloccano dinamicamente la prenotazione di una sala se risulta già occupata nel medesimo intervallo orario, o se la richiesta è fuori dall'orario lavorativo (08:00 - 19:00).
* **Gestione Risorse Umane:** I trigger della famiglia `controlloPartecipazioneSimultanea` (per Produttori, Musicisti e Clienti) impediscono che la stessa persona venga assegnata a due sessioni che si svolgono in parallelo.
* **Denormalizzazione Controllata (Ottimizzazione Letture):** Per evitare calcoli pesanti in fase di reportistica, l'attributo `costoTotale` nella tabella `Progetto` viene aggiornato in tempo reale dai trigger `aggiornamentoCostoProgetto` (su INSERT, UPDATE e DELETE della tabella `Sessione`), scartando dal calcolo le sessioni passate in caso di cancellazione.

### 2. Automazione dei Processi (Stored Procedures)
Sono state scritte procedure per incapsulare operazioni complesse che richiedono inserimenti multipli e verifiche:
* `registraNuovaPersona`: Gestisce l'onboarding di un nuovo collaboratore. Crea il contratto, assegna il ruolo (Cliente, Produttore o Musicista) e genera dinamicamente un ID univoco aziendale (es. `Nome.Cognome1`).
* `prenotaSessione`: Calcola in automatico le ore richieste calcolando la differenza tra orari (`TIMESTAMPDIFF`), recupera la tariffa della sala, calcola il costo e inserisce la sessione solo se tutti i vincoli sono rispettati.

### 3. Logica di Calcolo Dinamica (User-Defined Functions)
Per i calcoli ricorrenti sono state implementate funzioni deterministiche:
* `calcoloCostoSessione`: Restituisce il costo esatto incrociando i dati temporali della prenotazione con il listino prezzi della specifica sala.
* `calcolaSpesaTotaleCliente`: Un aggregatore che calcola il fatturato generato da un singolo cliente su tutti i suoi progetti.

### 4. Cruscotti Aziendali (Views)
Sono state create 4 viste per la reportistica e l'operatività quotidiana:
* `calendarioGiornaliero`: Dashboard per le sessioni odierne (Sale, Progetti, Produttori associati).
* `contrattiInScadenza`: Vista per le Risorse Umane che filtra in automatico i contratti in scadenza nei successivi 30 giorni usando la funzione `DATE_ADD(CURDATE(), INTERVAL 30 DAY)`.
* Altre viste includono `agendaProduttori` e l'analisi statistica `salePiuRichieste`.

### 5. DQL Avanzato (Querying)
Il file delle interrogazioni dimostra la padronanza del Data Query Language (DQL) tramite:
* Sotto-query annidate per calcolare medie dinamiche (es. `SELECT AVG()`) da usare come filtro in clausole `WHERE` o `HAVING`.
* Funzioni di aggregazione avanzate come `GROUP_CONCAT` per unire più record in una singola stringa leggibile.
* Calcoli sulle date/ore integrati nelle query (`TIMEDIFF`, `TIMESTAMPDIFF`).

---

## 📂 Struttura della Repository

Per garantire ordine e modularità, il codice è stato diviso in file logici:

- `studioDiRegistrazione.sql`: Script DDL primario. Genera lo schema relazionale composto da 15 tabelle, applicando vincoli `PRIMARY KEY` multipli e `FOREIGN KEY` con politiche di `CASCADE` e `RESTRICT` adeguate.
- `Trigger.sql`: Script contenente l'implementazione dei controlli di integrità e business rules.
- `Funzioni.sql` e `Procedure.sql`: Script per la logica di calcolo e l'automazione delle transazioni.
- `Viste.sql`: Tabelle virtuali per l'interrogazione rapida e la reportistica.
- `popolamentoStudioDiRegistrazione.sql`: Script DML con dati fittizi realistici (mock data) per testare le funzionalità del database.
- `Interrogazioni.sql`: Una suite di query complesse che rispondono a specifiche domande di business.

---

## ⚙️ Istruzioni per l'installazione locale

Se desideri clonare e testare il database in locale (ad es. su MySQL Workbench), esegui gli script seguendo rigorosamente questo ordine per evitare errori legati all'integrità referenziale:

1. Esegui `studioDiRegistrazione.sql`
2. Esegui `Funzioni.sql` e `Procedure.sql`
3. Esegui `Trigger.sql`
4. Esegui `Viste.sql`
5. Esegui `popolamentoStudioDiRegistrazione.sql`
6. (Opzionale) Testa il sistema eseguendo le query presenti in `Interrogazioni.sql`.

> **💡 Nota sul Timestamp:** Nello script di popolamento è stato inserito il comando `SET TIMESTAMP = UNIX_TIMESTAMP('2025-12-01 12:00:00');`. Questo fissa la data del server al 1° Dicembre 2025, permettendo di testare viste come "contratti in scadenza in 30 giorni" e le interrogazioni in modo coerente e prevedibile nel tempo.
