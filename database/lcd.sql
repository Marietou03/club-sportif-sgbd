-- ============================================================
-- GESTION DES DROITS (LCD) - club_sport
-- Sujet 8 : Gestion d'un Club Sportif
-- L2 GLSI - ESP/UCAD - 2026
-- ============================================================

USE club_sport;

-- Création des utilisateurs
CREATE USER 'entraineur_role'@'localhost' IDENTIFIED BY 'entraineur123';
CREATE USER 'secretaire_club'@'localhost' IDENTIFIED BY 'secretaire123';

-- Droits entraineur_role
-- SELECT sur toutes les tables
GRANT SELECT ON club_sport.* TO 'entraineur_role'@'localhost';
-- INSERT et UPDATE sur Entrainement et Presence uniquement
GRANT INSERT, UPDATE ON club_sport.Entrainement TO 'entraineur_role'@'localhost';
GRANT INSERT, UPDATE ON club_sport.Presence TO 'entraineur_role'@'localhost';

-- Droits secretaire_club
-- SELECT, INSERT, UPDATE sur Membre, Cotisation, Appartenance
GRANT SELECT, INSERT, UPDATE ON club_sport.Membre TO 'secretaire_club'@'localhost';
GRANT SELECT, INSERT, UPDATE ON club_sport.Cotisation TO 'secretaire_club'@'localhost';
GRANT SELECT, INSERT, UPDATE ON club_sport.Appartenance TO 'secretaire_club'@'localhost';
-- SELECT uniquement sur le reste
GRANT SELECT ON club_sport.Sport TO 'secretaire_club'@'localhost';
GRANT SELECT ON club_sport.Equipe TO 'secretaire_club'@'localhost';
GRANT SELECT ON club_sport.Entrainement TO 'secretaire_club'@'localhost';
GRANT SELECT ON club_sport.Presence TO 'secretaire_club'@'localhost';
GRANT SELECT ON club_sport.Competition TO 'secretaire_club'@'localhost';
GRANT SELECT ON club_sport.Participation TO 'secretaire_club'@'localhost';

FLUSH PRIVILEGES;