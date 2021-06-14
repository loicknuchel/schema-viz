module Views.Relations exposing (viewRelation)

import Models exposing (Msg)
import Models.Schema exposing (Column, ColumnIndex(..), ColumnName(..), ForeignKey, ForeignKeyName(..), Table, TableId(..))
import Svg exposing (Svg, line, svg, text)
import Svg.Attributes as Attributes exposing (class, height, style, width)



-- views showing table relations, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewRelation : ( ForeignKey, ( Table, Column ), ( Table, Column ) ) -> Svg Msg
viewRelation ( fk, ( srcTable, srcColumn ), ( refTable, refColumn ) ) =
    let
        ( srcY, refY ) =
            ( columnY srcTable srcColumn, columnY refTable refColumn )

        ( srcX, refX ) =
            columnX srcTable refTable

        ( x0, y0 ) =
            ( min srcX refX, min srcY refY )
    in
    svg
        [ class "relation"
        , width (String.fromFloat (abs (srcX - refX)))
        , height (String.fromFloat (abs (srcY - refY)))
        , style ("position: absolute; left: " ++ String.fromFloat x0 ++ "px; top: " ++ String.fromFloat y0 ++ "px;")
        ]
        [ viewLine (srcX - x0) (srcY - y0) (refX - x0) (refY - y0)
        , text (formatRef srcTable srcColumn ++ " -> " ++ formatForeignKeyName fk.name ++ " -> " ++ formatRef refTable refColumn)
        ]


viewLine : Float -> Float -> Float -> Float -> Svg Msg
viewLine x1 y1 x2 y2 =
    line
        [ Attributes.x1 (String.fromFloat x1)
        , Attributes.y1 (String.fromFloat y1)
        , Attributes.x2 (String.fromFloat x2)
        , Attributes.y2 (String.fromFloat y2)
        , style "stroke: #A0AEC0; stroke-width: 1.5"
        ]
        []



-- helpers


headerHeight : Float
headerHeight =
    48


columnHeight : Float
columnHeight =
    31.19


columnY : Table -> Column -> Float
columnY table column =
    case column.index of
        ColumnIndex index ->
            table.ui.position.top + headerHeight + (columnHeight * (0.5 + toFloat index))


columnX : Table -> Table -> ( Float, Float )
columnX srcTable refTable =
    case ( tablePositions srcTable, tablePositions refTable ) of
        ( ( srcLeft, srcCenter, srcRight ), ( refLeft, refCenter, refRight ) ) ->
            if srcRight < refLeft then
                ( srcRight, refLeft )

            else if srcCenter < refCenter then
                ( srcRight, refRight )

            else if srcLeft < refRight then
                ( srcLeft, refLeft )

            else
                ( srcLeft, refRight )


tablePositions : Table -> ( Float, Float, Float )
tablePositions table =
    ( table.ui.position.left, table.ui.position.left + (table.ui.size.width / 2), table.ui.position.left + table.ui.size.width )



-- formatters


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
