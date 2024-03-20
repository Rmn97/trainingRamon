--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

-- Started on 2024-03-19 23:22:43

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 239 (class 1255 OID 17504)
-- Name: operacionesusuarios(json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.operacionesusuarios(injson json, OUT cmensaje character varying, OUT cjson character varying, OUT iestado smallint) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare 
	data json;
	i json ; 
	opcion smallint ; 
	ipuesto smallint ;
	iusuario integer ; 
BEGIN
    --raise notice 'function executed %', injson;
	data := injson->'data'; 
	--raise notice 'function executed %', data;
	opcion := injson->'opc';
	cmensaje := 'exito';
    iestado := 1;
	if (opcion = 1) then -- LISTAR
		cjson = (select array_to_json(array_agg(
				jsonb_build_object('idUsuario', id, 'nombres', nombres, 'idPuesto', puesto) 
			)
		)
		from usuarios where status = 1); 
		cmensaje := 'Datos encontrados';
	elsif (opcion = 2) then -- CREAR
		for i in select * from json_array_elements(data) loop 
			ipuesto := (i->>'puesto')::INT;
			insert into usuarios(nombres,puesto) values (i->>'nombres', ipuesto);
		end loop ; 
		cmensaje := 'Usuarios Guardados';
	elsif (opcion = 3) then -- MODIFICAR 
		for i in select * from json_array_elements(data) loop 
			iusuario := (i->>'idUsuario')::INT;
			if exists (select * from usuarios where id = iusuario) then 
				update usuarios set nombres = i->>'nombres', puesto = (i->>'puesto')::INT where id = iusuario ;
				cmensaje := 'Usuarios modificados con exito';
			else 
				cmensaje := 'El usuario con id ' || iusuario || ' no existe '  ; 
				iestado := -1 ; 
				exit ; 
			end if ; 
		end loop ; 
	elsif (opcion = 4) then -- ELIMINAR
		for i in select * from json_array_elements(data) loop 
				iusuario := (i->>'idUsuario')::INT;
				if exists (select * from usuarios where id = iusuario) then 
					update usuarios set status = 0 where id = iusuario;
					cmensaje := 'Usuarios dado de baja con exito';
				else 
					cmensaje := 'El usuario con id ' || iusuario || ' no existe '  ; 
					iestado := -1 ; 
					exit ; 
				end if ; 
		end loop ; 
	else 
		cmensaje := 'Opcion no valida';
	end if ;
    RETURN;
END;
$$;


ALTER FUNCTION public.operacionesusuarios(injson json, OUT cmensaje character varying, OUT cjson character varying, OUT iestado smallint) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 17472)
-- Name: operacionesusuarios(json, smallint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.operacionesusuarios(ijson json, OUT cmensaje character varying, iestado smallint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare 
	regJson json ; 
BEGIN
    raise notice 'function executed %' , ijson ; 
	iestado := 1 ; 
	cmensaje := 'exito' ; 
	return ; 
END; 
$$;


ALTER FUNCTION public.operacionesusuarios(ijson json, OUT cmensaje character varying, iestado smallint) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 17403)
-- Name: proyecto_tiene_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proyecto_tiene_usuarios (
    id integer NOT NULL,
    idproyecto integer NOT NULL,
    idusuario integer NOT NULL,
    fechaintegracion date,
    fechasalida date,
    estatus smallint DEFAULT 1,
    rol integer
);


ALTER TABLE public.proyecto_tiene_usuarios OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17402)
-- Name: proyecto_tiene_usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proyecto_tiene_usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proyecto_tiene_usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 219
-- Name: proyecto_tiene_usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proyecto_tiene_usuarios_id_seq OWNED BY public.proyecto_tiene_usuarios.id;


--
-- TOC entry 218 (class 1259 OID 17394)
-- Name: proyectos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proyectos (
    id integer NOT NULL,
    nombre character varying,
    status character varying,
    fechainicio date,
    fechafin date,
    descripcion character varying
);


ALTER TABLE public.proyectos OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17393)
-- Name: proyectos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proyectos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proyectos_id_seq OWNER TO postgres;

--
-- TOC entry 4907 (class 0 OID 0)
-- Dependencies: 217
-- Name: proyectos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proyectos_id_seq OWNED BY public.proyectos.id;


--
-- TOC entry 226 (class 1259 OID 17451)
-- Name: proyectos_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proyectos_roles (
    id integer NOT NULL,
    nombre character varying,
    status smallint DEFAULT 1
);


ALTER TABLE public.proyectos_roles OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17450)
-- Name: proyectos_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proyectos_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proyectos_roles_id_seq OWNER TO postgres;

