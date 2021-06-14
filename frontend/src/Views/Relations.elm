module Views.Relations exposing (viewRelation)

import Html exposing (Html, div, text)
import Models exposing (Msg)
import Models.Schema exposing (Column, ColumnName(..), ForeignKey, ForeignKeyName(..), Table, TableId(..))



-- views showing table relations, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewRelation : ( ForeignKey, ( Table, Column ), ( Table, Column ) ) -> Html Msg
viewRelation ( fk, ( srcTable, srcColumn ), ( refTable, refColumn ) ) =
    case ( ( srcTable.id, srcColumn.column ), fk.name, ( refTable.id, refColumn.column ) ) of
        ( ( TableId srcId, ColumnName srcCol ), ForeignKeyName name, ( TableId refId, ColumnName refCol ) ) ->
            div [] [ text (srcId ++ "." ++ srcCol ++ " -> " ++ name ++ " -> " ++ refId ++ "." ++ refCol) ]
