--
-- PostgreSQL database dump
--

\restrict yW2F5SETFJcsHh0aXuylvG1IwNalVXn6WGIfv2iJJEPSTkcRSgpydwCLZ2dV6wd

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-09 18:24:32

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 238 (class 1255 OID 17139)
-- Name: aggiorna_num_visualizzazioni(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.aggiorna_num_visualizzazioni() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF(TG_OP = 'INSERT') THEN
		UPDATE contenutimultimediali
		SET Numvisualizzazioni = numvisualizzazioni + 1
		WHERE ID_Elemento = OLD.ID_Elemento;
		RETURN NEW;
	ELSEIF(TG_OP = 'DELETE') THEN
		UPDATE contenutimultimediali
		SET Numvisualizzazioni = numvisualizzazioni - 1
		WHERE ID_Elemento = OLD.ID_Elemento;
		RETURN OLD;
	END IF;
END;
$$;


ALTER FUNCTION public.aggiorna_num_visualizzazioni() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 17143)
-- Name: deriva_views_playlist_pubblica(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deriva_views_playlist_pubblica() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF(TG_OP = 'INSERT') THEN
		UPDATE playlist_Pubblica
		SET numvisualizzazioni = numvisualizzazioni + 1
		WHERE ID_Playlist = NEW.ID_Playlist;
		RETURN NEW;
	ELSEIF(TG_OP = 'DELETE')THEN
		UPDATE playlist_Pubblica
		SET numvisualizzazioni = numvisualizzazioni - 1
		WHERE ID_Playlist = OLD.ID_Playlist;
		RETURN OLD;
	END IF;
END;

$$;


ALTER FUNCTION public.deriva_views_playlist_pubblica() OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 17145)
-- Name: verifica_vincoli_playlist(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verifica_vincoli_playlist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    conteggio INT := 0;
BEGIN
    -- Contiamo in quante tabelle figlie appare l'ID della playlist attuale
    SELECT 
        (SELECT COUNT(*) FROM Playlist_Privata WHERE ID_Playlist = NEW.ID_Playlist) +
        (SELECT COUNT(*) FROM Playlist_Pubblica WHERE ID_Playlist = NEW.ID_Playlist) +
        (SELECT COUNT(*) FROM Playlist_Condivisa WHERE ID_Playlist = NEW.ID_Playlist)
    INTO conteggio;

    -- Vincolo di Totalità: conteggio non può essere 0
    IF conteggio = 0 THEN
        RAISE EXCEPTION 'Violazione Vincolo_Totalita_Playlist: La playlist % deve essere associata a Privata, Pubblica o Condivisa.', NEW.ID_Playlist;
    -- Vincolo di Disgiunzione: conteggio non può essere maggiore di 1
    ELSIF conteggio > 1 THEN
        RAISE EXCEPTION 'Violazione Vincolo_Disgiunzione_Playlist: La playlist % non può appartenere a più di una categoria contemporaneamente.', NEW.ID_Playlist;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.verifica_vincoli_playlist() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 235 (class 1259 OID 17095)
-- Name: accesso_o_modifica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accesso_o_modifica (
    id_utente integer,
    id_playlist integer
);


ALTER TABLE public.accesso_o_modifica OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17078)
-- Name: appartiene_categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appartiene_categoria (
    id_categoria integer NOT NULL,
    id_playlist integer NOT NULL
);


ALTER TABLE public.appartiene_categoria OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17071)
-- Name: categorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorie (
    id_categoria integer NOT NULL,
    nomecategoria character varying(50)
);


ALTER TABLE public.categorie OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17070)
-- Name: categorie_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorie_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorie_id_categoria_seq OWNER TO postgres;

--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 232
-- Name: categorie_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorie_id_categoria_seq OWNED BY public.categorie.id_categoria;


