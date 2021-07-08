# frozen_string_literal: true

require './test/test_helper'

describe SchemaViz::Matcher do
  matcher = SchemaViz::Matcher

  it 'parse and get values' do
    text = "CREATE TABLE public.users"
    regex = /CREATE (?<kind>[^ ]+) (?<schema>[^.]+)\.(?<table>[^ ]+)/
    res = matcher.new(text, regex)
    assert_equal SchemaViz::Result.of("TABLE"), res.get('kind')
    assert_equal SchemaViz::Result.of(%w[public users]), res.slice('schema', 'table')
    assert_equal SchemaViz::Result.of(%w[TABLE public users]), res.captures
  end
end
