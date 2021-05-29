
--
-- Name: table1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.table1 (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone
);


--
-- Name: table2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.table2 (
    id bigint NOT NULL,
    name character varying(255),
    is_fixed boolean DEFAULT true,
    min_price numeric(8,2),
    max_price numeric(8,2)
);
