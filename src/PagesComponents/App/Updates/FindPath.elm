module PagesComponents.App.Updates.FindPath exposing (computeFindPath)

import Dict exposing (Dict)
import Libs.Nel as Nel
import Models.FindPath as FindPath
import Models.Project exposing (Relation, Table, TableId)


computeFindPath : Dict TableId Table -> List Relation -> TableId -> TableId -> FindPath.Result
computeFindPath tables relations from to =
    { from = from, to = to, paths = buildPaths tables (filterRelations relations) from (\t -> t.id == to) [] }


ignoreColumns : List String
ignoreColumns =
    [ "created_by", "updated_by" ]


ignoreTables : List ( String, String )
ignoreTables =
    [ ( "public", "user_requests" ) ]


filterRelations : List Relation -> List Relation
filterRelations relations =
    -- ugly hack to keep computing low
    relations |> List.filter (\r -> not (List.member r.src.table ignoreTables || List.member r.ref.table ignoreTables || List.member r.src.column ignoreColumns || List.member r.ref.column ignoreColumns))


buildPaths : Dict TableId Table -> List Relation -> TableId -> (Table -> Bool) -> List FindPath.Step -> List FindPath.Path
buildPaths tables relations tableId isDone curPath =
    -- FIXME improve algo complexity
    tables
        |> Dict.get tableId
        |> Maybe.map
            (\table ->
                if isDone table then
                    curPath |> Nel.fromList |> Maybe.map (\p -> [ p ]) |> Maybe.withDefault []

                else
                    relations
                        |> List.partition (\r -> r.src.table == tableId || r.ref.table == tableId)
                        |> (\( tableRelations, otherRelations ) ->
                                if (tableRelations |> List.isEmpty) || ((curPath |> List.length) > 3) then
                                    []

                                else
                                    tableRelations
                                        |> List.concatMap
                                            (\r ->
                                                if r.src.table == tableId then
                                                    buildPaths (tables |> Dict.remove tableId) otherRelations r.ref.table isDone (curPath ++ [ { relation = r, direction = FindPath.Right } ])

                                                else
                                                    buildPaths (tables |> Dict.remove tableId) otherRelations r.src.table isDone (curPath ++ [ { relation = r, direction = FindPath.Left } ])
                                            )
                           )
            )
        |> Maybe.withDefault []
