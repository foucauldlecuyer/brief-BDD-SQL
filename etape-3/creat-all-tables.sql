DROP TABLE IF EXISTS adresse_parcelle;
DROP TABLE IF EXISTS adresse;
DROP TABLE IF EXISTS commune;
DROP TABLE IF EXISTS position;
DROP TABLE IF EXISTS parcelle;
DROP TABLE IF EXISTS voie;

create table position (
	id_position serial primary key,
	x decimal(22,15),
	y decimal(22,15),
	lon decimal(18,15),
	lat decimal(17,15),
	type_position varchar(50),
	source_position varchar(50)
);

create table voie (
	id_fantoir varchar(20) primary key,
	nom_voie varchar(255),
	source_nom_voie varchar(50),
	nom_afnor varchar(255)
);

create table commune (
	code_insee varchar(5) primary key,
	code_postal varchar(5),
	nom_commune varchar(50),
	code_insee_ancienne_commune varchar(5),
	nom_ancienne_commune varchar(50),
	libelle_acheminement varchar(50),
	certification_commune int not null
);

create table adresse (
	id_adresse serial primary key,
	id varchar(50),
	numero int4,
	rep varchar(10),
	alias varchar(50),
	nom_ld varchar(255),
	id_voie varchar(20),
	id_position int,
	id_commune varchar(5),
	constraint fk_adresse_voie foreign key(id_voie) references voie(id_fantoir) on delete cascade,
	constraint fk_adresse_postion foreign key(id_position) references position(id_position) on delete cascade,
	constraint fk_adresse_commune foreign key(id_commune) references commune (code_insee) on delete cascade
);

create table parcelle (
	id_parcelle serial primary key,
	cad_parcelles text
);

create table adresse_parcelle (
	id_parcelle int,
	id_adresse int,
	constraint fk_adresse_parcelle_parcelle foreign key(id_parcelle) references parcelle(id_parcelle) on delete cascade,
	constraint fk_adresse_parcelle_adresse foreign key(id_adresse) references adresse(id_adresse) on delete cascade
);

	



