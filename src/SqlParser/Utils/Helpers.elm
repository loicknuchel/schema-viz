module SqlParser.Utils.Helpers exposing (commaSplit, noEnclosingQuotes, parseIndexDefinition, regexMatches)

import Regex
import SqlParser.Utils.Types exposing (ParseError, SqlColumnName)


parseIndexDefinition : String -> Result (List ParseError) (List SqlColumnName)
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


noEnclosingQuotes : String -> String
noEnclosingQuotes text =
    case regexMatches "\"(.*)\"" text of
        (Just res) :: [] ->
            res

        _ ->
            text


regexMatches : String -> String -> List (Maybe String)
regexMatches regex text =
    Regex.fromStringWith { caseInsensitive = True, multiline = False } regex
        |> Maybe.withDefault Regex.never
        |> (\r -> Regex.find r text)
        |> List.concatMap .submatches


commaSplit : String -> List String
commaSplit text =
    String.foldr
        (\char ( res, cur, open ) ->
            if char == ',' && open == 0 then
                ( (cur |> String.fromList) :: res, [], open )

            else if char == '(' then
                ( res, char :: cur, open + 1 )

            else if char == ')' then
                ( res, char :: cur, open - 1 )

            else
                ( res, char :: cur, open )
        )
        ( [], [], 0 )
        text
        |> (\( res, end, _ ) -> (end |> String.fromList) :: res)
