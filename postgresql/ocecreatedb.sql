################################################################################
# CREATE DATABASE                                                  OC ESCALADE #
################################################################################
################################################################################

DROP DATABASE oc_escalade

CREATE DATABASE oc_escalade
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'French_France.1252'
    LC_CTYPE = 'French_France.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

SELECT oc_escalade


################################################################################
#                                                                       GLOBAL #
################################################################################

-- ################################################################ CIVILITE TYPE #
DROP TYPE IF EXISTS CIVILITE_TYPE;

CREATE TYPE CIVILITE_TYPE AS ENUM ('Mlle','Mme','M');

#################################################################### SITE TYPE #
DROP TYPE IF EXISTS SITE_TYPE;

CREATE TYPE SITE_TYPE AS ENUM ('Topo','Secteur','Voie');


################################################################ COTATION TYPE #
DROP TYPE IF EXISTS COTATION_TYPE;

CREATE TYPE COTATION_TYPE AS ENUM ('3','3+','4a','4b','4c',
                	'5a','5b','5c','6a','6a+','6b','6b+','6c','6c+',
                	'7a','7a+','7b','7b+','7c','7c+',
                	'8a','8a+','8b','8b+','8c','8c+','9a','9a+');

################################################################## STATUT TYPE #
DROP TYPE IF EXISTS STATUT_TYPE;

CREATE TYPE STATUT_TYPE AS ENUM ('Indisponible','Displonible','Demandé','Réservé');



##################################################################### TAG TYPE #
DROP TYPE IF EXISTS TAG_TYPE;

CREATE TYPE TAG_TYPE AS ENUM ('Officiel les amis de l’escalade');


################################################################## UTILISATEUR #
DROP TABLE IF EXISTS utilisateur;
CREATE SEQUENCE public.utilisateur_id_seq;

