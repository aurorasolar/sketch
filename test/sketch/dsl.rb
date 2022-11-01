require 'minitest/autorun'
require 'sketch/dsl'

class Fake
  attr_accessor :elements

  include Sketch::DSL

  def initialize
    @elements = []
  end

  def push(*args)
    elements.push args.first
  end
end

describe Sketch::DSL do
  Point = Geometry::Point

  subject { Fake.new }

  it "must have a first command that returns the first element" do
    point = Geometry::Point[1,2]
    subject.elements.push point
    _(subject.first).must_be_same_as point
  end

  it "must have a last command that returns the last element" do
    point = Point[1,2]
    subject.elements.push Point[3,4]
    subject.elements.push point
    _(subject.last).must_be_same_as point
  end

  it "must have a hexagon command" do
    subject.hexagon center:[1,2], radius:5
    _(subject.last).must_be_instance_of Geometry::RegularPolygon
    assert_equal subject.last.center, Point[1,2]
    assert_equal subject.last.edge_count, 6
    assert_equal subject.last.radius, 5
  end

  it 'must have a path command that takes a list of points' do
    subject.path [1,2], [2,3]
    assert_kind_of Geometry::Path, subject.last
    assert_equal subject.last.elements.count, 1
  end

  it 'must have a path command that takes a block' do
    subject.path do
      start_at    [0,0]
      move_to	[1,1]
    end
    assert_kind_of Geometry::Path, subject.last
    assert_equal subject.last.elements.count, 1
  end

  describe "when layout" do
    describe "without spacing" do
      it "must do a horizontal layout" do
        subject.layout :horizontal do
          rectangle from:[0,0], to:[5,5]
          rectangle from:[0,0], to:[6,6]
        end

        group = subject.first
        _(group).must_be_instance_of Sketch::Layout

        assert_kind_of Geometry::Rectangle, group.first
        assert_kind_of Sketch::Group, group.last
      end

      it "must do a vertical layout" do
      end
    end

    describe "with spacing" do
      it "must do a horizontal layout" do
      end

      it "must do a vertical layout" do
      end
    end
  end

  it 'must have a polygon command that takes a list of points' do
    polygon = subject.polygon [0,0], [1,0], [1,1], [0,1]
    assert_kind_of Sketch::Polygon, polygon
    assert_equal subject.last.vertices.size, 4
  end

  it 'must have a polygon command that takes a block' do
    subject.polygon do
      start_at    [0,0]
      move_to	    [1,0]
      move_to	    [1,1]
      move_to	    [0,1]
    end
    assert_kind_of Sketch::Polygon, subject.last
    assert_equal subject.elements.size, 1
    assert_equal subject.last.vertices.size, 4
  end
end
