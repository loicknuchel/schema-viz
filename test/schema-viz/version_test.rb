# frozen_string_literal: true

require './test/test_helper'
require './lib/schema-viz/version'

describe SchemaViz do
  it 'has a version number' do
    refute_nil ::SchemaViz::VERSION
  end
end