--
-- TOC entry 222 (class 1259 OID 16964)
-- Name: contenutimultimediali; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contenutimultimediali (
    id_elemento integer NOT NULL,
    titolo character varying(50) NOT NULL,
    descrizione character varying(500),
    durata bigint NOT NULL,
    datacreazione date NOT NULL,
    immaginecopertina character varying(500),
    numvisualizzazioni bigint DEFAULT 0,
    tipoelemento character(5) NOT NULL,
    bitrate smallint,
    risoluzione character varying(10),
    id_utente integer NOT NULL,
    CONSTRAINT vincolo_durata_positiva CHECK ((durata > 0)),
    CONSTRAINT vincolo_gerarchia_elemento CHECK ((((tipoelemento = 'video'::bpchar) AND (risoluzione IS NOT NULL) AND (bitrate IS NULL)) OR ((tipoelemento = 'audio'::bpchar) AND (bitrate IS NOT NULL) AND (risoluzione IS NULL))))
);


ALTER TABLE public.contenutimultimediali OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16963)
-- Name: contenutimultimediali_id_elemento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contenutimultimediali_id_elemento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contenutimultimediali_id_elemento_seq OWNER TO postgres;

--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 221
-- Name: contenutimultimediali_id_elemento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contenutimultimediali_id_elemento_seq OWNED BY public.contenutimultimediali.id_elemento;


--
-- TOC entry 236 (class 1259 OID 17108)
-- Name: contiene; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contiene (
    id_elemento integer,
    id_playlist integer
);


ALTER TABLE public.contiene OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16984)
-- Name: fruizioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fruizioni (
    id_utente integer NOT NULL,
    id_elemento integer NOT NULL,
    datafruizione timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.fruizioni OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17001)
-- Name: playlist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlist (
    id_playlist integer NOT NULL,
    nome character varying(50),
    datacreazione timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    id_utente integer
);


ALTER TABLE public.playlist OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17034)
-- Name: playlist_condivisa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlist_condivisa (
    id_playlist integer NOT NULL,
    url_invito character varying(200) NOT NULL,
    id_utente integer
);


ALTER TABLE public.playlist_condivisa OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17033)
-- Name: playlist_condivisa_id_playlist_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlist_condivisa_id_playlist_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.playlist_condivisa_id_playlist_seq OWNER TO postgres;

--
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 228
-- Name: playlist_condivisa_id_playlist_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlist_condivisa_id_playlist_seq OWNED BY public.playlist_condivisa.id_playlist;


--
-- TOC entry 224 (class 1259 OID 17000)
-- Name: playlist_id_playlist_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlist_id_playlist_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.playlist_id_playlist_seq OWNER TO postgres;

--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 224
-- Name: playlist_id_playlist_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlist_id_playlist_seq OWNED BY public.playlist.id_playlist;


--
-- TOC entry 231 (class 1259 OID 17053)
-- Name: playlist_privata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlist_privata (
    id_playlist integer NOT NULL,
    id_utente integer
);


ALTER TABLE public.playlist_privata OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17052)
-- Name: playlist_privata_id_playlist_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlist_privata_id_playlist_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.playlist_privata_id_playlist_seq OWNER TO postgres;

--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 230
-- Name: playlist_privata_id_playlist_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlist_privata_id_playlist_seq OWNED BY public.playlist_privata.id_playlist;


--
-- TOC entry 227 (class 1259 OID 17015)
-- Name: playlist_pubblica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlist_pubblica (
    id_playlist integer NOT NULL,
    categoria character varying(50),
    numvisualizzazioni bigint DEFAULT 0,
    id_utente integer
);


ALTER TABLE public.playlist_pubblica OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17014)
-- Name: playlist_pubblica_id_playlist_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlist_pubblica_id_playlist_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.playlist_pubblica_id_playlist_seq OWNER TO postgres;

--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 226
-- Name: playlist_pubblica_id_playlist_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlist_pubblica_id_playlist_seq OWNED BY public.playlist_pubblica.id_playlist;


--
-- TOC entry 237 (class 1259 OID 17121)
-- Name: salva_o_visualizza; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salva_o_visualizza (
    id_utente integer,
    id_playlist integer
);


