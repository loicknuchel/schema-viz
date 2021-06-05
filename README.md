# SchemaViz

**⚠️⚠️⚠️ Under construction ⚠️⚠️⚠️**

An Entity Relationship diagram (ERD) visualization tool, with various filters and inputs to help understand your SQL
schema.

Why building my own ?

Most ERD tool I looked into ([DrawSQL](https://drawsql.app), [dbdiagram.io](https://dbdiagram.io)
, [Lucidchart](https://www.lucidchart.com/pages/examples/er-diagram-tool), [ERDPlus](https://erdplus.com)
, [Creately](https://creately.com/lp/er-diagram-tool-online), [SqlDBM](https://sqldbm.com)) are focusing on
creating/editing the schema (collaboratively) and displaying it (statically). This is nice when starting a new project
with a few tables but doesn't really help when you discover an existing one with hundreds of tables and relations.

I really miss an interactive exploration tool with features like:

- filter/show/hide some tables
- filter/show/hide some columns
- search for tables, columns or even in metadata
- tag tables and columns to define meaningful groups (team ownership, domain exploration...)
- rich UI infos with:
    - source links (schema file but also app models)
    - database statistics (table size, column value samples)
    - team/code ownership (git blame or specific format)

For me, this tool is the missing piece between a classic ERD tool and a Data catalog.

## Installation

This tool is under construction and may drastically change in the process (no final packaging has been decided for now).

Currently, it has two parts:

- a parser, built in Ruby to parse a schema file and write it to JSON
- a front app, built in Elm to visualize the schema

### Ruby parser

First, you need to install Ruby & Bundler in your machine, then run `bundle install` to get the dependencies.

- launch the program: `exe/schema-viz generate --structure ./test/resources/structure.sql`
- launch the tests: `rake test`
- launch a Ruby console: `bin/console`

Ruby folders are `lib/schema-viz` for sources & `test` for tests.

### Elm viz

First, you need to install Elm & NPM on your machine, then run `npm install` to get the dependencies.

- launch dev env: `elm reactor`
- launch the tests: `npx elm-test`
- compile to an HTML file: `elm make src/Main.elm`

Elm folders are `src` for sources & `tests` for tests.

(I know, this is not very good, this will improve with the maturity of the tool ^^)

## License

The tool is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
