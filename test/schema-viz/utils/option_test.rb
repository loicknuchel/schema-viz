# frozen_string_literal: true

require './test/test_helper'

describe SchemaViz::Option do
  option = SchemaViz::Option

  it 'creates an Option' do
    assert_equal option::Some.new(1), option.of(1)
    assert_equal option::None.instance, option.of(nil)
    assert_equal option::None.instance, option.empty
    assert_raises(NameError) { option.new(1) }
    assert_raises(NameError) { option::AbstractClass.new(1) }
  end

  it 'checks for an Option' do
    assert_equal option.of(1), option.expected!(option.of(1))
    assert_equal option.empty, option.expected!(option.empty)
    assert_raises(TypeError) { option.expected!(1) }
  end

  it 'checks presence' do
    assert_equal true, option.of(1).some?
    assert_equal false, option.empty.some?
  end

  it 'extracts value' do
    assert_equal 1, option.of(1).get!
    assert_raises(option::NoSuchElementError) { option.empty.get! }

    assert_equal 1, option.of(1).get_or_else(2)
    assert_equal 2, option.empty.get_or_else(2)
  end

  it 'transforms value' do
    assert_equal option.of('1'), option.of(1).map(&:to_s)
    assert_equal option.empty, option.empty.map(&:to_s)

    assert_equal option.of(option.of('1')), (option.of(1).map { |i| option.of(i.to_s) })
    assert_equal option.of('1'), (option.of(1).flat_map { |i| option.of(i.to_s) })
    assert_equal option.empty, (option.of(1).flat_map { |i| option.empty })
    assert_equal option.empty, (option.empty.flat_map { |i| option.of(i.to_s) })
    assert_equal option.empty, (option.empty.flat_map { |i| option.empty })
  end
end

