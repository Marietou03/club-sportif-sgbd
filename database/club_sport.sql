-- ============================================================
-- BASE DE DONNÉES : club_sport
-- Sujet 8 : Gestion d'un Club Sportif
-- L2 GLSI - ESP/UCAD - 2026
-- ============================================================

DROP DATABASE IF EXISTS club_sport;
CREATE DATABASE club_sport CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE club_sport;

-- ============================================================
-- PARTIE 1 : CRÉATION DES TABLES (LDD)
-- ============================================================

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
    date_adhesion   DATE         NOT NULL DEFAULT (CURRENT_DATE)
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
    duree           INT         NOT NULL COMMENT 'Durée en minutes',
    lieu            VARCHAR(100),
    theme           VARCHAR(150),
    FOREIGN KEY (code_equipe) REFERENCES Equipe(code_equipe) ON DELETE CASCADE
);

CREATE TABLE Presence (
    id_presence       INT AUTO_INCREMENT PRIMARY KEY,
    id_entrainement   INT         NOT NULL,
    num_licence       VARCHAR(20) NOT NULL,
    present           TINYINT(1)  NOT NULL DEFAULT 1 COMMENT '1=présent, 0=absent',
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
    resultat          VARCHAR(100) COMMENT 'Score ou classement',
    FOREIGN KEY (code_equipe)     REFERENCES Equipe(code_equipe)          ON DELETE CASCADE,
    FOREIGN KEY (id_competition)  REFERENCES Competition(id_competition)  ON DELETE CASCADE,
    UNIQUE KEY uq_participation (code_equipe, id_competition)
);

CREATE TABLE Cotisation (
    id_cotisation   INT AUTO_INCREMENT PRIMARY KEY,
    num_licence     VARCHAR(20)  NOT NULL,
    saison          VARCHAR(9)   NOT NULL COMMENT 'Format : 2025-2026',
    montant         DECIMAL(8,2) NOT NULL CHECK (montant > 0),
    date_paiement   DATE         DEFAULT NULL,
    statut          ENUM('payee','impayee') NOT NULL DEFAULT 'impayee',
    FOREIGN KEY (num_licence) REFERENCES Membre(num_licence) ON DELETE CASCADE
);

-- ============================================================
-- PARTIE 2 : INSERTION DES DONNÉES (LMD)
-- ============================================================

-- Sports
INSERT INTO Sport (nom, description) VALUES
('Football',    'Sport collectif 11 joueurs par équipe'),
('Basketball',  'Sport collectif 5 joueurs par équipe'),
('Volleyball',  'Sport collectif 6 joueurs par équipe');

