TRUNCATE TABLE
  adresse_parcelle,
  parcelle,
  commune,
  adresse,
  voie,
  position
RESTART IDENTITY;

INSERT INTO voie (id_fantoir, nom_voie, source_nom_voie, nom_afnor)
select distinct on (id_fantoir)
  id_fantoir,
  nom_voie,
  source_nom_voie,
  nom_afnor
FROM public.adresses;

insert into position (x, y, lon, lat, type_position, source_position)
select distinct
  x,
  y,
  lon,
  lat,
  type_position,
  source_position
FROM public.adresses;

insert into commune (code_insee, code_postal, nom_commune, code_insee_ancienne_commune, nom_ancienne_commune, libelle_acheminement, certification_commune)
select distinct on (code_insee)
	code_insee,
	code_postal,
	nom_commune,
	code_insee_ancienne_commune,
	nom_ancienne_commune,
	libelle_acheminement,
	certification_commune
from public.adresses;

insert into adresse (id, numero, rep, alias, nom_ld, id_voie, id_commune, id_position)
select distinct on (a.id)
  a.id,
  a.numero,
  a.rep,
  a.alias,
  a.nom_ld,
  v.id_fantoir,
  c.code_insee,
  p.id_position
from public.adresses a
left join voie v
       on a.nom_voie = v.nom_voie
left join commune c
       on a.nom_commune = c.nom_commune
left join position p
       on a.x  = p.x
where a.id is not null
order by a.id;

insert into parcelle(cad_parcelles)
select distinct
	cad_parcelles
from public.adresses;

insert into adresse_parcelle(id_parcelle, id_adresse)
select
	p.id_parcelle,
	a.id_adresse
from adresse a
left join adresses b on a.id = b.id
left join parcelle p on p.cad_parcelles = b.cad_parcelles;