--Ajouter une nouvelle adresse complète dans les tables finales.
INSERT INTO adresse (
    id,
    numero,
    rep,
    alias,
    nom_ld,
    id_voie,
    id_commune,
    id_position
)
SELECT
    '01453_0222_00002' AS id,
    2 AS numero, 
    a.rep,
    a.alias,
    a.nom_ld,
    a.id_voie,
    a.id_commune,
    a.id_position
FROM adresse a
WHERE a.id = '01453_0222_00001';   -- l’adresse d’origine (le n°1)

SELECT 
    a.id_adresse,
    a.id,
    a.numero,
    v.nom_voie,
    c.nom_commune
FROM adresse a
JOIN voie v  ON a.id_voie = v.id_fantoir
JOIN commune c ON a.id_commune = c.code_insee
WHERE v.nom_voie = 'Chemin de Beaupaysage'
  AND c.nom_commune = 'Arvière-en-Valromey'
ORDER BY a.numero;

SELECT 
    a.id_adresse,
    a.id,
    a.numero,
    v.nom_voie,
    c.nom_commune
FROM adresse a
JOIN voie v  ON a.id_voie = v.id_fantoir
JOIN commune c ON a.id_commune = c.code_insee
WHERE v.nom_voie = 'Chemin de Bellevue'
and c.nom_commune = 'Arvière-en-Valromey'
ORDER BY a.numero;

--Mettre à jour le nom d’une voie pour une adresse spécifique.
UPDATE voie
SET nom_voie = 'Chemin de Beaupaysage'
WHERE id_fantoir = (
    SELECT id_voie
    FROM adresse
    WHERE id_adresse = 262768
);

--Supprimer toutes les adresses avec un champ manquant critique (ex : numéro de voie vide).
SELECT 
    id_adresse,
    id,
    numero,
    id_voie,
    id_commune
FROM adresse
WHERE numero IS null or numero <=0;

DELETE FROM adresse
WHERE numero IS null or numero <=0;