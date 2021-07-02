module SqlParser.SchemaParserTest exposing (..)

import Expect
import SqlParser.SchemaParser exposing (Line, Statement, buildRawSql, buildStatements, parseLines)
import Test exposing (Test, describe, test)


fileName : String
fileName =
    "file.sql"


fileContent : String
fileContent =
    """
-- a comment

CREATE TABLE public.users (
  id bigint NOT NULL,
  name character varying(255)
);

COMMENT ON TABLE public.users IS 'A comment ; ''tricky'' one';

ALTER TABLE ONLY public.users
  ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);
"""


fileLines : List Line
fileLines =
    [ { file = fileName, line = 1, text = "" }
    , { file = fileName, line = 2, text = "-- a comment" }
    , { file = fileName, line = 3, text = "" }
    , { file = fileName, line = 4, text = "CREATE TABLE public.users (" }
    , { file = fileName, line = 5, text = "  id bigint NOT NULL," }
    , { file = fileName, line = 6, text = "  name character varying(255)" }
    , { file = fileName, line = 7, text = ");" }
    , { file = fileName, line = 8, text = "" }
    , { file = fileName, line = 9, text = "COMMENT ON TABLE public.users IS 'A comment ; ''tricky'' one';" }
    , { file = fileName, line = 10, text = "" }
    , { file = fileName, line = 11, text = "ALTER TABLE ONLY public.users" }
    , { file = fileName, line = 12, text = "  ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);" }
    , { file = fileName, line = 13, text = "" }
    ]


fileStatements : List Statement
fileStatements =
    [ { first = { file = fileName, line = 4, text = "CREATE TABLE public.users (" }
      , others =
            [ { file = fileName, line = 5, text = "  id bigint NOT NULL," }
            , { file = fileName, line = 6, text = "  name character varying(255)" }
            , { file = fileName, line = 7, text = ");" }
            ]
      }
    , { first = { file = fileName, line = 9, text = "COMMENT ON TABLE public.users IS 'A comment ; ''tricky'' one';" }, others = [] }
    , { first = { file = fileName, line = 11, text = "ALTER TABLE ONLY public.users" }
      , others = [ { file = fileName, line = 12, text = "  ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);" } ]
      }
    ]


suite : Test
suite =
    describe "SchemaParserTest"
        [ describe "buildRawSql"
            [ test "basic"
                (\_ ->
                    buildRawSql
                        { first = { file = fileName, line = 11, text = "ALTER TABLE ONLY public.users" }
                        , others = [ { file = fileName, line = 12, text = "  ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);" } ]
                        }
                        |> Expect.equal "ALTER TABLE ONLY public.users   ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);"
                )
            ]
        , describe "parseLines"
            [ test "basic" (\_ -> parseLines fileName fileContent |> Expect.equal fileLines)
            ]
        , describe "buildStatements"
            [ test "basic" (\_ -> buildStatements fileLines |> Expect.equal fileStatements)
            ]
        ]