ALTER TABLE public.salva_o_visualizza OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16945)
-- Name: utenti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utenti (
    id_utente integer NOT NULL,
    nome character varying(50) NOT NULL,
    cognome character varying(50) NOT NULL,
    username character varying(50) NOT NULL,
    psswrd character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    matricola character(9),
    CONSTRAINT vincolo_dominio_email CHECK (((email)::text ~~ '%@unina.it'::text))
);


ALTER TABLE public.utenti OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16944)
-- Name: utenti_id_utente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utenti_id_utente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utenti_id_utente_seq OWNER TO postgres;

--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 219
-- Name: utenti_id_utente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utenti_id_utente_seq OWNED BY public.utenti.id_utente;


--
-- TOC entry 4919 (class 2604 OID 17074)
-- Name: categorie id_categoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie ALTER COLUMN id_categoria SET DEFAULT nextval('public.categorie_id_categoria_seq'::regclass);


--
-- TOC entry 4910 (class 2604 OID 16967)
-- Name: contenutimultimediali id_elemento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenutimultimediali ALTER COLUMN id_elemento SET DEFAULT nextval('public.contenutimultimediali_id_elemento_seq'::regclass);


--
-- TOC entry 4913 (class 2604 OID 17004)
-- Name: playlist id_playlist; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist ALTER COLUMN id_playlist SET DEFAULT nextval('public.playlist_id_playlist_seq'::regclass);


--
-- TOC entry 4917 (class 2604 OID 17037)
-- Name: playlist_condivisa id_playlist; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_condivisa ALTER COLUMN id_playlist SET DEFAULT nextval('public.playlist_condivisa_id_playlist_seq'::regclass);


--
-- TOC entry 4918 (class 2604 OID 17056)
-- Name: playlist_privata id_playlist; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_privata ALTER COLUMN id_playlist SET DEFAULT nextval('public.playlist_privata_id_playlist_seq'::regclass);


--
-- TOC entry 4915 (class 2604 OID 17018)
-- Name: playlist_pubblica id_playlist; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_pubblica ALTER COLUMN id_playlist SET DEFAULT nextval('public.playlist_pubblica_id_playlist_seq'::regclass);


--
-- TOC entry 4909 (class 2604 OID 16948)
-- Name: utenti id_utente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utenti ALTER COLUMN id_utente SET DEFAULT nextval('public.utenti_id_utente_seq'::regclass);


--
-- TOC entry 5129 (class 0 OID 17095)
-- Dependencies: 235
-- Data for Name: accesso_o_modifica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accesso_o_modifica (id_utente, id_playlist) FROM stdin;
1	30
2	30
\.


--
-- TOC entry 5128 (class 0 OID 17078)
-- Dependencies: 234
-- Data for Name: appartiene_categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.appartiene_categoria (id_categoria, id_playlist) FROM stdin;
1	20
\.


--
-- TOC entry 5127 (class 0 OID 17071)
-- Dependencies: 233
-- Data for Name: categorie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorie (id_categoria, nomecategoria) FROM stdin;
1	Musica Pop
2	Tutorial Programmazione
3	Podcast Scientifici
\.


--
-- TOC entry 5116 (class 0 OID 16964)
-- Dependencies: 222
-- Data for Name: contenutimultimediali; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contenutimultimediali (id_elemento, titolo, descrizione, durata, datacreazione, immaginecopertina, numvisualizzazioni, tipoelemento, bitrate, risoluzione, id_utente) FROM stdin;
1	Lezione 1 SQL	Introduzione alle basi di dati	3600	2026-01-10	thumb_sql1.jpg	0	video	\N	1080p	1
2	Canzone Estiva 2026	Hit del momento	210	2026-05-01	cover_pop.jpg	0	audio	320	\N	2
3	Podcast Intelligenza Artificiale	Discussione sul futuro dell'AI	2400	2026-06-01	podcast_ai.jpg	0	audio	192	\N	1
4	Video Corso PostgreSQL Avanzato	Guida ai trigger e funzioni	5400	2026-06-05	thumb_postgres.jpg	0	video	\N	4K	3
9	 dovresti funzionare	questa insert non dovrebbe violare i vincoli	2400	2026-09-06	qualcosa.formato	0	video	\N	4k	2
\.


