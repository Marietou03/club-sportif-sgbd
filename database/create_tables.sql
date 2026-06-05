-- ============================================================
-- CRÉATION DES TABLES - club_sport
-- Sujet 8 : Gestion d'un Club Sportif
-- L2 GLSI - ESP/UCAD - 2026
-- ============================================================

DROP DATABASE IF EXISTS club_sport;
CREATE DATABASE club_sport CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE club_sport;

CREATE TABLE Sport (
    id_sport      INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(50)  NOT NULL,
    description   TEXT
);

CREATE TABLE Membre (
    num_licence     VARCHAR(20) PRIMARY KEY,
    nom             VARCHAR(50)  NOT NULL,
    prenom          VARCHAR(50)  NOT NULL,
    date_naissance  DATE         NOT NULL,
    telephone       VARCHAR(20),
    email           VARCHAR(100) UNIQUE,
    date_adhesion   DATE         NOT NULL
);

CREATE TABLE Equipe (
    code_equipe   VARCHAR(10)  PRIMARY KEY,
    nom           VARCHAR(80)  NOT NULL,
    id_sport      INT          NOT NULL,
    categorie     ENUM('senior','junior','cadet') NOT NULL,
    entraineur    VARCHAR(100),
    FOREIGN KEY (id_sport) REFERENCES Sport(id_sport) ON DELETE RESTRICT
);

CREATE TABLE Appartenance (
    id_app          INT AUTO_INCREMENT PRIMARY KEY,
    num_licence     VARCHAR(20) NOT NULL,
    code_equipe     VARCHAR(10) NOT NULL,
    date_entree     DATE        NOT NULL,
    date_sortie     DATE        DEFAULT NULL,
    poste           VARCHAR(50),
    FOREIGN KEY (num_licence)  REFERENCES Membre(num_licence)  ON DELETE CASCADE,
    FOREIGN KEY (code_equipe)  REFERENCES Equipe(code_equipe)  ON DELETE CASCADE
);

CREATE TABLE Entrainement (
    id_entrainement INT AUTO_INCREMENT PRIMARY KEY,
    code_equipe     VARCHAR(10) NOT NULL,
    date_seance     DATE        NOT NULL,
    heure_debut     TIME        NOT NULL,
    duree           INT         NOT NULL,
    lieu            VARCHAR(100),
    theme           VARCHAR(150),
    FOREIGN KEY (code_equipe) REFERENCES Equipe(code_equipe) ON DELETE CASCADE
);

CREATE TABLE Presence (
    id_presence       INT AUTO_INCREMENT PRIMARY KEY,
    id_entrainement   INT         NOT NULL,
    num_licence       VARCHAR(20) NOT NULL,
    present           TINYINT(1)  NOT NULL DEFAULT 1,
    motif_absence     VARCHAR(200) DEFAULT NULL,
    FOREIGN KEY (id_entrainement) REFERENCES Entrainement(id_entrainement) ON DELETE CASCADE,
    FOREIGN KEY (num_licence)     REFERENCES Membre(num_licence)           ON DELETE CASCADE,
    UNIQUE KEY uq_presence (id_entrainement, num_licence)
);

CREATE TABLE Competition (
    id_competition  INT AUTO_INCREMENT PRIMARY KEY,
    nom             VARCHAR(100) NOT NULL,
    id_sport        INT          NOT NULL,
    date_comp       DATE         NOT NULL,
    lieu            VARCHAR(100),
    type_comp       ENUM('championnat','coupe','amical') NOT NULL,
    FOREIGN KEY (id_sport) REFERENCES Sport(id_sport) ON DELETE RESTRICT
);

CREATE TABLE Participation (
    id_participation  INT AUTO_INCREMENT PRIMARY KEY,
    code_equipe       VARCHAR(10) NOT NULL,
    id_competition    INT         NOT NULL,
    resultat          VARCHAR(100),
    FOREIGN KEY (code_equipe)     REFERENCES Equipe(code_equipe)          ON DELETE CASCADE,
    FOREIGN KEY (id_competition)  REFERENCES Competition(id_competition)  ON DELETE CASCADE,
    UNIQUE KEY uq_participation (code_equipe, id_competition)
);

CREATE TABLE Cotisation (
    id_cotisation   INT AUTO_INCREMENT PRIMARY KEY,
    num_licence     VARCHAR(20)  NOT NULL,
    saison          VARCHAR(9)   NOT NULL,
    montant         DECIMAL(8,2) NOT NULL CHECK (montant > 0),
    date_paiement   DATE         DEFAULT NULL,
    statut          ENUM('payee','impayee') NOT NULL DEFAULT 'impayee',
    FOREIGN KEY (num_licence) REFERENCES Membre(num_licence) ON DELETE CASCADE
); 
