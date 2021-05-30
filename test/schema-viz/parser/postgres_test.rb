# frozen_string_literal: true

require './test/test_helper'
require './lib/schema-viz/models/sql/column'
require './lib/schema-viz/models/sql/table'
require './lib/schema-viz/parser/postgresql'

describe SchemaViz::Parser::Postgresql do
  postgres = SchemaViz::Parser::Postgresql

  it 'parse a sql file' do
    structure = postgres.parse_schema_file_r('./test/resources/structure.sql').get!
    assert_equal 2, structure.tables.length
    # primary key is added
    assert_nil structure.table('public', 'table1').primary_key
    assert_equal ['id'], structure.table('public', 'table2').primary_key
    # foreign keys are added
    assert_nil structure.column('public', 'table2', 'id').reference
    assert_equal postgres::Reference.new('public', 'table1', 'id', 'table2_table1_id_fk'), structure.column('public', 'table2', 'table1_id').reference
    # column default
    assert_equal "nextval('public.table2_id_seq'::regclass)", structure.column('public', 'table2', 'id').default
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
        "Caused by: SchemaViz::Parser::Postgresql::SqlParser::ParseError: parse_alter_column_r can't parse \"ALTER COLUMN id SET STATISTICS bad\" (regex result: #<MatchData \"ALTER COLUMN id SET STATISTICS bad\" column:\"id\" property:\"STATISTICS bad\">)\n" \
        "Caused by: SchemaViz::Parser::Postgresql::SqlParser::ParseError: parse_alter_column_statistics_r can't parse \"STATISTICS bad\"\n" \
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
end
