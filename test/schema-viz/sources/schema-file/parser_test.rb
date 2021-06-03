# frozen_string_literal: true

require './test/test_helper'

describe SchemaViz::Source::SchemaFile::Parser do
  parser = SchemaViz::Source::SchemaFile::Parser

  it 'parses a table' do
    sql = <<~SQL
      CREATE TABLE public.users (
        id bigint NOT NULL,
        name character varying(255),
        price numeric(8,2)
      ) WITH (autovacuum_enabled='false');
    SQL
    assert_equal parser::Table.new('public', 'users', [
      parser::Column.new('id', 'bigint', false, SchemaViz::Option.empty),
      parser::Column.new('name', 'character varying(255)', true, SchemaViz::Option.empty),
      parser::Column.new('price', 'numeric(8,2)', true, SchemaViz::Option.empty)
    ]), parser.parse_table(sql).get!
    assert_equal parser::ParseError, parser.parse_table('bad text').error!.class
  end

  it 'parses a column' do
    assert_equal parser::Column.new('id', 'bigint', false, SchemaViz::Option.empty),
                 parser.parse_column('id bigint NOT NULL').get!
    assert_equal parser::Column.new('name', 'character varying(255)', true, SchemaViz::Option.empty),
                 parser.parse_column('name character varying(255)').get!
    assert_equal parser::Column.new('status', 'character varying(255)', false, SchemaViz::Option.of("'done'::character varying")),
                 parser.parse_column("status character varying(255) DEFAULT 'done'::character varying NOT NULL").get!
    assert_equal parser::Column.new('price', 'numeric(8,2)', true, SchemaViz::Option.empty),
                 parser.parse_column('price numeric(8,2)').get!
    assert_equal parser::ParseError, parser.parse_column('bad-text').error!.class
  end

  it 'parses an alter table' do
    assert_equal parser::PrimaryKey.new('public', 't2', ['id'], 't2_id_pkey'),
                 parser.parse_alter_table('ALTER TABLE ONLY public.t2 ADD CONSTRAINT t2_id_pkey PRIMARY KEY (id);').get!
    assert_equal parser::ForeignKey.new('p', 't2', 't1_id', 'p', 't1', 'id', 't2_t1_id_fk'),
                 parser.parse_alter_table('ALTER TABLE ONLY p.t2 ADD CONSTRAINT t2_t1_id_fk FOREIGN KEY (t1_id) REFERENCES p.t1(id);').get!
    assert_equal parser::UniqueConstraint.new('p', 't1', %w[first_name last_name], 'name_unique'),
                 parser.parse_alter_table('ALTER TABLE ONLY p.t1 ADD CONSTRAINT name_unique UNIQUE (first_name, last_name);').get!
    assert_equal parser::CheckConstraint.new('p', 't1', '((kind IS NOT NULL)) NOT VALID', 't1_kind_not_null'),
                 parser.parse_alter_table('ALTER TABLE p.t1 ADD CONSTRAINT t1_kind_not_null CHECK ((kind IS NOT NULL)) NOT VALID;').get!
    assert_equal parser::SetColumnDefault.new('public', 'table1', 'id', '1'),
                 parser.parse_alter_table('ALTER TABLE ONLY public.table1 ALTER COLUMN id SET DEFAULT 1;').get!
    assert_equal parser::SetColumnStatistics.new('public', 'table1', 'table1_id', 5000),
                 parser.parse_alter_table('ALTER TABLE ONLY public.table1 ALTER COLUMN table1_id SET STATISTICS 5000;').get!

    assert_equal parser::ParseError, parser.parse_alter_table('bad text').error!.class

    message = "parse_alter_table can't parse \"ALTER TABLE ONLY p.t1 ALTER COLUMN id SET STATISTICS bad;\"\n" \
      "Caused by: ParseError: parse_alter_column can't parse \"ALTER COLUMN id SET STATISTICS bad\"\n" \
      "Caused by: ParseError: parse_alter_column_statistics can't parse \"STATISTICS bad\"\n" \
      "Caused by: RuntimeError: /STATISTICS (?<value>[0-9]+)/ didn't matched, can't get :value capture"
    assert_equal message, parser.parse_alter_table('ALTER TABLE ONLY p.t1 ALTER COLUMN id SET STATISTICS bad;').error!.message
  end

  it 'parses a table comment' do
    assert_equal parser::TableComment.new('public', 'table1', 'A comment'),
                 parser.parse_table_comment("COMMENT ON TABLE public.table1 IS 'A comment';").get!
    assert_equal parser::TableComment.new('public', 'table1', "A 'good' comment"),
                 parser.parse_table_comment("COMMENT ON TABLE public.table1 IS 'A ''good'' comment';").get!
    assert_equal parser::TableComment.new('public', 'table1', 'A ; comment'),
                 parser.parse_table_comment("COMMENT ON TABLE public.table1 IS 'A ; comment';").get!
    assert_equal parser::ParseError, parser.parse_table_comment('bad text').error!.class
  end

  it 'parses a column comment' do
    assert_equal parser::ColumnComment.new('public', 'table1', 'id', 'An id'),
                 parser.parse_column_comment("COMMENT ON COLUMN public.table1.id IS 'An id';").get!
    assert_equal parser::ColumnComment.new('public', 'table1', 'id', "A 'good' id"),
                 parser.parse_column_comment("COMMENT ON COLUMN public.table1.id IS 'A ''good'' id';").get!
    assert_equal parser::ColumnComment.new('public', 'table1', 'id', 'An ; id'),
                 parser.parse_column_comment("COMMENT ON COLUMN public.table1.id IS 'An ; id';").get!
    assert_equal parser::ParseError, parser.parse_column_comment('bad text').error!.class
  end
end
