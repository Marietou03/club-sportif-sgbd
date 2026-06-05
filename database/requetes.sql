-- ============================================================
-- REQUÊTES DE CONSULTATION - club_sport
-- Sujet 8 : Gestion d'un Club Sportif
-- L2 GLSI - ESP/UCAD - 2026
-- ============================================================

USE club_sport;

-- R1 : Taux d'assiduité par membre pour la saison en cours
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom) AS membre,
    a.code_equipe,
    COUNT(p.id_presence) AS nb_presences,
    total_e.total_entrainements,
    ROUND(COUNT(p.id_presence)*100.0/NULLIF(total_e.total_entrainements,0),1) AS taux_assiduite_pct
FROM Membre m
JOIN Appartenance a ON m.num_licence = a.num_licence AND a.date_sortie IS NULL
JOIN Entrainement e ON e.code_equipe = a.code_equipe
LEFT JOIN Presence p ON p.id_entrainement = e.id_entrainement
                    AND p.num_licence = m.num_licence AND p.present = 1
JOIN (
    SELECT code_equipe, COUNT(*) AS total_entrainements
    FROM Entrainement GROUP BY code_equipe
) total_e ON total_e.code_equipe = a.code_equipe
GROUP BY m.num_licence, m.nom, m.prenom, a.code_equipe, total_e.total_entrainements
ORDER BY taux_assiduite_pct DESC;

-- R2 : Membres avec cotisation impayée pour la saison en cours
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom) AS membre,
    m.telephone, m.email, c.saison, c.montant
FROM Membre m
JOIN Cotisation c ON c.num_licence = m.num_licence
WHERE c.statut = 'impayee' AND c.saison = '2025-2026'
ORDER BY m.nom, m.prenom;

-- R3 : Résultats des équipes par compétition
SELECT
    e.code_equipe, e.nom AS equipe, s.nom AS sport,
    p.resultat, c.nom AS competition, c.type_comp
FROM Participation p
JOIN Equipe e ON e.code_equipe = p.code_equipe
JOIN Competition c ON c.id_competition = p.id_competition
JOIN Sport s ON s.id_sport = e.id_sport
ORDER BY e.code_equipe, c.date_comp;

-- R4 : Équipes classées par nombre de victoires
SELECT
    e.code_equipe, e.nom AS equipe, s.nom AS sport,
    COUNT(p.id_participation) AS total_participations,
    SUM(p.resultat LIKE '%victoire%') AS nb_victoires,
    SUM(p.resultat LIKE '%defaite%') AS nb_defaites
FROM Equipe e
JOIN Sport s ON s.id_sport = e.id_sport
LEFT JOIN Participation p ON p.code_equipe = e.code_equipe
GROUP BY e.code_equipe, e.nom, s.nom
ORDER BY nb_victoires DESC;

-- R5 : Membres présents à tous les entraînements du mois
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom) AS membre,
    a.code_equipe
FROM Membre m
JOIN Appartenance a ON a.num_licence = m.num_licence AND a.date_sortie IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM Entrainement e
    WHERE e.code_equipe = a.code_equipe
      AND MONTH(e.date_seance) = MONTH(CURDATE())
      AND YEAR(e.date_seance) = YEAR(CURDATE())
      AND NOT EXISTS (
          SELECT 1 FROM Presence p
          WHERE p.id_entrainement = e.id_entrainement
            AND p.num_licence = m.num_licence
            AND p.present = 1
      )
)
ORDER BY m.nom, m.prenom;

-- R6 : Membres n'ayant jamais participé à une compétition officielle
SELECT
    m.num_licence,
    CONCAT(m.prenom,' ',m.nom) AS membre,
    a.code_equipe
FROM Membre m
JOIN Appartenance a ON a.num_licence = m.num_licence AND a.date_sortie IS NULL
WHERE m.num_licence NOT IN (
    SELECT DISTINCT ap.num_licence
    FROM Appartenance ap
    JOIN Participation pa ON pa.code_equipe = ap.code_equipe
    JOIN Competition c ON c.id_competition = pa.id_competition
    WHERE c.type_comp IN ('championnat','coupe')
)
ORDER BY m.nom, m.prenom; 
