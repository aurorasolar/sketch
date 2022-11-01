require 'minitest/autorun'
require 'geometry/dsl/polyline'

class Fake
  attr_accessor :elements

  include Geometry::DSL::Polyline

  def initialize
    @elements = []
  end

  def first
    @elements.first
  end

  def last
    @elements.last
  end

  def push(arg)
    @elements.push arg
  end
end

describe Geometry::DSL::Polyline do
  subject { Fake.new }

  it 'must have a start command' do
    subject.start_at [1,2]
    assert_equal subject.last, Point[1,2]
  end

  describe 'when started' do
    before do
      subject.start_at [1,2]
    end

    it 'must refuse to start again' do
      assert_raises(Geometry::DSL::Polyline::BuildError) { subject.start_at [2,3] }
    end

    it 'must have a close command' do
      subject.move_to [3,4]
      subject.move_to [4,4]
      subject.close
      assert_equal subject.last, Point[1,2]
    end

    it 'must have a move_to command' do
      subject.move_to [3,4]
      assert_equal subject.last, Point[3,4]
    end

    it 'must have a relative horizontal move command' do
      subject.move_x 3
      assert_equal subject.last, Point[4,2]
    end

    it 'must have a relative vertical move command' do
      subject.move_y 4
      assert_equal subject.last, Point[1,6]
    end

    it 'must have an up command' do
      assert_equal subject.up(3).last, Point[1,5]
    end

    it 'must have a down command' do
      assert_equal subject.down(3).last, Point[1,-1]
    end

    it 'must have a left command' do
      assert_equal subject.left(3).last, Point[-2,2]
    end

    it 'must have a right command' do
      assert_equal subject.right(3).last, Point[4,2]
    end
  end
end