--
-- TOC entry 4908 (class 0 OID 0)
-- Dependencies: 225
-- Name: proyectos_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proyectos_roles_id_seq OWNED BY public.proyectos_roles.id;


--
-- TOC entry 222 (class 1259 OID 17421)
-- Name: tareas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tareas (
    id integer NOT NULL,
    nombre character varying,
    descripcion character varying,
    fechainicio date,
    fechafin date,
    asignadoa integer,
    idproyecto integer,
    status smallint DEFAULT 1,
    complejidad smallint DEFAULT 0
);


ALTER TABLE public.tareas OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17420)
-- Name: tareas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tareas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tareas_id_seq OWNER TO postgres;

--
-- TOC entry 4909 (class 0 OID 0)
-- Dependencies: 221
-- Name: tareas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tareas_id_seq OWNED BY public.tareas.id;


--
-- TOC entry 216 (class 1259 OID 17385)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombres character varying,
    puesto integer,
    status smallint DEFAULT 1
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 17384)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 4910 (class 0 OID 0)
-- Dependencies: 215
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- TOC entry 224 (class 1259 OID 17441)
-- Name: usuarios_puestos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios_puestos (
    id integer NOT NULL,
    nombre character varying,
    status smallint DEFAULT 1
);


ALTER TABLE public.usuarios_puestos OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17440)
-- Name: usuarios_puestos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_puestos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_puestos_id_seq OWNER TO postgres;

--
-- TOC entry 4911 (class 0 OID 0)
-- Dependencies: 223
-- Name: usuarios_puestos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_puestos_id_seq OWNED BY public.usuarios_puestos.id;


--
-- TOC entry 4718 (class 2604 OID 17406)
-- Name: proyecto_tiene_usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_tiene_usuarios ALTER COLUMN id SET DEFAULT nextval('public.proyecto_tiene_usuarios_id_seq'::regclass);


--
-- TOC entry 4717 (class 2604 OID 17397)
-- Name: proyectos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyectos ALTER COLUMN id SET DEFAULT nextval('public.proyectos_id_seq'::regclass);


--
-- TOC entry 4725 (class 2604 OID 17454)
-- Name: proyectos_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyectos_roles ALTER COLUMN id SET DEFAULT nextval('public.proyectos_roles_id_seq'::regclass);


--
-- TOC entry 4720 (class 2604 OID 17424)
-- Name: tareas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tareas ALTER COLUMN id SET DEFAULT nextval('public.tareas_id_seq'::regclass);


--
-- TOC entry 4715 (class 2604 OID 17388)
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- TOC entry 4723 (class 2604 OID 17444)
-- Name: usuarios_puestos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_puestos ALTER COLUMN id SET DEFAULT nextval('public.usuarios_puestos_id_seq'::regclass);


--
-- TOC entry 4893 (class 0 OID 17403)
-- Dependencies: 220
-- Data for Name: proyecto_tiene_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proyecto_tiene_usuarios (id, idproyecto, idusuario, fechaintegracion, fechasalida, estatus, rol) FROM stdin;
\.


--
-- TOC entry 4891 (class 0 OID 17394)
-- Dependencies: 218
-- Data for Name: proyectos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proyectos (id, nombre, status, fechainicio, fechafin, descripcion) FROM stdin;
1	Projecto 1	1	2024-03-14	\N	Projecto de prueba
\.


--
-- TOC entry 4899 (class 0 OID 17451)
-- Dependencies: 226
-- Data for Name: proyectos_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proyectos_roles (id, nombre, status) FROM stdin;
1	DESARROLLADOR BACKEND	1
2	DESARROLLADOR FRONTENDT	1
3	DESARROLLADOR FULLSTACK	1
4	LIDER TECNICO	1
5	ARQUITECTO	1
6	TESTER FUNCIONAL	1
7	TESTER AUTOMATIZADOR	1
8	LIDER PROYECTO	1
\.


--
-- TOC entry 4895 (class 0 OID 17421)
-- Dependencies: 222
-- Data for Name: tareas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tareas (id, nombre, descripcion, fechainicio, fechafin, asignadoa, idproyecto, status, complejidad) FROM stdin;
\.


--
-- TOC entry 4889 (class 0 OID 17385)
-- Dependencies: 216
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, nombres, puesto, status) FROM stdin;
1	el chuy	3	1
2	el ramon	2	1
3	Anahi	5	1
4	"Marlen"	8	1
5	"Renato"	5	1
6	Monserrat Valenzuela	2	1
10	Jose Carlos	8	1
9	Roberto Cervantes	9	0
7	Daniel Sauceda	8	0
\.


