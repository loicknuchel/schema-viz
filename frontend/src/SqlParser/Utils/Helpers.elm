module SqlParser.Utils.Helpers exposing (parseIndexDefinition, regexMatches)

import Regex
import SqlParser.Utils.Types exposing (ColumnName, ParseError)


parseIndexDefinition : String -> Result (List ParseError) (List ColumnName)
parseIndexDefinition definition =
    case definition |> regexMatches "^\\((?<columns>[^)]+)\\)$" of
        (Just columns) :: [] ->
            Ok (columns |> String.split "," |> List.map String.trim)

        _ ->
            case definition |> regexMatches "^USING[ \t]+[^ ]+[ \t]+\\((?<columns>[^)]+)\\).*$" of
                (Just columns) :: [] ->
                    Ok (columns |> String.split "," |> List.map String.trim)

                _ ->
                    Err [ "Can't parse definition: '" ++ definition ++ "' in create index" ]


regexMatches : String -> String -> List (Maybe String)
regexMatches regex text =
    Regex.fromStringWith { caseInsensitive = True, multiline = False } regex
        |> Maybe.withDefault Regex.never
        |> (\r -> Regex.find r text)
        |> List.concatMap .submatches
