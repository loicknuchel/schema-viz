# frozen_string_literal: true

require './lib/schema-viz/utils/args'
require './test/test_helper'

describe SchemaViz::Args do
  args = SchemaViz::Args

  it 'parses args' do
    assert_equal args.new(nil, {}, []),
                 args.parse([])
    assert_equal args.new('parse', {}, []),
                 args.parse(%w[parse])
    assert_equal args.new(nil, { structure: './path/to/file' }, []),
                 args.parse(%w[--structure ./path/to/file])
    assert_equal args.new('generate', { structure: './path/to/file' }, []),
                 args.parse(%w[generate --structure ./path/to/file])
    assert_equal args.new('generate', {}, ['flag']),
                 args.parse(%w[generate --flag])
    assert_equal args.new('cmd', { a1: %w[v1.1 v1.2], a2: 'v2.1' }, %w[f1 f2 f3]),
                 args.parse(%w[cmd f1 --f2 --a1 v1.1 v1.2 --f3 --a2 v2.1])
  end
end
