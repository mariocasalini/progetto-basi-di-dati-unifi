DROP DATABASE IF EXISTS studiodiregistrazione;
CREATE DATABASE IF NOT EXISTS studiodiregistrazione;
USE studiodiregistrazione;

CREATE TABLE IF NOT EXISTS Studio(
codStudio VARCHAR(22) PRIMARY KEY,
Nome VARCHAR(20) NOT NULL,
Via VARCHAR(20),
Civico VARCHAR(3),
Citta VARCHAR(20),
CAP VARCHAR(5),
Email VARCHAR(30),
Telefono VARCHAR(10)
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Sala(
codSala VARCHAR(15),
Studio VARCHAR(22),
Tipologia ENUM("registrazione","prove","consulenza") NOT NULL,
tariffaOraria DECIMAL(5,2),
livTrattamentoAcustico ENUM("basso","medio","alto"),
PRIMARY KEY(codSala,Studio),
FOREIGN KEY (Studio) REFERENCES Studio(codStudio) ON DELETE CASCADE 
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Traccia(
codTraccia INT AUTO_INCREMENT PRIMARY KEY,
Nome VARCHAR(20),
Versione VARCHAR(3),
Tipo ENUM("mix","take","master","jam","podcast"),
Durata INT
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Progetto(
codProgetto INT AUTO_INCREMENT PRIMARY KEY,
Titolo VARCHAR(40),
Genere VARCHAR(20),
dataInizio DATE,
dataFine DATE,
costoTotale DECIMAL(8,2)
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Strumento(
codStrumento VARCHAR(17) PRIMARY KEY,
Nome VARCHAR(15) NOT NULL,
Categoria VARCHAR(15)
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Contratto(
codContratto INT PRIMARY KEY AUTO_INCREMENT,
dataFirma DATE,
dataScadenza DATE,
Tipo ENUM("determinato","indeterminato"),
Compenso DECIMAL(6,2)
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Persona(
codPersona VARCHAR(45) PRIMARY KEY,
Nome VARCHAR(20) NOT NULL,
Cognome VARCHAR(20) NOT NULL,
dataNascita DATE,
Sesso ENUM("M","F"),
Nazionalita VARCHAR(20),
Email VARCHAR(30),
Telefono VARCHAR(10),
Contratto INT NOT NULL,
FOREIGN KEY (Contratto) REFERENCES Contratto(codContratto) ON DELETE RESTRICT
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Cliente(
codCliente VARCHAR(45) PRIMARY KEY,
FOREIGN KEY (codCliente) REFERENCES Persona(codPersona) ON DELETE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Produttore(
codProduttore VARCHAR(45) PRIMARY KEY,
FOREIGN KEY (codProduttore) REFERENCES Persona(codPersona) ON DELETE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Musicista(
codMusicista VARCHAR(45) PRIMARY KEY,
FOREIGN KEY (codMusicista) REFERENCES Persona(codPersona) ON DELETE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Sessione(
codSessione INT AUTO_INCREMENT PRIMARY KEY,
Data DATE,
oraInizio TIME NOT NULL,
oraFine TIME NOT NULL,
Studio VARCHAR(22) NOT NULL,
Sala VARCHAR(15) NOT NULL,
Progetto INT NOT NULL,
Produttore VARCHAR(45) NOT NULL,
costoSessione DECIMAL(7,2),
FOREIGN KEY (Sala, Studio) REFERENCES Sala(codSala, Studio) ON DELETE RESTRICT,
FOREIGN KEY (Progetto) REFERENCES Progetto(codProgetto) ON DELETE CASCADE,
FOREIGN KEY (Produttore) REFERENCES Produttore(codProduttore) ON DELETE RESTRICT
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Registrazione(
Sessione INT,
Traccia INT,
PRIMARY KEY (Traccia, Sessione),
FOREIGN KEY (Traccia) REFERENCES Traccia(codTraccia) ON DELETE CASCADE,
FOREIGN KEY (Sessione) REFERENCES Sessione(codSessione) ON DELETE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Utilizzo (
Sessione INT,
Musicista VARCHAR(45),
Strumento VARCHAR(17),
PRIMARY KEY (Sessione, Musicista, Strumento),
FOREIGN KEY (Sessione) REFERENCES Sessione(codSessione) ON DELETE CASCADE,
FOREIGN KEY (Musicista) REFERENCES Musicista(codMusicista) ON DELETE CASCADE,
FOREIGN KEY (Strumento) REFERENCES Strumento(codStrumento) ON DELETE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Richiesta (
Cliente VARCHAR(45),
Sessione INT,
PRIMARY KEY (Cliente, Sessione),
FOREIGN KEY (Cliente) REFERENCES Cliente(codCliente) ON DELETE CASCADE,
FOREIGN KEY (Sessione) REFERENCES Sessione(codSessione) ON DELETE CASCADE
)ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Creazione (
Progetto INT,
Produttore VARCHAR(45),
Cliente VARCHAR(45),
PRIMARY KEY (Progetto, Produttore, Cliente),
FOREIGN KEY (Progetto) REFERENCES Progetto(codProgetto) ON DELETE CASCADE,
FOREIGN KEY (Produttore) REFERENCES Produttore(codProduttore) ON DELETE CASCADE,
FOREIGN KEY (Cliente) REFERENCES Cliente(codCliente) ON DELETE CASCADE
)ENGINE = InnoDB;