--
-- TOC entry 5130 (class 0 OID 17108)
-- Dependencies: 236
-- Data for Name: contiene; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contiene (id_elemento, id_playlist) FROM stdin;
1	10
4	10
2	20
3	30
\.


--
-- TOC entry 5117 (class 0 OID 16984)
-- Dependencies: 223
-- Data for Name: fruizioni; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fruizioni (id_utente, id_elemento, datafruizione) FROM stdin;
1	1	2026-06-09 18:12:59.398846+02
2	1	2026-06-09 18:12:59.398846+02
3	2	2026-06-09 18:12:59.398846+02
\.


--
-- TOC entry 5119 (class 0 OID 17001)
-- Dependencies: 225
-- Data for Name: playlist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlist (id_playlist, nome, datacreazione, id_utente) FROM stdin;
10	I miei Video di Studio	2026-06-09 18:12:59.398846+02	1
20	Canzoni Preferite Pubbliche	2026-06-09 18:12:59.398846+02	2
30	Progetto di Gruppo Condiviso	2026-06-09 18:12:59.398846+02	3
\.


--
-- TOC entry 5123 (class 0 OID 17034)
-- Dependencies: 229
-- Data for Name: playlist_condivisa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlist_condivisa (id_playlist, url_invito, id_utente) FROM stdin;
30	https://unina.it/invite/playlist/30xyz	3
\.


--
-- TOC entry 5125 (class 0 OID 17053)
-- Dependencies: 231
-- Data for Name: playlist_privata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlist_privata (id_playlist, id_utente) FROM stdin;
10	1
\.


--
-- TOC entry 5121 (class 0 OID 17015)
-- Dependencies: 227
-- Data for Name: playlist_pubblica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlist_pubblica (id_playlist, categoria, numvisualizzazioni, id_utente) FROM stdin;
20	Musica	2	2
\.


--
-- TOC entry 5131 (class 0 OID 17121)
-- Dependencies: 237
-- Data for Name: salva_o_visualizza; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salva_o_visualizza (id_utente, id_playlist) FROM stdin;
1	20
3	20
\.


--
-- TOC entry 5114 (class 0 OID 16945)
-- Dependencies: 220
-- Data for Name: utenti; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utenti (id_utente, nome, cognome, username, psswrd, email, matricola) FROM stdin;
1	Mario	Rossi	mariorossi	password123	mario.rossi@unina.it	N86001234
2	Giuseppe	Verdi	peppeverdi	secure456	g.verdi@unina.it	N86001235
3	Anna	Bianchi	annab	secret789	a.bianchi@unina.it	N86001236
\.


--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 232
-- Name: categorie_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorie_id_categoria_seq', 3, true);


--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 221
-- Name: contenutimultimediali_id_elemento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contenutimultimediali_id_elemento_seq', 9, true);


--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 228
-- Name: playlist_condivisa_id_playlist_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlist_condivisa_id_playlist_seq', 1, false);


--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 224
-- Name: playlist_id_playlist_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlist_id_playlist_seq', 30, true);


--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 230
-- Name: playlist_privata_id_playlist_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlist_privata_id_playlist_seq', 1, false);


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 226
-- Name: playlist_pubblica_id_playlist_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlist_pubblica_id_playlist_seq', 1, false);


--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 219
-- Name: utenti_id_utente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utenti_id_utente_seq', 3, true);


--
-- TOC entry 4924 (class 2606 OID 16960)
-- Name: utenti Vincolo_Email_Univoca; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT "Vincolo_Email_Univoca" UNIQUE (email);