-- Membres (40 membres)
INSERT INTO Membre (num_licence, nom, prenom, date_naissance, telephone, email, date_adhesion) VALUES
('LIC001','Diallo','Moussa','2000-03-15','771234501','moussa.diallo@club.sn','2022-09-01'),
('LIC002','Ndiaye','Fatou','2001-07-22','772234502','fatou.ndiaye@club.sn','2022-09-01'),
('LIC003','Sow','Ibrahima','1999-11-10','773234503','ibrahima.sow@club.sn','2022-09-01'),
('LIC004','Fall','Aminata','2003-05-18','774234504','aminata.fall@club.sn','2023-09-01'),
('LIC005','Ba','Cheikh','1998-01-25','775234505','cheikh.ba@club.sn','2021-09-01'),
('LIC006','Mbaye','Rokhaya','2002-08-30','776234506','rokhaya.mbaye@club.sn','2023-09-01'),
('LIC007','Kane','Ousmane','1997-04-12','777234507','ousmane.kane@club.sn','2021-09-01'),
('LIC008','Diop','Mariama','2004-12-05','778234508','mariama.diop@club.sn','2023-09-01'),
('LIC009','Sarr','Abdoulaye','2001-06-20','779234509','abdoulaye.sarr@club.sn','2022-09-01'),
('LIC010','Gueye','Ndèye','2000-09-14','770234510','ndeye.gueye@club.sn','2022-09-01'),
('LIC011','Diouf','Papa','1999-02-28','771334511','papa.diouf@club.sn','2022-09-01'),
('LIC012','Niang','Sokhna','2003-07-07','772334512','sokhna.niang@club.sn','2023-09-01'),
('LIC013','Faye','Serigne','2002-10-19','773334513','serigne.faye@club.sn','2023-09-01'),
('LIC014','Sene','Aissatou','2001-03-03','774334514','aissatou.sene@club.sn','2022-09-01'),
('LIC015','Mboup','Tidiane','1998-08-16','775334515','tidiane.mboup@club.sn','2021-09-01'),
('LIC016','Thiaw','Bineta','2004-01-22','776334516','bineta.thiaw@club.sn','2023-09-01'),
('LIC017','Lô','Pape','2000-05-11','777334517','pape.lo@club.sn','2022-09-01'),
('LIC018','Cissé','Khady','2003-11-29','778334518','khady.cisse@club.sn','2023-09-01'),
('LIC019','Diagne','Babacar','1997-07-08','779334519','babacar.diagne@club.sn','2021-09-01'),
('LIC020','Toure','Ndèye Astou','2002-04-17','770334520','ndeye.toure@club.sn','2023-09-01'),
('LIC021','Badji','Lamine','2001-09-23','771434521','lamine.badji@club.sn','2022-09-01'),
('LIC022','Dème','Coumba','2000-12-01','772434522','coumba.deme@club.sn','2022-09-01'),
('LIC023','Mendy','Saliou','1999-06-14','773434523','saliou.mendy@club.sn','2021-09-01'),
('LIC024','Ndour','Fatimata','2004-03-28','774434524','fatimata.ndour@club.sn','2023-09-01'),
('LIC025','Gomis','Aliou','2002-08-09','775434525','aliou.gomis@club.sn','2023-09-01'),
('LIC026','Diedhiou','Yacine','2001-01-16','776434526','yacine.diedhiou@club.sn','2022-09-01'),
('LIC027','Bassène','Mamadou','1998-10-30','777434527','mamadou.bassene@club.sn','2021-09-01'),
('LIC028','Camara','Rokhaya','2003-05-05','778434528','rokhaya.camara@club.sn','2023-09-01'),
('LIC029','Sagna','Thierno','2000-07-21','779434529','thierno.sagna@club.sn','2022-09-01'),
('LIC030','Diatta','Awa','2002-02-13','770434530','awa.diatta@club.sn','2023-09-01'),
('LIC031','Keita','Modou','1999-04-07','771534531','modou.keita@club.sn','2022-09-01'),
('LIC032','Kouyaté','Ndeye Fatou','2004-08-18','772534532','ndeye.kouyate@club.sn','2023-09-01'),
('LIC033','Barry','Ibou','2001-11-25','773534533','ibou.barry@club.sn','2022-09-01'),
('LIC034','Sylla','Adja','2000-06-03','774534534','adja.sylla@club.sn','2022-09-01'),
('LIC035','Traoré','Seydina','1997-09-12','775534535','seydina.traore@club.sn','2021-09-01'),
('LIC036','Konaté','Marième','2003-03-20','776534536','marieme.konate@club.sn','2023-09-01'),
('LIC037','Baldé','Malick','2002-07-14','777534537','malick.balde@club.sn','2023-09-01'),
('LIC038','Dramé','Oumou','2001-12-08','778534538','oumou.drame@club.sn','2022-09-01'),
('LIC039','Badiane','Pape Alé','1999-05-26','779534539','pape.badiane@club.sn','2021-09-01'),
('LIC040','Sall','Dieynaba','2004-10-02','770534540','dieynaba.sall@club.sn','2023-09-01');

