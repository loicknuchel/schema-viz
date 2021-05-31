# frozen_string_literal: true

require './test/test_helper'
require './lib/schema-viz/utils/result'

describe SchemaViz::Result do
  result = SchemaViz::Result

  it 'creates a Result' do
    assert_equal result::Success.new(1), result.of(1)
    assert_equal result::Failure.new('err'), result.failure('err')
    assert_equal result::Success.new(5), result.rescue { 10 / 2 }.on_error(&:message)
    assert_equal result::Failure.new('divided by 0'), result.rescue { 10 / 0 }.on_error(&:message)
    assert_raises(NameError) { result.new(1) }
    assert_raises(NameError) { result::AbstractClass.new(1) }
  end

  it 'checks for a Result' do
    assert_equal result.of(1), result.expected!(result.of(1))
    assert_equal result.failure('err'), result.expected!(result.failure('err'))
    assert_raises(TypeError) { result.expected!(1) }
  end

  it 'checks success' do
    assert_equal true, result.of(1).success?
    assert_equal false, result.failure('err').success?
  end

  it 'extracts value' do
    assert_equal 1, result.of(1).get!
    assert_equal 'err', result.failure('err').error!
    assert_raises(result::NotAFailure) { result.of(1).error! }
    assert_raises(result::NotASuccess) { result.failure('err').get! }
  end

  it 'transforms value' do
    assert_equal result.of('1'), result.of(1).map(&:to_s)
    assert_equal result.of(1), result.of(1).on_error(&:to_s)
    assert_equal result.failure(1), result.failure(1).map(&:to_s)
    assert_equal result.failure('1'), result.failure(1).on_error(&:to_s)

    assert_equal result.of(result.of('1')), (result.of(1).map { |i| result.of(i.to_s) })
    assert_equal result.of('1'), (result.of(1).flat_map { |i| result.of(i.to_s) })
    assert_equal result.failure('err'), (result.of(1).flat_map { |i| result.failure('err') })
    assert_equal result.failure('err'), (result.failure('err').flat_map { |i| result.of(i.to_s) })
    assert_equal result.failure('err1'), (result.failure('err1').flat_map { |i| result.failure('err2') })
  end

  it 'combines results' do
    assert_equal result.of(6), result.of(1).and(result.of(2), result.of(3)) { |a, b, c| a + b + c }
    assert_equal result.failure('err1'), result.failure('err1').and(result.of(2), result.of(3)) { |a, b, c| a + b + c }
    assert_equal result.failure('err2'), result.of(1).and(result.failure('err2'), result.of(3)) { |a, b, c| a + b + c }
    assert_equal result.failure('err3'), result.of(1).and(result.of(2), result.failure('err3')) { |a, b, c| a + b + c }
    assert_equal result.failure(%w[err1 err2]), result.failure('err1').and(result.failure('err2'), result.of(3)) { |a, b, c| a + b + c }

    assert_equal result.of(6), result.of(1).flat_and(result.of(2), result.of(3)) { |a, b, c| result.of(a + b + c) }
  end

  it 'extracts Result from Array' do
    assert_equal result.of([1, 2]), result.seq([result.of(1), result.of(2)])
    assert_equal result.failure('err1'), result.seq([result.failure('err1'), result.of(2)])
    assert_equal result.failure('err2'), result.seq([result.of(1), result.failure('err2')])
    assert_equal result.failure(%w[err1 err2]), result.seq([result.failure('err1'), result.failure('err2')])
  end
end
