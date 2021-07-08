# frozen_string_literal: true

require './lib/schema-viz/version'
require './test/test_helper'

describe SchemaViz do
  it 'has a version number' do
    refute_nil SchemaViz::VERSION
  end
end