-- Équipes (6 équipes : 2 par sport)
INSERT INTO Equipe (code_equipe, nom, id_sport, categorie, entraineur) VALUES
('FOOT-SEN','Football Sénior','1','senior','Moustapha NDOYE'),
('FOOT-JUN','Football Junior','1','junior','Ibrahima DIALLO'),
('BASK-SEN','Basketball Sénior','2','senior','Aminata FALL'),
('BASK-JUN','Basketball Junior','2','junior','Cheikh SALL'),
('VOLL-SEN','Volleyball Sénior','3','senior','Mariama THIAW'),
('VOLL-JUN','Volleyball Junior','3','junior','Fatou CISSÉ');

-- Appartenances (membres → équipes actives + quelques sorties)
INSERT INTO Appartenance (num_licence, code_equipe, date_entree, date_sortie, poste) VALUES
-- Football Sénior (8 membres)
('LIC001','FOOT-SEN','2022-09-01',NULL,'Attaquant'),
('LIC003','FOOT-SEN','2022-09-01',NULL,'Milieu'),
('LIC005','FOOT-SEN','2021-09-01',NULL,'Défenseur'),
('LIC007','FOOT-SEN','2021-09-01',NULL,'Gardien'),
('LIC009','FOOT-SEN','2022-09-01',NULL,'Milieu'),
('LIC011','FOOT-SEN','2022-09-01',NULL,'Attaquant'),
('LIC019','FOOT-SEN','2021-09-01',NULL,'Défenseur'),
('LIC023','FOOT-SEN','2021-09-01',NULL,'Milieu'),
-- Football Junior (6 membres)
('LIC013','FOOT-JUN','2023-09-01',NULL,'Attaquant'),
('LIC015','FOOT-JUN','2021-09-01','2024-06-30','Milieu'),
('LIC021','FOOT-JUN','2022-09-01',NULL,'Défenseur'),
('LIC025','FOOT-JUN','2023-09-01',NULL,'Gardien'),
('LIC033','FOOT-JUN','2022-09-01',NULL,'Milieu'),
('LIC037','FOOT-JUN','2023-09-01',NULL,'Attaquant'),
-- Basketball Sénior (7 membres)
('LIC002','BASK-SEN','2022-09-01',NULL,'Pivot'),
('LIC006','BASK-SEN','2023-09-01',NULL,'Meneur'),
('LIC010','BASK-SEN','2022-09-01',NULL,'Ailier'),
('LIC014','BASK-SEN','2022-09-01',NULL,'Arrière'),
('LIC022','BASK-SEN','2022-09-01',NULL,'Pivot'),
('LIC026','BASK-SEN','2022-09-01',NULL,'Ailier'),
('LIC034','BASK-SEN','2022-09-01',NULL,'Meneur'),
-- Basketball Junior (6 membres)
('LIC008','BASK-JUN','2023-09-01',NULL,'Meneur'),
('LIC016','BASK-JUN','2023-09-01',NULL,'Ailier'),
('LIC024','BASK-JUN','2023-09-01',NULL,'Pivot'),
('LIC028','BASK-JUN','2023-09-01',NULL,'Arrière'),
('LIC032','BASK-JUN','2023-09-01',NULL,'Meneur'),
('LIC040','BASK-JUN','2023-09-01',NULL,'Ailier'),
-- Volleyball Sénior (6 membres)
('LIC004','VOLL-SEN','2023-09-01',NULL,'Libero'),
('LIC018','VOLL-SEN','2023-09-01',NULL,'Attaquant'),
('LIC020','VOLL-SEN','2023-09-01',NULL,'Passeur'),
('LIC030','VOLL-SEN','2023-09-01',NULL,'Central'),
('LIC036','VOLL-SEN','2023-09-01',NULL,'Central'),
('LIC038','VOLL-SEN','2022-09-01',NULL,'Libero'),
-- Volleyball Junior (5 membres)
('LIC012','VOLL-JUN','2023-09-01',NULL,'Attaquant'),
('LIC017','VOLL-JUN','2022-09-01',NULL,'Passeur'),
('LIC029','VOLL-JUN','2022-09-01',NULL,'Central'),
('LIC031','VOLL-JUN','2022-09-01',NULL,'Libero'),
('LIC039','VOLL-JUN','2021-09-01','2025-03-15','Central');

