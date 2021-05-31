# frozen_string_literal: true

require './lib/schema-viz/sources/structure-file/service'
require './lib/schema-viz/utils/file'
require './test/test_helper'

describe SchemaViz::Source::StructureFile::Service do
  pkg = SchemaViz::Source::StructureFile
  service = pkg::Service.new(SchemaViz::FileService.new)

  it 'parse a sql file' do
    structure = service.parse_schema_file_r('./test/resources/structure.sql').get!
    assert_equal 2, structure.tables.length
    # primary key is added
    assert_nil structure.table('public', 'table1').primary_key
    assert_equal ['id'], structure.table('public', 'table2').primary_key
    # foreign keys are added
    assert_nil structure.column('public', 'table2', 'id').reference
    assert_equal pkg::Reference.new('public', 'table1', 'id', 'table2_table1_id_fk'), structure.column('public', 'table2', 'table1_id').reference
    # column default
    assert_equal "nextval('public.table2_id_seq'::regclass)", structure.column('public', 'table2', 'id').default
    # comments are added
    assert_nil structure.table('public', 'table2').comment
    assert_nil structure.column('public', 'table1', 'id').comment
    assert_equal 'This is the first table', structure.table('public', 'table1').comment
    assert_equal 'An external \'id\' or "value"', structure.column('public', 'table1', 'user_id').comment
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
    statements = [
      'CREATE TABLE public.users ( id bigint NOT NULL, name character varying(255) );',
      "COMMENT ON TABLE public.users IS 'A comment ; ''tricky'' one';",
      'ALTER TABLE ONLY public.users ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);'
    ]
    assert_equal statements, service.build_statements(lines)
  end
end
