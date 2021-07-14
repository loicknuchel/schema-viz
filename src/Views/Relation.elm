module Views.Relation exposing (viewRelation)

import Libs.List as L
import Libs.Maybe as M
import Models exposing (Msg)
import Models.Schema exposing (Column, ForeignKeyName(..), Relation, RelationTarget, Table, TableProps, showTableId)
import Models.Utils exposing (Color, Size)
import Svg exposing (Svg, line, svg, text)
import Svg.Attributes exposing (class, height, strokeDasharray, style, width, x1, x2, y1, y2)
import Views.Helpers exposing (withColumnName)



-- deps = { to = { only = [ "Libs.*", "Models.*", "Conf", "Views.Helpers" ] } }


viewRelation : Relation -> Svg Msg
viewRelation { key, src, ref } =
    case ( ( src.props, ref.props ), ( formatText key src ref, getColor src ref ) ) of
        ( ( Nothing, Nothing ), ( name, _ ) ) ->
            svg [ class "erd-relation" ] [ text name ]

        ( ( Just ( sProps, sSize ), Nothing ), ( name, color ) ) ->
            case { x = sProps.position.left + sSize.width, y = positionY sProps src.column } of
                srcPos ->
                    drawRelation srcPos { x = srcPos.x + 20, y = srcPos.y } src.column.nullable color name

        ( ( Nothing, Just ( rProps, _ ) ), ( name, color ) ) ->
            case { x = rProps.position.left, y = positionY rProps ref.column } of
                refPos ->
                    drawRelation { x = refPos.x - 20, y = refPos.y } refPos src.column.nullable color name

        ( ( Just ( sProps, sSize ), Just ( rProps, rSize ) ), ( name, color ) ) ->
            case ( positionX ( sProps, sSize ) ( rProps, rSize ), ( positionY sProps src.column, positionY rProps ref.column ) ) of
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


getColor : RelationTarget -> RelationTarget -> Maybe Color
getColor src ref =
    (src.props |> Maybe.map Tuple.first |> M.filter .selected |> Maybe.map .color)
        |> M.orElse (ref.props |> Maybe.map Tuple.first |> M.filter .selected |> Maybe.map .color)


positionX : ( TableProps, Size ) -> ( TableProps, Size ) -> ( Float, Float )
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


tablePositions : ( TableProps, Size ) -> ( Float, Float, Float )
tablePositions ( props, size ) =
    ( props.position.left, props.position.left + (size.width / 2), props.position.left + size.width )


headerHeight : Float
headerHeight =
    48


columnHeight : Float
columnHeight =
    31


positionY : TableProps -> Column -> Float
positionY props column =
    props.position.top + headerHeight + (columnHeight * (0.5 + (props.columns |> L.indexOf column.column |> Maybe.withDefault -1 |> toFloat)))


minus : Point -> Point -> Point
minus p1 p2 =
    { x = p1.x - p2.x, y = p1.y - p2.y }



-- formatters


formatText : ForeignKeyName -> RelationTarget -> RelationTarget -> String
formatText fk src ref =
    formatRef src.table src.column ++ " -> " ++ formatForeignKeyName fk ++ " -> " ++ formatRef ref.table ref.column


formatRef : Table -> Column -> String
formatRef table column =
    showTableId table.id |> withColumnName column.column


formatForeignKeyName : ForeignKeyName -> String
formatForeignKeyName (ForeignKeyName name) =
    name
