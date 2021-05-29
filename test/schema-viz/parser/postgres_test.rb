# frozen_string_literal: true

require './test/test_helper'
require './lib/schema-viz/models/sql/column'
require './lib/schema-viz/models/sql/table'
require './lib/schema-viz/parser/postgresql'

describe SchemaViz::Parser::Postgresql do
  postgres = SchemaViz::Parser::Postgresql
  table = SchemaViz::Table
  column = SchemaViz::Column

  describe 'parse_table' do
    it 'parses a simple table' do
      sql = <<~SQL
        CREATE TABLE public.users (
          id bigint NOT NULL,
          name character varying(255)
        );
      SQL
      assert_equal table.new('public', 'users', [
                               column.new('id', 'bigint', false, nil),
                               column.new('name', 'character varying(255)', true, nil)
                             ]), postgres.parse_table(sql)
    end
    it 'parses a column' do
      assert_equal column.new('id', 'bigint', false, nil),
                   postgres.parse_column('id bigint NOT NULL')
      assert_equal column.new('name', 'character varying(255)', true, nil),
                   postgres.parse_column('name character varying(255)')
      assert_equal column.new('status', 'character varying(255)', false, "'done'::character varying"),
                   postgres.parse_column("status character varying(255) DEFAULT 'done'::character varying NOT NULL")
      assert_equal column.new('json', 'jsonb', false, "'{}'::jsonb"),
                   postgres.parse_column("json jsonb DEFAULT '{}'::jsonb NOT NULL")
    end
  end
end
