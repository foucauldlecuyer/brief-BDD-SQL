--Lister toutes les adresses d’une commune donnée, triées par numéro de voie.

SELECT 
    a.id_adresse,
    a.id,
    a.numero,
    a.rep,
    a.alias,
    a.nom_ld,
    v.nom_voie,
    c.nom_commune,
    c.code_postal
FROM adresse a
JOIN voie v 
    ON a.id_voie = v.id_fantoir
JOIN commune c 
    ON a.id_commune = c.code_insee
WHERE c.nom_commune = 'Ambérieu-en-Bugey'   -- à remplacer
ORDER BY v.nom_voie, a.numero;

--Compter le nombre d’adresses par commune et par type de voie.

SELECT
    c.nom_commune,
    v.nom_voie AS type_voie,
    COUNT(*) AS nb_adresses
FROM adresse a
JOIN voie v 
    ON a.id_voie = v.id_fantoir
JOIN commune c 
    ON a.id_commune = c.code_insee
GROUP BY
    c.nom_commune,
    v.nom_voie
ORDER BY
    c.nom_commune,
    type_voie;

--Lister toutes les communes distinctes présentes dans le fichier.
SELECT
    nom_commune
FROM commune
ORDER BY nom_commune;

--Rechercher toutes les adresses contenant un mot-clé dans le nom de voie.

SELECT 
    a.id_adresse,
    a.id,
    a.numero,
    a.rep,
    a.alias,
    a.nom_ld,
    v.nom_voie,
    c.nom_commune,
    c.code_postal
FROM adresse a
JOIN voie v
    ON a.id_voie = v.id_fantoir
JOIN commune c
    ON a.id_commune = c.code_insee
WHERE v.nom_voie ILIKE '%' || 'église' || '%'
ORDER BY c.nom_commune, v.nom_voie, a.numero;

--Trouver toutes les adresses où le code postal ne correspond pas à la commune.
SELECT 
    a.id_adresse,
    a.id,
    a.numero,
    v.nom_voie,
    c.nom_commune,
    c.code_postal AS code_postal_officiel,
    b.code_postal AS code_postal_ban
FROM adresse a
JOIN voie v
    ON a.id_voie = v.id_fantoir
JOIN commune c
    ON a.id_commune = c.code_insee
JOIN public.adresses b
    ON a.id = b.id   -- identifiant BAN
WHERE b.code_postal::text <> c.code_postal
ORDER BY c.nom_commune, v.nom_voie, a.numero;