CREATE TABLE utilisateur (
                id INTEGER NOT NULL DEFAULT nextval('public.utilisateur_id_seq'),
                civilite CIVILITE_TYPE NOT NULL,
                nom VARCHAR(50) NOT NULL,
                prenom VARCHAR(50) NOT NULL,
                pseudo VARCHAR(20) NOT NULL,
                telephone VARCHAR(10) NOT NULL,
                mail VARCHAR(100) NOT NULL,
                login VARCHAR(50) NOT NULL,
                mot_de_passe VARCHAR(255) NOT NULL,
                membre BOOLEAN NOT NULL DEFAULT FALSE,
                adresse_id INTEGER NOT NULL,
                CONSTRAINT utilisateur_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.utilisateur_id_seq OWNED BY public.utilisateur.id;

\d+ utilisateur;


ALTER TABLE public.utilisateur ADD CONSTRAINT adresse_utilisateur_fk
FOREIGN KEY (adresse_id)
REFERENCES public.adresse (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


###################################################################### ADRESSE #
DROP TABLE IF EXISTS adresse;

CREATE SEQUENCE public.adresse_id_seq;


CREATE TABLE public.adresse (
                id INTEGER NOT NULL DEFAULT nextval('public.adresse_id_seq'),
                appartement VARCHAR(4),
                etage VARCHAR(3),
                couloir VARCHAR(3),
                escalier VARCHAR(3),
                entree VARCHAR(3),
                immeuble VARCHAR(10),
                residence VARCHAR(20),
                numero VARCHAR(5),
                voie VARCHAR(50),
                place VARCHAR(50),
                code VARCHAR(5) NOT NULL,
                ville VARCHAR(20) NOT NULL,
                pays VARCHAR(20) NOT NULL,
                commentaire TEXT,
                CONSTRAINT id PRIMARY KEY (id)
);


ALTER SEQUENCE public.adresse_id_seq OWNED BY public.adresse.id;

\d+ adresse;


################################################################## COMMENTAIRE #
DROP TABLE IF EXISTS commentaire;

CREATE TABLE public.commentaire (
                id INTEGER NOT NULL,
                grimpeur_id INTEGER NOT NULL,
                texte TEXT NOT NULL,
                CONSTRAINT commentaires_pk PRIMARY KEY (id,grimpeur_id)
);


\d+ commentaire;

ALTER TABLE public.commentaire ADD CONSTRAINT site_commentaires_fk
FOREIGN KEY (id)
REFERENCES public.site (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.commentaire ADD CONSTRAINT utilisateur_commentaires_fk
FOREIGN KEY (grimpeur_id)
REFERENCES public.utilisateur (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


########################################################################## TAG #
DROP TABLE IF EXISTS tag CASCADE;

CREATE SEQUENCE public.tag_id_seq;

CREATE TABLE public.tag (
                id SMALLINT NOT NULL DEFAULT nextval('public.tag_id_seq'),
                name TAG_TYPE DEFAULT 'Officiel les amis de l’escalade' NOT NULL,
                CONSTRAINT tag_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.tag_id_seq OWNED BY public.tag.id;

\d+ tag;


##################################################################### TAG LIST #
CREATE TABLE public.tag_list (
                topo_id INTEGER NOT NULL,
                tag_id SMALLINT NOT NULL,
                CONSTRAINT tag_list_pk PRIMARY KEY (topo_id, tag_id)
);

\d+ tag_list;


ALTER TABLE public.tag_list ADD CONSTRAINT tag_tag_list_fk
FOREIGN KEY (tag_id)
REFERENCES public.tag (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.tag_list ADD CONSTRAINT topo_tag_list_fk
FOREIGN KEY (topo_id)
REFERENCES public.topo (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


################################################################################
#                                                                       METIER #
################################################################################

######################################################################### SITE #
DROP TABLE IF EXISTS site;

CREATE SEQUENCE public.site_id_seq;

CREATE TABLE public.site (
                id INTEGER NOT NULL DEFAULT nextval('public.site_id_seq'),
                nom VARCHAR(50) NOT NULL,
                type SMALLINT NOT NULL,
                a_commentaire BOOLEAN DEFAULT FALSE NOT NULL,
                lien_photo VARCHAR(255) NOT NULL,
                lien_carte VARCHAR(255) NOT NULL,
                CONSTRAINT site_pk PRIMARY KEY (id)
);


ALTER SEQUENCE public.site_id_seq OWNED BY public.site.id;

\d+ site;


######################################################################### TOPO #
DROP TABLE IF EXISTS topo;

CREATE TABLE public.topo (
                id INTEGER NOT NULL,
                region VARCHAR(50) NOT NULL,
                adresse_id INTEGER NOT NULL,
                date DATE NOT NULL DEFAULT CURRENT_DATE,
                description TEXT,
                technique TEXT,
                acces TEXT,
                longitude VARCHAR(10),
                latitude VARCHAR(10),
                promoteur_id INTEGER NOT NULL,
                grimpeur_id INTEGER,
                date_1 VARCHAR NOT NULL,
                statut STATUT_TYPE NOT NULL DEFAULT 'Indisponible',
                statut_auto BOOLEAN NOT NULL DEFAULT FALSE,
                CONSTRAINT topo_pk PRIMARY KEY (id)
);

\d+ topo;

ALTER TABLE public.topo ADD CONSTRAINT site_topo_fk
FOREIGN KEY (id)
REFERENCES public.site (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


ALTER TABLE public.topo ADD CONSTRAINT adresse_topo_fk
FOREIGN KEY (adresse_id)
REFERENCES public.adresse (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.topo ADD CONSTRAINT utilisateur_topo_promoteur_fk
FOREIGN KEY (promoteur_id)
REFERENCES public.utilisateur (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.topo ADD CONSTRAINT utilisateur_topo_grimpeur_fk
FOREIGN KEY (grimpeur_id)
REFERENCES public.utilisateur (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


###################################################################### SECTEUR #
DROP TABLE IF EXISTS secteur;
CREATE TABLE public.secteur (
                id INTEGER NOT NULL,
                topo_id INTEGER NOT NULL,
                longitude VARCHAR(10),
                latitude VARCHAR(10),
                equipement TEXT,
                CONSTRAINT secteur_pk PRIMARY KEY (id)
);

\d+ secteur;

ALTER TABLE public.secteur ADD CONSTRAINT site_secteur_fk
FOREIGN KEY (id)
REFERENCES public.site (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.secteur ADD CONSTRAINT topo_secteur_fk
FOREIGN KEY (topo_id)
REFERENCES public.topo (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


######################################################################### VOIE #
DROP TABLE IF EXISTS voie;
CREATE TABLE public.voie (
                id INTEGER NOT NULL,
                secteur_id INTEGER NOT NULL,
                equipee BOOLEAN DEFAULT FALSE NOT NULL,
                hauteur INTEGER NOT NULL,
                cotation COTATION_TYPE,
                CONSTRAINT voie_pk PRIMARY KEY (id)
);

\d+ voie;

ALTER TABLE public.voie ADD CONSTRAINT site_voie_fk
FOREIGN KEY (id)
REFERENCES public.site (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.voie ADD CONSTRAINT secteur_voie_fk
FOREIGN KEY (secteur_id)
REFERENCES public.secteur (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


##################################################################### LONGUEUR #
DROP TABLE IF EXISTS longueur;
CREATE TABLE public.longueur (
                id INTEGER NOT NULL,
                voie_id INTEGER NOT NULL,
                hauteur INTEGER NOT NULL,
                nombre_points INTEGER NOT NULL,
                cotation COTATION_TYPE,
                CONSTRAINT longueur_pk PRIMARY KEY (id)
);

\d+ longueur;

ALTER TABLE public.longueur ADD CONSTRAINT voie_longueur_fk
FOREIGN KEY (voie_id)
REFERENCES public.voie (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;


######################################################################### SPIT #
DROP TABLE IF EXISTS spit;
CREATE TABLE public.spit (
                topo_id INTEGER NOT NULL,
                numero SMALLINT NOT NULL,
                secteur_id INTEGER NOT NULL,
                longueur_id INTEGER NOT NULL,
                cotation COTATION_TYPE,
                relai BOOLEAN DEFAULT FALSE NOT NULL,
                commentaire TEXT,
                CONSTRAINT spit_pk PRIMARY KEY (topo_id, numero)
);

\d+ spit;

SELECT * FROM pg_catalog.pg_tables WHERE schemaname = 'public';

ALTER TABLE public.spit ADD CONSTRAINT topo_spit_fk
FOREIGN KEY (topo_id)
REFERENCES public.topo (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.spit ADD CONSTRAINT secteur_spit_fk
FOREIGN KEY (secteur_id)
REFERENCES public.secteur (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.spit ADD CONSTRAINT longueur_spit_fk
FOREIGN KEY (longueur_id)
REFERENCES public.longueur (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

\dt