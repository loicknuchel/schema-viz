module SqlParser.Parsers.CommentTest exposing (..)

import Expect
import SqlParser.Parsers.Comment exposing (parseColumnComment, parseTableComment)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Comment"
        [ describe "parseTableComment"
            [ test "basic" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", comment = "A comment" }))
            , test "with quotes" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A ''good'' comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", comment = "A 'good' comment" }))
            , test "with semicolon" (\_ -> parseTableComment "COMMENT ON TABLE public.table1 IS 'A ; comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", comment = "A ; comment" }))
            , test "bad" (\_ -> parseTableComment "bad" |> Expect.equal (Err [ "Can't parse table comment: 'bad'" ]))
            ]
        , describe "parseColumnComment"
            [ test "basic" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", column = "col", comment = "A comment" }))
            , test "with quotes" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A ''good'' comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", column = "col", comment = "A 'good' comment" }))
            , test "with semicolon" (\_ -> parseColumnComment "COMMENT ON COLUMN public.table1.col IS 'A ; comment';" |> Expect.equal (Ok { schema = Just "public", table = "table1", column = "col", comment = "A ; comment" }))
            , test "bad" (\_ -> parseColumnComment "bad" |> Expect.equal (Err [ "Can't parse column comment: 'bad'" ]))
            ]
        ]
