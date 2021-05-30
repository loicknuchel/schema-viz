# frozen_string_literal: true

require './test/test_helper'
require './lib/schema-viz/models/sql/column'
require './lib/schema-viz/models/sql/table'
require './lib/schema-viz/parser/postgresql'

describe SchemaViz::Parser::Postgresql do
  postgres = SchemaViz::Parser::Postgresql

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
    assert_equal postgres::Table.new('public', 'users', [
      postgres::Column.new('id', 'bigint', false, nil),
      postgres::Column.new('name', 'character varying(255)', true, nil),
      postgres::Column.new('price', 'numeric(8,2)', true, nil)
    ]), postgres.parse_table(sql)
  end

  it 'parses a column' do
    assert_equal postgres::Column.new('id', 'bigint', false, nil),
                 postgres.parse_column('id bigint NOT NULL')
    assert_equal postgres::Column.new('name', 'character varying(255)', true, nil),
                 postgres.parse_column('name character varying(255)')
    assert_equal postgres::Column.new('status', 'character varying(255)', false, "'done'::character varying"),
                 postgres.parse_column("status character varying(255) DEFAULT 'done'::character varying NOT NULL")
    assert_equal postgres::Column.new('price', 'numeric(8,2)', true, nil),
                 postgres.parse_column('price numeric(8,2)')
  end

  it 'parses an alter table' do
    assert_equal postgres::PrimaryKey.new('public', 't2', ['id'], 't2_id_pkey'),
                 postgres.parse_alter_table('ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);')
    assert_equal postgres::ForeignKey.new('p', 't2', 't1_id', 'p', 't1', 'id', 't2_t1_id_fk'),
                 postgres.parse_alter_table('ALTER TABLE ONLY p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1(id);')
    assert_equal postgres::SetColumnDefault.new('public', 'table1', 'id', '1'),
                 postgres.parse_alter_table('ALTER TABLE ONLY public.table1 ALTER COLUMN id SET DEFAULT 1;')
    assert_equal postgres::SetColumnStatistics.new('public', 'table1', 'table1_id', 5000),
                 postgres.parse_alter_table('ALTER TABLE ONLY public.table1 ALTER COLUMN table1_id SET STATISTICS 5000;')
  end

  it 'parses a table comment' do
    assert_equal postgres::TableComment.new('public', 'table1', 'A comment'),
                 postgres.parse_table_comment("COMMENT ON TABLE public.table1 IS 'A comment';")
    assert_equal postgres::TableComment.new('public', 'table1', "A 'good' comment"),
                 postgres.parse_table_comment("COMMENT ON TABLE public.table1 IS 'A ''good'' comment';")
  end

  it 'parses a column comment' do
    assert_equal postgres::ColumnComment.new('public', 'table1', 'id', 'An id'),
                 postgres.parse_column_comment("COMMENT ON COLUMN public.table1.id IS 'An id';")
    assert_equal postgres::ColumnComment.new('public', 'table1', 'id', "A 'good' id"),
                 postgres.parse_column_comment("COMMENT ON COLUMN public.table1.id IS 'A ''good'' id';")
  end
end
