module Views.Relations exposing (viewRelation)

import Models exposing (Msg)
import Models.Schema exposing (Column, ColumnIndex(..), ColumnName(..), ForeignKey, ForeignKeyName(..), Table, TableId(..))
import Svg exposing (Svg, line, svg, text)
import Svg.Attributes exposing (class, height, style, width, x1, x2, y1, y2)



-- views showing table relations, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewRelation : ( ForeignKey, ( Table, Column ), ( Table, Column ) ) -> Svg Msg
viewRelation ( fk, ( srcTable, srcColumn ), ( refTable, refColumn ) ) =
    case ( srcTable.state.show, refTable.state.show, formatText fk srcTable srcColumn refTable refColumn ) of
        ( False, False, name ) ->
            svg [ class "relation" ] [ text name ]

        ( True, False, name ) ->
            case { x = srcTable.state.position.left + srcTable.state.size.width, y = positionY srcTable srcColumn } of
                src ->
                    drawRelation src { x = src.x + 20, y = src.y } name

        ( False, True, name ) ->
            case { x = refTable.state.position.left, y = positionY refTable refColumn } of
                ref ->
                    drawRelation { x = ref.x - 20, y = ref.y } ref name

        ( True, True, name ) ->
            case ( positionX srcTable refTable, ( positionY srcTable srcColumn, positionY refTable refColumn ) ) of
                ( ( srcX, refX ), ( srcY, refY ) ) ->
                    drawRelation { x = srcX, y = srcY } { x = refX, y = refY } name


drawRelation : Point -> Point -> String -> Svg Msg
drawRelation src ref name =
    let
        padding : Float
        padding =
            10

        origin : Point
        origin =
            { x = min src.x ref.x - padding, y = min src.y ref.y - padding }
    in
    svg
        [ class "relation"
        , width (String.fromFloat (abs (src.x - ref.x) + (padding * 2)))
        , height (String.fromFloat (abs (src.y - ref.y) + (padding * 2)))
        , style ("position: absolute; left: " ++ String.fromFloat origin.x ++ "px; top: " ++ String.fromFloat origin.y ++ "px;")
        ]
        [ viewLine (minus src origin) (minus ref origin)
        , text name
        ]


viewLine : Point -> Point -> Svg Msg
viewLine p1 p2 =
    line
        [ x1 (String.fromFloat p1.x)
        , y1 (String.fromFloat p1.y)
        , x2 (String.fromFloat p2.x)
        , y2 (String.fromFloat p2.y)
        , style "stroke: #A0AEC0; stroke-width: 1.5"
        ]
        []



-- helpers


type alias Point =
    { x : Float, y : Float }


positionX : Table -> Table -> ( Float, Float )
positionX srcTable refTable =
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
    ( table.state.position.left, table.state.position.left + (table.state.size.width / 2), table.state.position.left + table.state.size.width )


headerHeight : Float
headerHeight =
    48


columnHeight : Float
columnHeight =
    31.19


positionY : Table -> Column -> Float
positionY table column =
    case column.index of
        ColumnIndex index ->
            table.state.position.top + headerHeight + (columnHeight * (0.5 + toFloat index))


minus : Point -> Point -> Point
minus p1 p2 =
    { x = p1.x - p2.x, y = p1.y - p2.y }



-- formatters


formatText : ForeignKey -> Table -> Column -> Table -> Column -> String
formatText fk srcTable srcColumn refTable refColumn =
    formatRef srcTable srcColumn ++ " -> " ++ formatForeignKeyName fk.name ++ " -> " ++ formatRef refTable refColumn


formatRef : Table -> Column -> String
formatRef table column =
    formatTableId table.id ++ "." ++ formatColumnName column.column


formatTableId : TableId -> String
formatTableId (TableId id) =
    id


formatColumnName : ColumnName -> String
formatColumnName (ColumnName name) =
    name


formatForeignKeyName : ForeignKeyName -> String
formatForeignKeyName (ForeignKeyName name) =
    name