--
-- TOC entry 4926 (class 2606 OID 16958)
-- Name: utenti Vincolo_Username_Univoco; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT "Vincolo_Username_Univoco" UNIQUE (username);


--
-- TOC entry 4944 (class 2606 OID 17084)
-- Name: appartiene_categoria appartiene_categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appartiene_categoria
    ADD CONSTRAINT appartiene_categoria_pkey PRIMARY KEY (id_categoria, id_playlist);


--
-- TOC entry 4942 (class 2606 OID 17077)
-- Name: categorie categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie
    ADD CONSTRAINT categorie_pkey PRIMARY KEY (id_categoria);


--
-- TOC entry 4932 (class 2606 OID 16978)
-- Name: contenutimultimediali contenutimultimediali_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenutimultimediali
    ADD CONSTRAINT contenutimultimediali_pkey PRIMARY KEY (id_elemento);


--
-- TOC entry 4938 (class 2606 OID 17041)
-- Name: playlist_condivisa playlist_condivisa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_condivisa
    ADD CONSTRAINT playlist_condivisa_pkey PRIMARY KEY (id_playlist);


--
-- TOC entry 4934 (class 2606 OID 17008)
-- Name: playlist playlist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist
    ADD CONSTRAINT playlist_pkey PRIMARY KEY (id_playlist);


--
-- TOC entry 4940 (class 2606 OID 17059)
-- Name: playlist_privata playlist_privata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_privata
    ADD CONSTRAINT playlist_privata_pkey PRIMARY KEY (id_playlist);


--
-- TOC entry 4936 (class 2606 OID 17022)
-- Name: playlist_pubblica playlist_pubblica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_pubblica
    ADD CONSTRAINT playlist_pubblica_pkey PRIMARY KEY (id_playlist);


--
-- TOC entry 4928 (class 2606 OID 16962)
-- Name: utenti utenti_matricola_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT utenti_matricola_key UNIQUE (matricola);


--
-- TOC entry 4930 (class 2606 OID 16956)
-- Name: utenti utenti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utenti
    ADD CONSTRAINT utenti_pkey PRIMARY KEY (id_utente);


--
-- TOC entry 4964 (class 2620 OID 17146)
-- Name: playlist trg_verifica_vincoli_playlist; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE CONSTRAINT TRIGGER trg_verifica_vincoli_playlist AFTER INSERT OR UPDATE ON public.playlist DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.verifica_vincoli_playlist();


--
-- TOC entry 4963 (class 2620 OID 17140)
-- Name: fruizioni vincolo_derivazione_views_elemento; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER vincolo_derivazione_views_elemento AFTER INSERT OR DELETE ON public.fruizioni FOR EACH ROW EXECUTE FUNCTION public.aggiorna_num_visualizzazioni();


--
-- TOC entry 4965 (class 2620 OID 17144)
-- Name: salva_o_visualizza vincolo_derivazione_views_pubblica; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER vincolo_derivazione_views_pubblica AFTER INSERT OR DELETE ON public.salva_o_visualizza FOR EACH ROW EXECUTE FUNCTION public.deriva_views_playlist_pubblica();


--
-- TOC entry 4957 (class 2606 OID 17103)
-- Name: accesso_o_modifica accesso_o_modifica_id_playlist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accesso_o_modifica
    ADD CONSTRAINT accesso_o_modifica_id_playlist_fkey FOREIGN KEY (id_playlist) REFERENCES public.playlist_condivisa(id_playlist) ON UPDATE CASCADE;


--
-- TOC entry 4958 (class 2606 OID 17098)
-- Name: accesso_o_modifica accesso_o_modifica_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accesso_o_modifica
    ADD CONSTRAINT accesso_o_modifica_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE;


--
-- TOC entry 4955 (class 2606 OID 17085)
-- Name: appartiene_categoria appartiene_categoria_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appartiene_categoria
    ADD CONSTRAINT appartiene_categoria_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categorie(id_categoria) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4956 (class 2606 OID 17090)
