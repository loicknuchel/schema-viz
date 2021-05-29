# frozen_string_literal: true

require './test/test_helper'
require './lib/schema-viz/models/sql/column'
require './lib/schema-viz/models/sql/table'
require './lib/schema-viz/parser/postgresql'

describe SchemaViz::Parser::Postgresql do
  postgres = SchemaViz::Parser::Postgresql
  table = SchemaViz::Table
  column = SchemaViz::Column

  it 'parse a sql file' do
    tables = postgres.parse_schema_file('./test/resources/structure.sql')
    assert_equal 2, tables.length
  end

  it 'parses a table' do
    sql = <<~SQL
      CREATE TABLE public.users (
        id bigint NOT NULL,
        name character varying(255),
        price numeric(8,2)
      ) WITH (autovacuum_enabled='false');
    SQL
    assert_equal table.new('public', 'users', [
      column.new('id', 'bigint', false, nil),
      column.new('name', 'character varying(255)', true, nil),
      column.new('price', 'numeric(8,2)', true, nil)
    ]), postgres.parse_table(sql)
  end

  it 'parses a column' do
    assert_equal column.new('id', 'bigint', false, nil),
                 postgres.parse_column('id bigint NOT NULL')
    assert_equal column.new('name', 'character varying(255)', true, nil),
                 postgres.parse_column('name character varying(255)')
    assert_equal column.new('status', 'character varying(255)', false, "'done'::character varying"),
                 postgres.parse_column("status character varying(255) DEFAULT 'done'::character varying NOT NULL")
    assert_equal column.new('price', 'numeric(8,2)', true, nil),
                 postgres.parse_column('price numeric(8,2)')
  end
end
