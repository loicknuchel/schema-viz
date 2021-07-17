module Models.SchemaTest exposing (..)

import Expect
import Models.Schema exposing (TableId, htmlIdAsTableId, showTableName, stringAsTableId, tableIdAsHtmlId, tableIdAsString)
import Test exposing (Test, describe, test)


tableId : TableId
tableId =
    ( "public", "users" )


suite : Test
suite =
    describe "Models.Schema"
        [ describe "tableIdAsHtmlId"
            [ test "round-trip" (\_ -> tableId |> tableIdAsHtmlId |> htmlIdAsTableId |> Expect.equal tableId)
            , test "serialize" (\_ -> tableId |> tableIdAsHtmlId |> Expect.equal "table-public-users")
            ]
        , describe "tableIdAsString"
            [ test "round-trip" (\_ -> tableId |> tableIdAsString |> stringAsTableId |> Expect.equal tableId)
            , test "serialize" (\_ -> tableId |> tableIdAsString |> Expect.equal "public.users")
            ]
        , describe "showTableName"
            [ test "with default schema" (\_ -> showTableName "public" "users" |> Expect.equal "users")
            , test "with other schema" (\_ -> showTableName "wp" "users" |> Expect.equal "wp.users")
            ]
        ]
