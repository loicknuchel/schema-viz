module Views.Relations exposing (getRelations, viewRelation)

import AssocList as Dict exposing (Dict)
import Html exposing (Html, div, text)
import Libs.SchemaDecoders exposing (Column, ColumnName(..), ForeignKey, ForeignKeyName(..), SchemaName, TableId(..), TableName, buildTableId)
import Libs.Std exposing (listCollect)
import Models exposing (Msg, UiTable)



-- views showing table relations, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewRelation : ( ( UiTable, Column ), ( UiTable, Column ), ForeignKey ) -> Html Msg
viewRelation ( ( srcTable, srcColumn ), ( refTable, refColumn ), fk ) =
    case ( ( srcTable.id, srcColumn.column ), fk.name, ( refTable.id, refColumn.column ) ) of
        ( ( TableId srcId, ColumnName srcCol ), ForeignKeyName name, ( TableId refId, ColumnName refCol ) ) ->
            div [] [ text (srcId ++ "." ++ srcCol ++ " -> " ++ name ++ " -> " ++ refId ++ "." ++ refCol) ]



-- data accessors


getRelations : Dict TableId UiTable -> List ( ( UiTable, Column ), ( UiTable, Column ), ForeignKey )
getRelations tables =
    List.foldr (\table res -> includeRefTable tables (getColumnsWithForeignKey table) ++ res) [] (Dict.values tables)


includeRefTable : Dict TableId UiTable -> List ( ( UiTable, Column ), ForeignKey ) -> List ( ( UiTable, Column ), ( UiTable, Column ), ForeignKey )
includeRefTable tables relations =
    listCollect (\( src, fk ) -> Maybe.map (\ref -> ( src, ref, fk )) (getTableAndColumn ( fk.schema, fk.table, fk.column ) tables)) relations


getTableAndColumn : ( SchemaName, TableName, ColumnName ) -> Dict TableId UiTable -> Maybe ( UiTable, Column )
getTableAndColumn ( schemaName, tableName, columnName ) tables =
    Maybe.andThen (\table -> Maybe.map (\column -> ( table, column )) (getTableColumn columnName table)) (getTable ( schemaName, tableName ) tables)


getTableColumn : ColumnName -> UiTable -> Maybe Column
getTableColumn columnName table =
    Dict.get columnName table.sql.columns


getTable : ( SchemaName, TableName ) -> Dict TableId UiTable -> Maybe UiTable
getTable ( schema, table ) tables =
    Dict.get (buildTableId schema table) tables


getColumnsWithForeignKey : UiTable -> List ( ( UiTable, Column ), ForeignKey )
getColumnsWithForeignKey table =
    listCollect (\column -> Maybe.map (\ref -> ( ( table, column ), ref )) column.reference) (Dict.values table.sql.columns)
