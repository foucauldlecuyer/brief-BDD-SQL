--Identifier doublons exacts (mêmes numéro + nom de voie + code postal + commune).
WITH doublons AS (
    SELECT
        a.numero,
        v.nom_voie,
        c.code_postal,
        c.nom_commune
    FROM adresse a
    JOIN voie v
        ON a.id_voie = v.id_fantoir
    JOIN commune c
        ON a.id_commune = c.code_insee
    GROUP BY
        a.numero,
        v.nom_voie,
        c.code_postal,
        c.nom_commune
    HAVING COUNT(*) > 1
)
SELECT
    a.id_adresse,
    a.id,
    a.numero,
    v.nom_voie,
    c.code_postal,
    c.nom_commune
FROM adresse a
JOIN voie v
    ON a.id_voie = v.id_fantoir
JOIN commune c
    ON a.id_commune = c.code_insee
JOIN doublons d
    ON  a.numero      = d.numero
    AND v.nom_voie    = d.nom_voie
    AND c.code_postal = d.code_postal
    AND c.nom_commune = d.nom_commune
ORDER BY
    c.nom_commune,
    v.nom_voie,
    a.numero,
    a.id_adresse;

--Identifier les adresses incohérentes, par exemple coordonnées GPS absentes ou en dehors du département.
SELECT 
    a.id_adresse,
    a.id,
    a.numero,
    v.nom_voie,
    c.nom_commune,
    p.lon,
    p.lat
FROM adresse a
JOIN voie v       ON a.id_voie = v.id_fantoir
JOIN commune c    ON a.id_commune = c.code_insee
JOIN position p   ON a.id_position = p.id_position
WHERE p.lon IS NULL
   OR p.lat IS NULL
ORDER BY c.nom_commune, v.nom_voie, a.numero;

SELECT 
    a.id_adresse,
    a.id,
    a.numero,
    v.nom_voie,
    c.nom_commune,
    c.code_insee,
    p.lon,
    p.lat
FROM adresse a
JOIN voie v       ON a.id_voie = v.id_fantoir
JOIN commune c    ON a.id_commune = c.code_insee
JOIN position p   ON a.id_position = p.id_position
WHERE (
       p.lon < 5.0 OR p.lon > 6.2
    OR p.lat < 45.5 OR p.lat > 46.5
)
ORDER BY c.nom_commune, v.nom_voie, a.numero;

--Lister les codes postaux avec plus de 10 000 adresses pour détecter les anomalies volumétriques.
SELECT
    c.code_postal,
    COUNT(*) AS nb_adresses
FROM adresse a
JOIN commune c
    ON a.id_commune = c.code_insee
GROUP BY
    c.code_postal
HAVING
    COUNT(*) > 10000
ORDER BY
    nb_adresses DESC;



