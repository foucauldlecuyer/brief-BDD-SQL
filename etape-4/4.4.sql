--Nombre moyen d’adresses par commune et par type de voie.

SELECT
    c.nom_commune,
    SPLIT_PART(v.nom_voie, ' ', 1) AS type_voie,
    AVG(nb_adresses) AS moyenne_adresses
FROM (
    SELECT
        a.id_commune,
        a.id_voie,
        COUNT(*) AS nb_adresses
    FROM adresse a
    GROUP BY a.id_commune, a.id_voie
) x
JOIN commune c ON x.id_commune = c.code_insee
JOIN voie v    ON x.id_voie     = v.id_fantoir
GROUP BY 
    c.nom_commune,
    type_voie
ORDER BY 
    c.nom_commune,
    type_voie;

--Top 10 des communes avec le plus d’adresses.

SELECT
    c.code_insee,
    c.nom_commune,
    c.code_postal,
    COUNT(*) AS nb_adresses
FROM adresse a
JOIN commune c
    ON a.id_commune = c.code_insee
GROUP BY
    c.code_insee,
    c.nom_commune,
    c.code_postal
ORDER BY
    nb_adresses DESC
LIMIT 10;

--Vérifier la complétude des champs essentiels (numéro, voie, code postal, commune).
SELECT
    a.id_adresse,
    a.id,
    a.numero,
    v.nom_voie,
    c.code_postal,
    c.nom_commune
FROM adresse a
LEFT JOIN voie v
       ON a.id_voie = v.id_fantoir
LEFT JOIN commune c
       ON a.id_commune = c.code_insee
WHERE 
      a.numero IS NULL
   OR v.nom_voie IS NULL
   OR c.code_postal IS NULL
   OR c.nom_commune IS NULL
ORDER BY c.nom_commune NULLS LAST, v.nom_voie, a.numero;

SELECT
    COUNT(*) AS total_adresses,
    COUNT(*) FILTER (
        WHERE a.numero IS NOT NULL
          AND v.nom_voie IS NOT NULL
          AND c.code_postal IS NOT NULL
          AND c.nom_commune IS NOT NULL
    ) AS nb_completes,
    COUNT(*) FILTER (
        WHERE a.numero IS NULL
           OR v.nom_voie IS NULL
           OR c.code_postal IS NULL
           OR c.nom_commune IS NULL
    ) AS nb_incompletes
FROM adresse a
LEFT JOIN voie v
       ON a.id_voie = v.id_fantoir
LEFT JOIN commune c
       ON a.id_commune = c.code_insee;



