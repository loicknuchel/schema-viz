CREATE TABLE public.users
(
    id          int          NOT NULL,
    first_name  varchar(255) NOT NULL,
    last_name   varchar(255) NOT NULL,
    email       varchar(255),
    external_id uuid
);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_email_uniq UNIQUE (email);

CREATE INDEX user_name_index ON public.users USING btree (first_name, last_name);

COMMENT ON TABLE public.users IS 'A table to store all users and in a single diagram control them, for the better or worse!';
COMMENT ON COLUMN public.users.id IS 'The user id which is automatically defined based on subscription order. Should never change!';

CREATE TABLE public.roles
(
    id          int          NOT NULL,
    slug        varchar(255) NOT NULL,
    name        varchar(255) NOT NULL,
    description text,
    created_at  timestamp    NOT NULL,
    updated_at  timestamp    NOT NULL
);

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_slug_uniq UNIQUE (slug);

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_uniq UNIQUE (name);

CREATE TABLE public.credentials
(
    user_id  int          NOT NULL,
    login    varchar(255) NOT NULL,
    password varchar(255) NOT NULL
);

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users (id);

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_login_uniq UNIQUE (login);

CREATE TABLE public.role_user
(
    id         int       NOT NULL,
    role_id    int       NOT NULL,
    user_id    int       NOT NULL,
    created_at timestamp NOT NULL,
    updated_at timestamp NOT NULL
);

ALTER TABLE ONLY public.role_user
    ADD CONSTRAINT role_user_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.role_user
    ADD CONSTRAINT role_user_role_id_fk FOREIGN KEY (role_id) REFERENCES public.roles (id);

ALTER TABLE ONLY public.role_user
    ADD CONSTRAINT role_user_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users (id);
