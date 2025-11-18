-- Créer une procédure stockée pour insérer ou mettre à jour une adresse selon qu’elle existe déjà.

CREATE OR REPLACE FUNCTION upsert_adresse_pk(
    p_id_adresse INT,
    p_id VARCHAR(50),
    p_numero INT,
    p_rep VARCHAR(10),
    p_alias VARCHAR(50),
    p_nom_ld VARCHAR(255),
    p_id_voie VARCHAR(20),
    p_id_commune VARCHAR(5),
    p_id_position INT
)
RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    -- 🟩 Cas INSERT (id_adresse NULL)
    IF p_id_adresse IS NULL THEN
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
        VALUES (
            p_id,
            p_numero,
            p_rep,
            p_alias,
            p_nom_ld,
            p_id_voie,
            p_id_commune,
            p_id_position
        )
        RETURNING id_adresse INTO new_id;

        RETURN new_id;
    END IF;

    -- 🟦 Cas UPDATE (id_adresse connu)
    UPDATE adresse
    SET
        id          = p_id,
        numero      = p_numero,
        rep         = p_rep,
        alias       = p_alias,
        nom_ld      = p_nom_ld,
        id_voie     = p_id_voie,
        id_commune  = p_id_commune,
        id_position = p_id_position
    WHERE id_adresse = p_id_adresse;

    RETURN p_id_adresse;
END;
$$ LANGUAGE plpgsql;

SELECT upsert_adresse_pk(
    NULL,                   -- p_id_adresse (NULL = INSERT)
    '01453_0222_00002',     -- p_id (id BAN)
    2,                      -- p_numero
    NULL,                   -- p_rep
    NULL,                   -- p_alias
    NULL,                   -- p_nom_ld
    '01453_0222',           -- p_id_voie  (doit exister dans voie.id_fantoir)
    '1453',                -- p_id_commune (doit exister dans commune.code_insee)
    1250                    -- p_id_position (doit exister dans position.id_position)
);

-- Créer un trigger qui vérifie, avant insertion, que les coordonnées GPS sont valides (lat entre -90 et 90, lon entre -180 et 180) et que le code postal est bien au format 5 chiffres
-- coordonnées:
CREATE OR REPLACE FUNCTION check_gps_position()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérification latitude
    IF NEW.lat IS NULL OR NEW.lat < -90 OR NEW.lat > 90 THEN
        RAISE EXCEPTION 'Latitude invalide : % (doit être entre -90 et 90)', NEW.lat;
    END IF;

    -- Vérification longitude
    IF NEW.lon IS NULL OR NEW.lon < -180 OR NEW.lon > 180 THEN
        RAISE EXCEPTION 'Longitude invalide : % (doit être entre -180 et 180)', NEW.lon;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_check_gps_position
BEFORE INSERT OR UPDATE ON position
FOR EACH ROW
EXECUTE FUNCTION check_gps_position();

-- Trigger Code postal:
CREATE OR REPLACE FUNCTION check_code_postal()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier que le code postal n'est pas NULL
    IF NEW.code_postal IS NULL THEN
        RAISE EXCEPTION 'Le code postal ne peut pas être NULL';
    END IF;

    -- Vérifier longueur = 5
    IF length(NEW.code_postal) <> 5 THEN
        RAISE EXCEPTION 'Code postal "%" invalide : doit contenir exactement 5 caractères', NEW.code_postal;
    END IF;

    -- Vérifier que ce sont bien des chiffres
    IF NEW.code_postal !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'Code postal "%" invalide : doit contenir uniquement des chiffres', NEW.code_postal;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_check_code_postal
BEFORE INSERT OR UPDATE ON commune
FOR EACH ROW
EXECUTE FUNCTION check_code_postal();

-- Ajouter automatiquement une date de création / mise à jour à chaque modification via trigger.
ALTER TABLE adresse
ADD COLUMN created_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN updated_at TIMESTAMP;

CREATE OR REPLACE FUNCTION set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    -- Définir created_at uniquement lors d'un INSERT (pas UPDATE)
    IF TG_OP = 'INSERT' THEN
        NEW.created_at := NOW();
    END IF;

    -- Définir updated_at à chaque modification
    NEW.updated_at := NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_timestamp_adresse
BEFORE INSERT OR UPDATE ON adresse
FOR EACH ROW
EXECUTE FUNCTION set_timestamp();

INSERT INTO adresse (id, numero, id_voie, id_commune, id_position)
VALUES ('A_001', 10, 'V0001', '01453', 1250);

UPDATE adresse
SET numero = 12
WHERE id = 'A_001';

