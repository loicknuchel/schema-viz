# frozen_string_literal: true

require './lib/schema-viz/sources/structure-file/parser'
require './test/test_helper'

describe SchemaViz::Source::StructureFile::Parser do
  parser = SchemaViz::Source::StructureFile::Parser

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
    ]), parser.parse_table_r(sql).get!
    assert_equal parser::ParseError, parser.parse_table_r('bad text').error!.class
  end

  it 'parses a column' do
    assert_equal parser::Column.new('id', 'bigint', false, nil),
                 parser.parse_column_r('id bigint NOT NULL').get!
    assert_equal parser::Column.new('name', 'character varying(255)', true, nil),
                 parser.parse_column_r('name character varying(255)').get!
    assert_equal parser::Column.new('status', 'character varying(255)', false, "'done'::character varying"),
                 parser.parse_column_r("status character varying(255) DEFAULT 'done'::character varying NOT NULL").get!
    assert_equal parser::Column.new('price', 'numeric(8,2)', true, nil),
                 parser.parse_column_r('price numeric(8,2)').get!
    assert_equal parser::ParseError, parser.parse_column_r('bad-text').error!.class
  end

  it 'parses an alter table' do
    assert_equal parser::PrimaryKey.new('public', 't2', ['id'], 't2_id_pkey'),
                 parser.parse_alter_table_r('ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);').get!
    assert_equal parser::ForeignKey.new('p', 't2', 't1_id', 'p', 't1', 'id', 't2_t1_id_fk'),
                 parser.parse_alter_table_r('ALTER TABLE ONLY p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1(id);').get!
    assert_equal parser::UniqueConstraint.new('p', 't1', %w[first_name last_name], 'name_unique'),
                 parser.parse_alter_table_r('ALTER TABLE ONLY p.t1 ADD CONSTRAINT name_unique UNIQUE (first_name, last_name);').get!
    assert_equal parser::CheckConstraint.new('p', 't1', '((kind IS NOT NULL)) NOT VALID', 't1_kind_not_null'),
                 parser.parse_alter_table_r('ALTER TABLE p.t1 ADD CONSTRAINT t1_kind_not_null CHECK ((kind IS NOT NULL)) NOT VALID;').get!
    assert_equal parser::SetColumnDefault.new('public', 'table1', 'id', '1'),
                 parser.parse_alter_table_r('ALTER TABLE ONLY public.table1 ALTER COLUMN id SET DEFAULT 1;').get!
    assert_equal parser::SetColumnStatistics.new('public', 'table1', 'table1_id', 5000),
                 parser.parse_alter_table_r('ALTER TABLE ONLY public.table1 ALTER COLUMN table1_id SET STATISTICS 5000;').get!

    assert_equal parser::ParseError, parser.parse_alter_table_r('bad text').error!.class

    message = "parse_alter_table_r can't parse \"ALTER TABLE ONLY p.t1 ALTER COLUMN id SET STATISTICS bad;\" (regex result: #<MatchData \"ALTER TABLE ONLY p.t1 ALTER COLUMN id SET STATISTICS bad;\" schema:\"p\" table:\"t1\" command:\"ALTER COLUMN id SET STATISTICS bad\">)\n" \
      "Caused by: SchemaViz::Source::StructureFile::Parser::ParseError: parse_alter_column_r can't parse \"ALTER COLUMN id SET STATISTICS bad\" (regex result: #<MatchData \"ALTER COLUMN id SET STATISTICS bad\" column:\"id\" property:\"STATISTICS bad\">)\n" \
      "Caused by: SchemaViz::Source::StructureFile::Parser::ParseError: parse_alter_column_statistics_r can't parse \"STATISTICS bad\"\n" \
      "Caused by: NoMethodError: undefined method `[]' for nil:NilClass"
    assert_equal message, parser.parse_alter_table_r('ALTER TABLE ONLY p.t1 ALTER COLUMN id SET STATISTICS bad;').error!.message
  end

  it 'parses a table comment' do
    assert_equal parser::TableComment.new('public', 'table1', 'A comment'),
                 parser.parse_table_comment_r("COMMENT ON TABLE public.table1 IS 'A comment';").get!
    assert_equal parser::TableComment.new('public', 'table1', "A 'good' comment"),
                 parser.parse_table_comment_r("COMMENT ON TABLE public.table1 IS 'A ''good'' comment';").get!
    assert_equal parser::TableComment.new('public', 'table1', 'A ; comment'),
                 parser.parse_table_comment_r("COMMENT ON TABLE public.table1 IS 'A ; comment';").get!
    assert_equal parser::ParseError, parser.parse_table_comment_r('bad text').error!.class
  end

  it 'parses a column comment' do
    assert_equal parser::ColumnComment.new('public', 'table1', 'id', 'An id'),
                 parser.parse_column_comment_r("COMMENT ON COLUMN public.table1.id IS 'An id';").get!
    assert_equal parser::ColumnComment.new('public', 'table1', 'id', "A 'good' id"),
                 parser.parse_column_comment_r("COMMENT ON COLUMN public.table1.id IS 'A ''good'' id';").get!
    assert_equal parser::ColumnComment.new('public', 'table1', 'id', 'An ; id'),
                 parser.parse_column_comment_r("COMMENT ON COLUMN public.table1.id IS 'An ; id';").get!
    assert_equal parser::ParseError, parser.parse_column_comment_r('bad text').error!.class
  end
end
