

# PostgreSQL • MERISE • Normalisation • SQL Avancé
##🎯 Objectif du projet

L’objectif de ce projet est de partir d’un jeu de données réelles issu de la Base Adresse Nationale (BAN) — plus de 26 millions d’adresses disponibles au format CSV — afin de :
- Importer et explorer un échantillon dans PostgreSQL
- Concevoir un modèle MERISE complet : MCD → MLD → MPD
- Construire une base de données relationnelle normalisée
- Écrire un script ETL SQL simple (transformation table brute → tables normalisées)
- Produire un ensemble de requêtes avancées de consultation, analyse et qualité des données

Le projet est volontairement orienté qualité, normalisation et performance, comme on le ferait pour une base de production.

## 🗂️ Contenu du projet
### 1. Découverte de la donnée

Je télécharge un fichier départemental du BAN (ex : adresses-01.csv) :
https://adresse.data.gouv.fr/data/ban/adresses/latest/csv/

Étapes réalisées :

- Exploration dans DBeaver (types, doublons, valeurs manquantes)
- Import du CSV dans une table brute PostgreSQL :

CREATE TABLE public.adresses (...);  

- Inspection :

SELECT * FROM public.adresses LIMIT 20;
Identification des entités : voie / commune / adresse / position / parcelle

### 2. Modélisation MERISE

Lien  du dictionnaire de données :
https://docs.google.com/spreadsheets/d/1w5XGE2t59c0Kw8s8UZLy88FTr8EOuM9KCD-3cniLWks/edit?usp=sharing

[](etape-2/MCD.png)

[](etape-2/MLD.png)

[](etape-2/MPD.png)

### 3. Création des tables (MPD)

Voici un extrait du script complet utilisé :

CREATE TABLE position ( ... );
CREATE TABLE voie ( ... );
CREATE TABLE commune ( ... );
CREATE TABLE adresse ( ... );
CREATE TABLE parcelle (...);
CREATE TABLE adresse_parcelle (...);

Les clés étrangères utilisent des ON DELETE CASCADE garantissant la cohérence lors des suppressions.

### 4. Script ETL : insertion des données normalisées

Le script importe la table brute public.adresses vers les tables normalisées :

insertion des voies :

INSERT INTO voie (...)
SELECT DISTINCT ON (id_fantoir) ...
FROM public.adresses;


insertion des positions, communes, adresses, parcelles

insertion des relations adresse_parcelle

✔ Toutes les relations FK sont respectées
✔ Aucun doublon dans les référentiels
✔ Adresses liées correctement à leurs voies / positions / communes

### 🔍 5. Requêtes SQL demandées
5.1 Requêtes de consultation
✔ Lister toutes les adresses d’une commune donnée, triées par numéro
SELECT ...
FROM adresse a
JOIN voie v ON a.id_voie = v.id_fantoir
JOIN commune c ON a.id_commune = c.code_insee
WHERE c.nom_commune = 'Poncin'
ORDER BY v.nom_voie, a.numero;

✔ Lister toutes les communes distinctes
SELECT code_insee, nom_commune, code_postal
FROM commune
ORDER BY nom_commune;

✔ Rechercher les adresses contenant un mot-clé dans la voie
WHERE v.nom_voie ILIKE '%Bellevue%'

5.2 Qualité et anomalies
✔ Adresses où le code postal ne correspond pas à la commune
WHERE b.code_postal::text <> c.code_postal

✔ Adresses avec coordonnées GPS absentes
WHERE p.lon IS NULL OR p.lat IS NULL

✔ Adresses GPS hors France
WHERE p.lon NOT BETWEEN -5 AND 10
   OR p.lat NOT BETWEEN 41 AND 51

✔ Codes postaux avec plus de 10 000 adresses
GROUP BY c.code_postal
HAVING COUNT(*) > 10000

✔ Doublons exacts (numéro + voie + commune + code postal)
GROUP BY a.numero, v.nom_voie, c.code_postal, c.nom_commune
HAVING COUNT(*) > 1

5.3 Analyse & agrégations
✔ Nombre moyen d’adresses par commune et par type de voie

(type de voie = premier mot du nom_voie)

SPLIT_PART(v.nom_voie, ' ', 1) AS type_voie

✔ Top 10 des communes les plus fournies
ORDER BY nb_adresses DESC
LIMIT 10;

✔ Complétude des champs essentiels

(numero, voie, code postal, commune)

WHERE a.numero IS NULL OR v.nom_voie IS NULL OR ...

### 6. Manipulation : modifications, insertions, suppressions
✔ Ajouter une nouvelle adresse

Exemple : créer le numéro 2 à partir du numéro 1 :

INSERT INTO adresse (...)
SELECT ..., 2, ...
WHERE id = '01453_0222_00001';

✔ Mettre à jour le nom d’une voie
UPDATE voie
SET nom_voie = 'Nouveau Nom'
WHERE id_fantoir = (
    SELECT id_voie FROM adresse WHERE id_adresse = 1234
);

✔ Supprimer les adresses incomplètes
DELETE FROM adresse
WHERE numero IS NULL OR numero <= 0;

🛠️ Outils utilisés

PostgreSQL (via installation locale)

DBeaver (exploration, import CSV, exécution SQL)

Merise (modélisation MCD → MLD → MPD)

SQL avancé : DISTINCT ON, agrégations, ILIKE, GROUP BY, HAVING, CTE