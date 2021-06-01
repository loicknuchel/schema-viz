# frozen_string_literal: true

require './test/test_helper'

describe SchemaViz::Source::StructureFile::Service do
  pkg = SchemaViz::Source::StructureFile
  service = pkg::Service.new(SchemaViz::File::Service.new)

  it 'parse a sql file' do
    file = './test/resources/structure.sql'
    structure = service.parse_schema_file_r(file).get!
    assert_equal 2, structure.tables.length
    # primary key is added
    assert_equal SchemaViz::Option.empty, structure.table('public', 'table1').primary_key
    assert_equal ['id'], structure.table('public', 'table2').primary_key.get!.columns
    # foreign keys are added
    assert_equal SchemaViz::Option.empty, structure.column('public', 'table2', 'id').reference
    assert_equal 'table2_table1_id_fk', structure.column('public', 'table2', 'table1_id').reference.get!.name
    # unique constraint
    assert_equal [], structure.table('public', 'table1').uniques
    assert_equal %w[table1_id name], structure.table('public', 'table2').uniques[0].columns
    # check constraint
    assert_equal [], structure.table('public', 'table2').checks
    assert_equal '((user_id > 10)) NOT VALID', structure.table('public', 'table1').checks[0].predicate
    # column default
    assert_equal "nextval('public.table2_id_seq'::regclass)", structure.column('public', 'table2', 'id').default
    # comments are added
    assert_equal SchemaViz::Option.empty, structure.table('public', 'table2').comment
    assert_equal SchemaViz::Option.empty, structure.column('public', 'table1', 'id').comment
    assert_equal 'This is the first table', structure.table('public', 'table1').comment.get!
    assert_equal 'An external \'id\' or "value"', structure.column('public', 'table1', 'user_id').comment.get!
    # sources are kept
    assert_equal file, structure.src
    assert_equal 6, structure.table('public', 'table1').src.line
    assert_equal 9, structure.column('public', 'table1', 'created_at').src.line
    assert_equal 17, structure.table('public', 'table1').checks[0].src.line
    assert_equal 39, structure.table('public', 'table2').primary_key.get!.src.line
    assert_equal 42, structure.column('public', 'table2', 'table1_id').reference.get!.src.line
    assert_equal 49, structure.table('public', 'table2').uniques[0].src.line
  end

  it 'builds statements from lines' do
    file = 'structure.sql'
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
    ].each_with_index.map { |line, index| SchemaViz::File::Line.new(file, index + 1, line) }
    statements_with_indexes = [
      pkg::Statement.new(file, 4, [
        SchemaViz::File::Line.new(file, 4, 'CREATE TABLE public.users ('),
        SchemaViz::File::Line.new(file, 5, '  id bigint NOT NULL,'),
        SchemaViz::File::Line.new(file, 6, '  name character varying(255)'),
        SchemaViz::File::Line.new(file, 7, ');')
      ]),
      pkg::Statement.new(file, 9, [
        SchemaViz::File::Line.new(file, 9, "COMMENT ON TABLE public.users IS 'A comment ; ''tricky'' one';")
      ]),
      pkg::Statement.new(file, 11, [
        SchemaViz::File::Line.new(file, 11, 'ALTER TABLE ONLY public.users'),
        SchemaViz::File::Line.new(file, 12, '  ADD CONSTRAINT users_id_pkey PRIMARY KEY (id);')
      ])
    ]
    assert_equal statements_with_indexes, service.build_statements(lines)
  end
end
