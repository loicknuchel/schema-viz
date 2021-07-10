module Views.Relations exposing (viewRelation)

import Libs.List as L
import Models exposing (Msg)
import Models.Schema exposing (Column, ForeignKeyName(..), Relation, Table, TableAndColumn, TableStatus(..), formatTableId)
import Models.Utils exposing (Color)
import Svg exposing (Svg, line, svg, text)
import Svg.Attributes exposing (class, height, strokeDasharray, style, width, x1, x2, y1, y2)
import Views.Helpers exposing (withColumnName)



-- views showing table relations, can include Views.Helpers, Models or Libs modules. Nothing else from views.


viewRelation : Relation -> Svg Msg
viewRelation { key, src, ref } =
    case ( ( src.table.state.status == Shown, ref.table.state.status == Shown ), ( formatText key src ref, getColor src ref ) ) of
        ( ( False, False ), ( name, _ ) ) ->
            svg [ class "erd-relation" ] [ text name ]

        ( ( True, False ), ( name, color ) ) ->
            case { x = src.table.state.position.left + src.table.state.size.width, y = positionY src } of
                srcPos ->
                    drawRelation srcPos { x = srcPos.x + 20, y = srcPos.y } src.column.nullable color name

        ( ( False, True ), ( name, color ) ) ->
            case { x = ref.table.state.position.left, y = positionY ref } of
                refPos ->
                    drawRelation { x = refPos.x - 20, y = refPos.y } refPos src.column.nullable color name

        ( ( True, True ), ( name, color ) ) ->
            case ( positionX src.table ref.table, ( positionY src, positionY ref ) ) of
                ( ( srcX, refX ), ( srcY, refY ) ) ->
                    drawRelation { x = srcX, y = srcY } { x = refX, y = refY } src.column.nullable color name


drawRelation : Point -> Point -> Bool -> Maybe Color -> String -> Svg Msg
drawRelation src ref optional color name =
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
        [ viewLine (minus src origin) (minus ref origin) optional color
        , text name
        ]


viewLine : Point -> Point -> Bool -> Maybe Color -> Svg Msg
viewLine p1 p2 optional color =
    line
        (L.addIf optional
            (strokeDasharray "4")
            [ x1 (String.fromFloat p1.x)
            , y1 (String.fromFloat p1.y)
            , x2 (String.fromFloat p2.x)
            , y2 (String.fromFloat p2.y)
            , style
                (color
                    |> Maybe.map (\c -> "stroke: var(--tw-" ++ c ++ "); stroke-width: 3;")
                    |> Maybe.withDefault "stroke: #A0AEC0; stroke-width: 2;"
                )
            ]
        )
        []



-- helpers


type alias Point =
    { x : Float, y : Float }


getColor : TableAndColumn -> TableAndColumn -> Maybe Color
getColor src ref =
    if src.table.state.status == Shown && src.table.state.selected then
        Just src.table.state.color

    else if ref.table.state.status == Shown && ref.table.state.selected then
        Just ref.table.state.color

    else
        Nothing


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
    31


positionY : TableAndColumn -> Float
positionY { table, column } =
    table.state.position.top + headerHeight + (columnHeight * (0.5 + (column.state.order |> Maybe.withDefault -1 |> toFloat)))


minus : Point -> Point -> Point
minus p1 p2 =
    { x = p1.x - p2.x, y = p1.y - p2.y }



-- formatters


formatText : ForeignKeyName -> TableAndColumn -> TableAndColumn -> String
formatText fk src ref =
    formatRef src.table src.column ++ " -> " ++ formatForeignKeyName fk ++ " -> " ++ formatRef ref.table ref.column


formatRef : Table -> Column -> String
formatRef table column =
    formatTableId table.id |> withColumnName column.column


formatForeignKeyName : ForeignKeyName -> String
formatForeignKeyName (ForeignKeyName name) =
    name
