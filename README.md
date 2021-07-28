# SchemaViz

**⚠️⚠️⚠️ Under construction ⚠️⚠️⚠️**

An Entity Relationship diagram (ERD) visualization tool, with various filters and inputs to help understand your SQL
schema.

Why building my own ?

Most ERD tool I looked into ([DrawSQL](https://drawsql.app), [dbdiagram.io](https://dbdiagram.io)
, [Lucidchart](https://www.lucidchart.com/pages/examples/er-diagram-tool), [ERDPlus](https://erdplus.com)
, [Creately](https://creately.com/lp/er-diagram-tool-online), [SqlDBM](https://sqldbm.com)
, [QuickDBD](https://www.quickdatabasediagrams.com)) are focusing on creating/editing the schema (collaboratively) and
displaying it (statically). This is nice when starting a new project with a few tables but doesn't really help when you
discover an existing one with hundreds of tables and relations.

I really miss an interactive exploration tool with features like:

- filter/show/hide some tables
- filter/show/hide some columns
- search for tables, columns or even in metadata
- tag tables and columns to define meaningful groups (team ownership, domain exploration...)
- rich UI infos with:
    - source links (schema file but also app models)
    - database statistics (table size, column value samples)
    - team/code ownership (git blame or specific format)
    - tables/columns updates (from migrations files or schema file history)

For me, this tool is the missing piece between a classic ERD tool and a Data catalog.

## Installation

Schema Viz is a Single Page Application built with Elm that parse and explore your SQL schema.

First, you need to install npm, Elm & [elm-spa](https://www.elm-spa.dev) on your machine and run `npm install` to get the dependencies.

- launch dev server: `elm-spa server`
- launch the tests: `elm-test` (needs `npm install -g elm-test`)
- run linter: `elm-review` (needs `npm install -g elm-review`)
- run coverage: `elm-coverage --open` (needs `npm install -g elm-coverage`) > doesn't work with elm-spa :(
- update the demo: `./build-demo.sh`
- install deps `elm-json install author/package` (needs `npm install --g elm-json`)
- uninstall deps `elm-json uninstall author/package`
- update deps `elm-json upgrade` (use `--unsafe` flag for major versions)

Elm folders are `src` for sources, `tests` for tests and `public` for static assets.

### (legacy) Ruby parser

This tool started as a Ruby parser for the SQL schema, you can still find it under `legacy/ruby` folder.

To run it you need to install Ruby & Bundler in your machine, then run `bundle install` to get the dependencies.

- launch the
  program: `exe/schema-viz generate --structure ./test/resources/schema.sql --output ../../tests/resources/schema.json`
- launch the tests: `rake test` (& open coverage `xdg-open coverage/index.html`)
- launch a Ruby console: `bin/console`

Ruby folders are `lib/schema-viz` for sources & `test` for tests.

## License

The tool is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