-- Entraînements (20 séances)
INSERT INTO Entrainement (code_equipe, date_seance, heure_debut, duree, lieu, theme) VALUES
('FOOT-SEN','2026-04-07','16:00:00',90,'Stade Léopold Sédar Senghor','Phases offensives'),
('FOOT-SEN','2026-04-09','16:00:00',90,'Stade Léopold Sédar Senghor','Jeux de position'),
('FOOT-SEN','2026-04-14','16:00:00',90,'Stade Léopold Sédar Senghor','Coups de pied arrêtés'),
('FOOT-JUN','2026-04-08','15:00:00',90,'Terrain annexe ESP','Technique individuelle'),
('FOOT-JUN','2026-04-10','15:00:00',90,'Terrain annexe ESP','Pressing collectif'),
('FOOT-JUN','2026-04-15','15:00:00',90,'Terrain annexe ESP','Tactique défensive'),
('BASK-SEN','2026-04-07','17:00:00',75,'Gymnase Université Cheikh Anta Diop','Jeu de contre-attaque'),
('BASK-SEN','2026-04-09','17:00:00',75,'Gymnase Université Cheikh Anta Diop','Tirs extérieur'),
('BASK-SEN','2026-04-14','17:00:00',75,'Gymnase Université Cheikh Anta Diop','Pick and roll'),
('BASK-JUN','2026-04-08','16:00:00',60,'Gymnase Université Cheikh Anta Diop','Dribble et conduite de balle'),
('BASK-JUN','2026-04-10','16:00:00',60,'Gymnase Université Cheikh Anta Diop','Défense en zone'),
('BASK-JUN','2026-04-15','16:00:00',60,'Gymnase Université Cheikh Anta Diop','Attaque 5v0'),
('VOLL-SEN','2026-04-07','18:00:00',90,'Salle polyvalente ESP','Attaque en 2ème tempo'),
('VOLL-SEN','2026-04-09','18:00:00',90,'Salle polyvalente ESP','Réception service'),
('VOLL-SEN','2026-04-14','18:00:00',90,'Salle polyvalente ESP','Jeu en complexe 2'),
('VOLL-JUN','2026-04-08','17:00:00',75,'Salle polyvalente ESP','Apprentissage de la manchette'),
('VOLL-JUN','2026-04-10','17:00:00',75,'Salle polyvalente ESP','Service flottant'),
('VOLL-JUN','2026-04-15','17:00:00',75,'Salle polyvalente ESP','Smash et contre'),
('FOOT-SEN','2026-05-05','16:00:00',90,'Stade Léopold Sédar Senghor','Préparation match retour'),
('BASK-SEN','2026-05-06','17:00:00',75,'Gymnase Université Cheikh Anta Diop','Systèmes de jeu');

-- Présences (25 enregistrements)
INSERT INTO Presence (id_entrainement, num_licence, present, motif_absence) VALUES
-- Séance 1 : FOOT-SEN
(1,'LIC001',1,NULL),(1,'LIC003',1,NULL),(1,'LIC005',0,'Maladie'),
(1,'LIC007',1,NULL),(1,'LIC009',1,NULL),
-- Séance 2 : FOOT-SEN
(2,'LIC001',1,NULL),(2,'LIC003',0,'Cours rattrapé'),(2,'LIC005',1,NULL),
(2,'LIC007',1,NULL),(2,'LIC011',1,NULL),
-- Séance 3 : FOOT-SEN (mai)
(19,'LIC001',1,NULL),(19,'LIC003',1,NULL),(19,'LIC005',1,NULL),
(19,'LIC007',0,'Blessure'),(19,'LIC009',1,NULL),
-- Séance 7 : BASK-SEN
(7,'LIC002',1,NULL),(7,'LIC006',1,NULL),(7,'LIC010',0,'Voyage'),
(7,'LIC014',1,NULL),(7,'LIC022',1,NULL),
-- Séances VOLL-SEN
(13,'LIC004',1,NULL),(13,'LIC018',1,NULL),(13,'LIC020',1,NULL),
(13,'LIC030',0,'Examen'),(14,'LIC004',1,NULL);

