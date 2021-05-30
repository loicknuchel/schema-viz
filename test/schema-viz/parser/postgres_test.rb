# frozen_string_literal: true

require './test/test_helper'
require './lib/schema-viz/models/sql/column'
require './lib/schema-viz/models/sql/table'
require './lib/schema-viz/parser/postgresql'

describe SchemaViz::Parser::Postgresql do
  postgres = SchemaViz::Parser::Postgresql

  it 'parse a sql file' do
    structure = postgres.parse_schema_file('./test/resources/structure.sql')
    assert_equal 2, structure.tables.length
    # primary key is added
    assert_nil structure.table('public', 'table1').primary_key
    assert_equal ['id'], structure.table('public', 'table2').primary_key
    # foreign keys are added
    assert_nil structure.column('public', 'table2', 'id').reference
    assert_equal postgres::Reference.new('public', 'table1', 'id', 'table2_table1_id_fk'), structure.column('public', 'table2', 'table1_id').reference
    # comments are added
    assert_nil structure.table('public', 'table2').comment
    assert_nil structure.column('public', 'table1', 'id').comment
    assert_equal 'This is the first table', structure.table('public', 'table1').comment
    assert_equal 'An external \'id\' or "value"', structure.column('public', 'table1', 'user_id').comment
  end

  describe 'SqlParser' do
    parser = SchemaViz::Parser::Postgresql::SqlParser

    it 'parses a table' do
      sql = <<~SQL
        CREATE TABLE public.users (
          id bigint NOT NULL,
          name character varying(255),
          price numeric(8,2)
        ) WITH (autovacuum_enabled='false');
      SQL
      assert_equal parser::Table.new('public', 'users', [
        parser::Column.new('id', 'bigint', false, nil),
        parser::Column.new('name', 'character varying(255)', true, nil),
        parser::Column.new('price', 'numeric(8,2)', true, nil)
      ]), parser.parse_table(sql)
    end

    it 'parses a column' do
      assert_equal parser::Column.new('id', 'bigint', false, nil),
                   parser.parse_column('id bigint NOT NULL')
      assert_equal parser::Column.new('name', 'character varying(255)', true, nil),
                   parser.parse_column('name character varying(255)')
      assert_equal parser::Column.new('status', 'character varying(255)', false, "'done'::character varying"),
                   parser.parse_column("status character varying(255) DEFAULT 'done'::character varying NOT NULL")
      assert_equal parser::Column.new('price', 'numeric(8,2)', true, nil),
                   parser.parse_column('price numeric(8,2)')
    end

    it 'parses an alter table' do
      assert_equal parser::PrimaryKey.new('public', 't2', ['id'], 't2_id_pkey'),
                   parser.parse_alter_table('ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);')
      assert_equal parser::ForeignKey.new('p', 't2', 't1_id', 'p', 't1', 'id', 't2_t1_id_fk'),
                   parser.parse_alter_table('ALTER TABLE ONLY p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1(id);')
      assert_equal parser::SetColumnDefault.new('public', 'table1', 'id', '1'),
                   parser.parse_alter_table('ALTER TABLE ONLY public.table1 ALTER COLUMN id SET DEFAULT 1;')
      assert_equal parser::SetColumnStatistics.new('public', 'table1', 'table1_id', 5000),
                   parser.parse_alter_table('ALTER TABLE ONLY public.table1 ALTER COLUMN table1_id SET STATISTICS 5000;')
    end

    it 'parses a table comment' do
      assert_equal parser::TableComment.new('public', 'table1', 'A comment'),
                   parser.parse_table_comment("COMMENT ON TABLE public.table1 IS 'A comment';")
      assert_equal parser::TableComment.new('public', 'table1', "A 'good' comment"),
                   parser.parse_table_comment("COMMENT ON TABLE public.table1 IS 'A ''good'' comment';")
    end

    it 'parses a column comment' do
      assert_equal parser::ColumnComment.new('public', 'table1', 'id', 'An id'),
                   parser.parse_column_comment("COMMENT ON COLUMN public.table1.id IS 'An id';")
      assert_equal parser::ColumnComment.new('public', 'table1', 'id', "A 'good' id"),
                   parser.parse_column_comment("COMMENT ON COLUMN public.table1.id IS 'A ''good'' id';")
    end
  end
end