-- Name: appartiene_categoria appartiene_categoria_id_playlist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appartiene_categoria
    ADD CONSTRAINT appartiene_categoria_id_playlist_fkey FOREIGN KEY (id_playlist) REFERENCES public.playlist_pubblica(id_playlist) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4945 (class 2606 OID 16979)
-- Name: contenutimultimediali contenutimultimediali_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contenutimultimediali
    ADD CONSTRAINT contenutimultimediali_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4959 (class 2606 OID 17111)
-- Name: contiene contiene_id_elemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contiene
    ADD CONSTRAINT contiene_id_elemento_fkey FOREIGN KEY (id_elemento) REFERENCES public.contenutimultimediali(id_elemento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4960 (class 2606 OID 17116)
-- Name: contiene contiene_id_playlist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contiene
    ADD CONSTRAINT contiene_id_playlist_fkey FOREIGN KEY (id_playlist) REFERENCES public.playlist(id_playlist) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4946 (class 2606 OID 16995)
-- Name: fruizioni fruizioni_id_elemento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fruizioni
    ADD CONSTRAINT fruizioni_id_elemento_fkey FOREIGN KEY (id_elemento) REFERENCES public.contenutimultimediali(id_elemento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4947 (class 2606 OID 16990)
-- Name: fruizioni fruizioni_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fruizioni
    ADD CONSTRAINT fruizioni_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE;


--
-- TOC entry 4951 (class 2606 OID 17047)
-- Name: playlist_condivisa playlist_condivisa_id_playlist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_condivisa
    ADD CONSTRAINT playlist_condivisa_id_playlist_fkey FOREIGN KEY (id_playlist) REFERENCES public.playlist(id_playlist) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4952 (class 2606 OID 17042)
-- Name: playlist_condivisa playlist_condivisa_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_condivisa
    ADD CONSTRAINT playlist_condivisa_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4948 (class 2606 OID 17009)
-- Name: playlist playlist_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist
    ADD CONSTRAINT playlist_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4953 (class 2606 OID 17065)
-- Name: playlist_privata playlist_privata_id_playlist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_privata
    ADD CONSTRAINT playlist_privata_id_playlist_fkey FOREIGN KEY (id_playlist) REFERENCES public.playlist(id_playlist) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4954 (class 2606 OID 17060)
-- Name: playlist_privata playlist_privata_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_privata
    ADD CONSTRAINT playlist_privata_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4949 (class 2606 OID 17028)
-- Name: playlist_pubblica playlist_pubblica_id_playlist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_pubblica
    ADD CONSTRAINT playlist_pubblica_id_playlist_fkey FOREIGN KEY (id_playlist) REFERENCES public.playlist(id_playlist) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4950 (class 2606 OID 17023)
-- Name: playlist_pubblica playlist_pubblica_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist_pubblica
    ADD CONSTRAINT playlist_pubblica_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4961 (class 2606 OID 17129)
-- Name: salva_o_visualizza salva_o_visualizza_id_playlist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salva_o_visualizza
    ADD CONSTRAINT salva_o_visualizza_id_playlist_fkey FOREIGN KEY (id_playlist) REFERENCES public.playlist_pubblica(id_playlist) ON UPDATE CASCADE;


--
-- TOC entry 4962 (class 2606 OID 17124)
-- Name: salva_o_visualizza salva_o_visualizza_id_utente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salva_o_visualizza
    ADD CONSTRAINT salva_o_visualizza_id_utente_fkey FOREIGN KEY (id_utente) REFERENCES public.utenti(id_utente) ON UPDATE CASCADE;


-- Completed on 2026-06-09 18:24:32

--
-- PostgreSQL database dump complete
--

\unrestrict yW2F5SETFJcsHh0aXuylvG1IwNalVXn6WGIfv2iJJEPSTkcRSgpydwCLZ2dV6wd