-- Compétitions (5 compétitions)
INSERT INTO Competition (nom, id_sport, date_comp, lieu, type_comp) VALUES
('Championnat régional de football','1','2026-03-20','Stade Demba Diop','championnat'),
('Coupe de Dakar de football','1','2026-04-05','Stade Léopold Sédar Senghor','coupe'),
('Championnat régional de basketball','2','2026-03-25','Gymnase Dakar Arena','championnat'),
('Tournoi amical de basketball','2','2026-04-20','Gymnase Université Cheikh Anta Diop','amical'),
('Championnat régional de volleyball','3','2026-04-10','Salle polyvalente ESP','championnat');

-- Participations avec résultats
INSERT INTO Participation (code_equipe, id_competition, resultat) VALUES
('FOOT-SEN',1,'2-1 victoire'),
('FOOT-JUN',1,'0-3 défaite'),
('FOOT-SEN',2,'3-0 victoire'),
('BASK-SEN',3,'78-65 victoire'),
('BASK-JUN',3,'45-60 défaite'),
('BASK-SEN',4,'85-70 victoire'),
('BASK-JUN',4,'50-55 défaite'),
('VOLL-SEN',5,'3-1 victoire');

-- Cotisations (20 cotisations saison 2025-2026)
INSERT INTO Cotisation (num_licence, saison, montant, date_paiement, statut) VALUES
('LIC001','2025-2026',25000,'2025-10-05','payee'),
('LIC002','2025-2026',25000,'2025-10-12','payee'),
('LIC003','2025-2026',25000,'2025-11-01','payee'),
('LIC004','2025-2026',25000,NULL,'impayee'),
('LIC005','2025-2026',25000,'2025-09-28','payee'),
('LIC006','2025-2026',25000,NULL,'impayee'),
('LIC007','2025-2026',25000,'2025-10-20','payee'),
('LIC008','2025-2026',25000,NULL,'impayee'),
('LIC009','2025-2026',25000,'2025-10-08','payee'),
('LIC010','2025-2026',25000,'2025-12-15','payee'),
('LIC011','2025-2026',25000,'2026-01-10','payee'),
('LIC012','2025-2026',25000,NULL,'impayee'),
('LIC013','2025-2026',25000,'2025-10-30','payee'),
('LIC014','2025-2026',25000,'2025-11-20','payee'),
('LIC015','2025-2026',25000,'2025-09-15','payee'),
('LIC016','2025-2026',25000,NULL,'impayee'),
('LIC017','2025-2026',25000,'2025-10-25','payee'),
('LIC018','2025-2026',25000,NULL,'impayee'),
('LIC019','2025-2026',25000,'2025-09-20','payee'),
('LIC020','2025-2026',25000,'2026-02-05','payee');

-- ============================================================
-- PARTIE 2 : REQUÊTES DE CONSULTATION (6 requêtes)
-- ============================================================

-- -------------------------------------------------------
-- R1 : Taux d'assiduité par membre pour la saison en cours
--      (présences / total entraînements de l'équipe)
-- -------------------------------------------------------
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom)           AS membre,
    a.code_equipe,
    COUNT(p.id_presence)                 AS nb_presences,
    total_e.total_entrainements,
    ROUND(
        COUNT(p.id_presence) * 100.0 / NULLIF(total_e.total_entrainements, 0),
        1
    )                                    AS taux_assiduite_pct
FROM Membre m
JOIN Appartenance a    ON m.num_licence = a.num_licence AND a.date_sortie IS NULL
JOIN Entrainement e    ON e.code_equipe = a.code_equipe
LEFT JOIN Presence p   ON p.id_entrainement = e.id_entrainement
                       AND p.num_licence = m.num_licence
                       AND p.present = 1
