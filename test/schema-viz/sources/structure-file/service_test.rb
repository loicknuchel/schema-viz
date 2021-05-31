# frozen_string_literal: true

require './lib/schema-viz/sources/structure-file/service'
require './lib/schema-viz/utils/file'
require './test/test_helper'

describe SchemaViz::Source::StructureFile::Service do
  pkg = SchemaViz::Source::StructureFile
  service = pkg::Service.new(SchemaViz::File::Service.new)

  it 'parse a sql file' do
    file = './test/resources/structure.sql'
    structure = service.parse_schema_file_r(file).get!
    assert_equal 2, structure.tables.length
    # primary key is added
    assert_nil structure.table('public', 'table1').primary_key
    assert_equal ['id'], structure.table('public', 'table2').primary_key.columns
    # foreign keys are added
    assert_nil structure.column('public', 'table2', 'id').reference
    assert_equal 'table2_table1_id_fk', structure.column('public', 'table2', 'table1_id').reference.name
    # unique constraint
    assert_nil structure.table('public', 'table1').uniques
    assert_equal %w[table1_id name], structure.table('public', 'table2').uniques[0].columns
    # check constraint
    assert_nil structure.table('public', 'table2').checks
    assert_equal '((user_id > 10)) NOT VALID', structure.table('public', 'table1').checks[0].predicate
    # column default
    assert_equal "nextval('public.table2_id_seq'::regclass)", structure.column('public', 'table2', 'id').default
    # comments are added
    assert_nil structure.table('public', 'table2').comment
    assert_nil structure.column('public', 'table1', 'id').comment
    assert_equal 'This is the first table', structure.table('public', 'table1').comment
    assert_equal 'An external \'id\' or "value"', structure.column('public', 'table1', 'user_id').comment
    # sources are kept
    assert_equal file, structure.src
    assert_equal 6, structure.table('public', 'table1').src.line
    assert_equal 9, structure.column('public', 'table1', 'created_at').src.line
    assert_equal 17, structure.table('public', 'table1').checks[0].src.line
    assert_equal 39, structure.table('public', 'table2').primary_key.src.line
    assert_equal 42, structure.column('public', 'table2', 'table1_id').reference.src.line
    assert_equal 49, structure.table('public', 'table2').uniques[0].src.line
  end

  it 'builds statements from lines' do
    lines = [
      '',
      '-- a comment',
      '',
      'CREATE TABLE public.users (',
      '  id bigint NOT NULL,',
      '  name character varying(255)',
      ');',
      '',
      "COMMENT ON TABLE public.users IS 'A comment ; ''tricky'' one';",
      '',
      'ALTER TABLE ONLY public.users',
      '  ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);',
      ''
    ]
    statements_with_indexes = [
      pkg::Service::Statement.new('structure.sql', 4, [
        pkg::Service::Line.new('structure.sql', 4, 'CREATE TABLE public.users ('),
        pkg::Service::Line.new('structure.sql', 5, '  id bigint NOT NULL,'),
        pkg::Service::Line.new('structure.sql', 6, '  name character varying(255)'),
        pkg::Service::Line.new('structure.sql', 7, ');')
      ]),
      pkg::Service::Statement.new('structure.sql', 9, [
        pkg::Service::Line.new('structure.sql', 9, "COMMENT ON TABLE public.users IS 'A comment ; ''tricky'' one';")
      ]),
      pkg::Service::Statement.new('structure.sql', 11, [
        pkg::Service::Line.new('structure.sql', 11, 'ALTER TABLE ONLY public.users'),
        pkg::Service::Line.new('structure.sql', 12, '  ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);')
      ])
    ]
    assert_equal statements_with_indexes, service.build_statements('structure.sql', lines)
  end
end