--
-- TOC entry 4897 (class 0 OID 17441)
-- Dependencies: 224
-- Data for Name: usuarios_puestos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios_puestos (id, nombre, status) FROM stdin;
1	Programador Jr	1
2	Programador Semi Senior	1
3	Programador Senior	1
4	Tester jr	1
5	Tester Semi Senior	1
6	Tester Senior	1
7	Arquitecto	1
8	Project Manager	1
9	Scrum Master	1
\.


--
-- TOC entry 4912 (class 0 OID 0)
-- Dependencies: 219
-- Name: proyecto_tiene_usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proyecto_tiene_usuarios_id_seq', 1, false);


--
-- TOC entry 4913 (class 0 OID 0)
-- Dependencies: 217
-- Name: proyectos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proyectos_id_seq', 1, true);


--
-- TOC entry 4914 (class 0 OID 0)
-- Dependencies: 225
-- Name: proyectos_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proyectos_roles_id_seq', 8, true);


--
-- TOC entry 4915 (class 0 OID 0)
-- Dependencies: 221
-- Name: tareas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tareas_id_seq', 1, false);


--
-- TOC entry 4916 (class 0 OID 0)
-- Dependencies: 215
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 10, true);


--
-- TOC entry 4917 (class 0 OID 0)
-- Dependencies: 223
-- Name: usuarios_puestos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_puestos_id_seq', 9, true);


--
-- TOC entry 4732 (class 2606 OID 17409)
-- Name: proyecto_tiene_usuarios proyecto_tiene_usuarios_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_tiene_usuarios
    ADD CONSTRAINT proyecto_tiene_usuarios_pk PRIMARY KEY (id);


--
-- TOC entry 4730 (class 2606 OID 17401)
-- Name: proyectos proyectos_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyectos
    ADD CONSTRAINT proyectos_pk PRIMARY KEY (id);


--
-- TOC entry 4738 (class 2606 OID 17459)
-- Name: proyectos_roles proyectos_roles_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyectos_roles
    ADD CONSTRAINT proyectos_roles_pk PRIMARY KEY (id);


--
-- TOC entry 4734 (class 2606 OID 17428)
-- Name: tareas tareas_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tareas
    ADD CONSTRAINT tareas_pk PRIMARY KEY (id);


--
-- TOC entry 4728 (class 2606 OID 17392)
-- Name: usuarios usuarios_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pk PRIMARY KEY (id);


--
-- TOC entry 4736 (class 2606 OID 17449)
-- Name: usuarios_puestos usuarios_puestos_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_puestos
    ADD CONSTRAINT usuarios_puestos_pk PRIMARY KEY (id);


--
-- TOC entry 4740 (class 2606 OID 17410)
-- Name: proyecto_tiene_usuarios proyecto_tiene_usuarios_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_tiene_usuarios
    ADD CONSTRAINT proyecto_tiene_usuarios_fk FOREIGN KEY (idusuario) REFERENCES public.usuarios(id);


--
-- TOC entry 4741 (class 2606 OID 17415)
-- Name: proyecto_tiene_usuarios proyecto_tiene_usuarios_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_tiene_usuarios
    ADD CONSTRAINT proyecto_tiene_usuarios_fk_1 FOREIGN KEY (idproyecto) REFERENCES public.proyectos(id);


--
-- TOC entry 4742 (class 2606 OID 17460)
-- Name: proyecto_tiene_usuarios proyecto_tiene_usuarios_rol_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto_tiene_usuarios
    ADD CONSTRAINT proyecto_tiene_usuarios_rol_fk FOREIGN KEY (rol) REFERENCES public.proyectos_roles(id);


--
-- TOC entry 4743 (class 2606 OID 17429)
-- Name: tareas tareas_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tareas
    ADD CONSTRAINT tareas_fk FOREIGN KEY (asignadoa) REFERENCES public.usuarios(id);


--
-- TOC entry 4744 (class 2606 OID 17435)
-- Name: tareas tareas_proyectos_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tareas
    ADD CONSTRAINT tareas_proyectos_fk FOREIGN KEY (idproyecto) REFERENCES public.proyectos(id);


--
-- TOC entry 4739 (class 2606 OID 17465)
-- Name: usuarios usuarios_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_fk FOREIGN KEY (puesto) REFERENCES public.usuarios_puestos(id);


-- Completed on 2024-03-19 23:22:44

--
-- PostgreSQL database dump complete
--