JOIN (
    SELECT code_equipe, COUNT(*) AS total_entrainements
    FROM Entrainement
    GROUP BY code_equipe
) total_e ON total_e.code_equipe = a.code_equipe
GROUP BY m.num_licence, m.nom, m.prenom, a.code_equipe, total_e.total_entrainements
ORDER BY taux_assiduite_pct DESC;

-- -------------------------------------------------------
-- R2 : Membres avec cotisation impayée pour la saison en cours
-- -------------------------------------------------------
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom)  AS membre,
    m.telephone,
    m.email,
    c.saison,
    c.montant
FROM Membre m
JOIN Cotisation c ON c.num_licence = m.num_licence
WHERE c.statut = 'impayee'
  AND c.saison = '2025-2026'
ORDER BY m.nom, m.prenom;

-- -------------------------------------------------------
-- R3 : Meilleur buteur/marqueur par équipe
--      (basé sur le résultat de la Participation)
-- -------------------------------------------------------
-- Note : dans ce modèle, les scores individuels ne sont pas stockés.
-- On affiche ici les équipes avec leurs victoires par compétition,
-- ce qui correspond aux données disponibles.
SELECT
    e.code_equipe,
    e.nom         AS equipe,
    s.nom         AS sport,
    p.resultat,
    c.nom         AS competition,
    c.type_comp
FROM Participation p
JOIN Equipe      e ON e.code_equipe    = p.code_equipe
JOIN Competition c ON c.id_competition = p.id_competition
JOIN Sport       s ON s.id_sport       = e.id_sport
ORDER BY e.code_equipe, c.date_comp;

-- -------------------------------------------------------
-- R4 : Équipes classées par nombre de victoires en compétition
-- -------------------------------------------------------
SELECT
    e.code_equipe,
    e.nom                                  AS equipe,
    s.nom                                  AS sport,
    COUNT(p.id_participation)              AS total_participations,
    SUM(p.resultat LIKE '%victoire%')      AS nb_victoires,
    SUM(p.resultat LIKE '%défaite%')       AS nb_defaites
FROM Equipe e
JOIN Sport       s  ON s.id_sport       = e.id_sport
LEFT JOIN Participation p ON p.code_equipe = e.code_equipe
GROUP BY e.code_equipe, e.nom, s.nom
ORDER BY nb_victoires DESC, total_participations DESC;

-- -------------------------------------------------------
-- R5 : Membres présents à TOUS les entraînements du mois
--      (utilisation de EXISTS / double négation)
-- -------------------------------------------------------
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom) AS membre,
    a.code_equipe
FROM Membre m
JOIN Appartenance a ON a.num_licence = m.num_licence AND a.date_sortie IS NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM Entrainement e
    WHERE e.code_equipe = a.code_equipe
      AND MONTH(e.date_seance) = MONTH(CURDATE())
      AND YEAR(e.date_seance)  = YEAR(CURDATE())
      AND NOT EXISTS (
          SELECT 1
          FROM Presence p
          WHERE p.id_entrainement = e.id_entrainement
            AND p.num_licence     = m.num_licence
            AND p.present         = 1
      )
)
ORDER BY m.nom, m.prenom;

-- -------------------------------------------------------
-- R6 : Membres n'ayant jamais participé à une compétition officielle
--      (championnat ou coupe, pas les amicaux)
-- -------------------------------------------------------
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom) AS membre,
    a.code_equipe
FROM Membre m
JOIN Appartenance a ON a.num_licence = m.num_licence AND a.date_sortie IS NULL
WHERE m.num_licence NOT IN (
    SELECT DISTINCT ap.num_licence
    FROM Appartenance ap
    JOIN Participation pa ON pa.code_equipe    = ap.code_equipe
    JOIN Competition   c  ON c.id_competition  = pa.id_competition
    WHERE c.type_comp IN ('championnat','coupe')
)
ORDER BY m.nom, m.prenom;

