
--
-- Name: table1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.table1 (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone
);

COMMENT ON TABLE public.table1 IS 'This is the first table';

COMMENT ON COLUMN public.table1.user_id IS 'An external ''id'' or "value"';

ALTER TABLE public.table1
    ADD CONSTRAINT big_user_id CHECK ((user_id > 10)) NOT VALID;

CREATE TABLE public.table2 (
    id bigint NOT NULL,
    table1_id uuid NOT NULL,
    name character varying(255),
    is_fixed boolean DEFAULT true,
    min_price numeric(8,2),
    max_price numeric(8,2),
    CONSTRAINT max_greater_than_min CHECK ((min_price < max_price))
);

CREATE SEQUENCE public.table2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.table2_id_seq OWNED BY public.table2.id;

ALTER TABLE ONLY public.table2
    ADD CONSTRAINT table2_id_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.table2
    ADD CONSTRAINT table2_table1_id_fk FOREIGN KEY (table1_id) REFERENCES public.table1(id);

ALTER TABLE ONLY public.table2 ALTER COLUMN id SET DEFAULT nextval('public.table2_id_seq'::regclass);

ALTER TABLE ONLY public.table2 ALTER COLUMN table1_id SET STATISTICS 5000;

ALTER TABLE ONLY public.table2
    ADD CONSTRAINT name_unique UNIQUE (table1_id, name);

CREATE VIEW public.table2_view AS
SELECT table2.id,
       table2.name,
       CASE
           WHEN table2.min_price < 10 THEN 'cheap'
           ELSE 'expensive'
           END AS price
FROM public.table2;
