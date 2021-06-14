module Views.Relations exposing (viewRelation)

import Models exposing (Msg)
import Models.Schema exposing (Column, ColumnName(..), ForeignKey, ForeignKeyName(..), Table, TableId(..))
import Svg exposing (Svg, line, svg, text)
import Svg.Attributes exposing (class, height, style, width, x1, x2, y1, y2)



-- views showing table relations, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewRelation : ( ForeignKey, ( Table, Column ), ( Table, Column ) ) -> Svg Msg
viewRelation ( fk, ( srcTable, srcColumn ), ( refTable, refColumn ) ) =
    let
        x0 =
            min srcTable.ui.position.left refTable.ui.position.left

        y0 =
            min srcTable.ui.position.top refTable.ui.position.top
    in
    svg
        [ class "relation"
        , width (String.fromFloat (abs (srcTable.ui.position.left - refTable.ui.position.left)))
        , height (String.fromFloat (abs (srcTable.ui.position.top - refTable.ui.position.top)))
        , style ("position: absolute; left: " ++ String.fromFloat x0 ++ "px; top: " ++ String.fromFloat y0 ++ "px;")
        ]
        [ line
            [ x1 (String.fromFloat (srcTable.ui.position.left - x0))
            , y1 (String.fromFloat (srcTable.ui.position.top - y0))
            , x2 (String.fromFloat (refTable.ui.position.left - x0))
            , y2 (String.fromFloat (refTable.ui.position.top - y0))
            , style "stroke: #A0AEC0; stroke-width: 1.5"
            ]
            []
        , text (formatRef srcTable srcColumn ++ " -> " ++ formatForeignKeyName fk.name ++ " -> " ++ formatRef refTable refColumn)
        ]


formatTableId : TableId -> String
formatTableId (TableId id) =
    id


formatColumnName : ColumnName -> String
formatColumnName (ColumnName name) =
    name


formatForeignKeyName : ForeignKeyName -> String
formatForeignKeyName (ForeignKeyName name) =
    name


formatRef : Table -> Column -> String
formatRef table column =
    formatTableId table.id ++ "." ++ formatColumnName column.column
