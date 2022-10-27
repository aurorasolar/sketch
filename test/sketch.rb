require 'minitest/autorun'
require 'sketch'
require 'set'

describe Sketch do
  Size = Geometry::Size

  let(:sketch)    { Sketch.new }

  it "should create a Sketch object" do
    _(sketch).must_be_kind_of Sketch
  end

  it "should have a read only elements accessor" do
    _(sketch).must_respond_to :elements
    _(sketch).wont_respond_to :elements=
  end

  it "must have a push method that pushes an element" do
    sketch.push Rectangle.new size:[5, 5]
    _(sketch.elements.last).must_be_kind_of Rectangle
  end

  it "must push a sketch with a transformation" do
    sketch.push Sketch.new(), origin:[1,2]
    _(sketch.elements.last).must_be_kind_of Sketch
    _(sketch.elements.last.transformation).must_equal Geometry::Transformation.new(origin:[1,2])
  end

  describe "parameters" do
    it "must define custom parameters" do
      Sketch.define_parameter(:a_parameter) { 42 }
      _(Sketch.new.a_parameter).must_equal 42
    end

    it "must bequeath custom parameters to subclasses" do
      Sketch.define_parameter(:a_parameter) { 42 }
      _(Class.new(Sketch).new).must_respond_to(:a_parameter)
    end

    it "must not allow access to parameters defined on a subclass" do
      Sketch.define_parameter(:a_parameter) { 42 }
      Class.new(Sketch).define_parameter(:b_parameter) { 24 }
      _(Sketch.new).wont_respond_to :b_parameter
    end
  end

  it "should have a circle command that makes a new circle from a center point and radius" do
    circle = sketch.add_circle [1,2], 3
    _(circle).must_be_kind_of Geometry::Circle
    _(circle.center).must_equal Point[1,2]
    _(circle.radius).must_equal 3
  end

  it "should have a point creation method" do
    point = sketch.add_point(5,6)
    _(point).must_be_kind_of Sketch::Point
    _(point.x).must_equal 5
    _(point.y).must_equal 6
  end

  it "have a line creation method" do
    line = sketch.add_line([5,6], [7,8])
    _(line).must_be_kind_of Sketch::Line
  end

  it "have a rectangle creation method" do
    rectangle = sketch.add_rectangle size:[10, 20]
    _(rectangle).must_be_kind_of Geometry::Rectangle
    _(rectangle.points).must_equal [Point[0,0], Point[0,20], Point[10,20], Point[10,0]]
  end

  it "should have a method for adding a square" do
    square = sketch.add_square 10
    _(square).must_be_kind_of Geometry::Square
    _(square.width).must_equal 10
    _(square.height).must_equal 10
    _(square.center).must_equal Point[0,0]
    _(square.points.to_set).must_equal [Point[-5,-5], Point[5,-5], Point[5,5], Point[-5,5]].to_set
  end

  describe "when constructed with a block" do
    before do
      @sketch = Sketch.new do
        add_circle [1,2], 3
      end
    end

    it "should execute the block" do
      circle = @sketch.elements.last
      _(circle).must_be_kind_of Geometry::Circle
      _(circle.center).must_equal Point[1,2]
      _(circle.radius).must_equal 3
    end
  end

  describe "object creation" do
    it "must create an Arc" do
      arc = sketch.add_arc center:[1,2], radius:3, start:0, end:90
      _(sketch.elements.last).must_be_kind_of Geometry::Arc
      _(arc.center).must_equal Point[1,2]
      _(arc.radius).must_equal 3
      _(arc.start_angle).must_equal 0
      _(arc.end_angle).must_equal 90
    end

    it "triangle" do
      triangle = sketch.add_triangle [0,0], [1,0], [0,1]
      _(sketch.elements.last).must_be_kind_of Geometry::Triangle
    end
  end

  describe "properties" do
    subject { Sketch.new { add_circle([1,-2], 3); add_circle([-1,2], 3) } }

    it "must have a bounds rectangle" do
      _(subject.bounds).must_equal Rectangle.new(from:[-4,-5], to:[4,5])
    end

    it "must have an accessor for the first element" do
      _(subject.first).must_be_instance_of(Geometry::Circle)
    end

    it "must have an accessor for the last element" do
      _(subject.last).must_be_instance_of(Geometry::Circle)
    end

    it "must have a max property that returns the upper right point of the bounding rectangle" do
      _(subject.max).must_equal Point[4,5]
    end

    it "must have a min property that returns the lower left point of the bounding rectangle" do
      _(subject.min).must_equal Point[-4,-5]
    end

    it "must have a minmax property that returns the corners of the bounding rectangle" do
      _(subject.minmax).must_equal [Point[-4,-5], Point[4,5]]
    end

    it "must have a size" do
      _(subject.size).must_equal Size[8,10]
      _(subject.size).must_be_instance_of(Size)
    end

    describe "when the Sketch is empty" do
      subject { Sketch.new }

      it "max must return nil" do
        _(subject.max).must_be_nil
      end

      it "min must return nil" do
        _(subject.min).must_be_nil
      end

      it "minmax must return an array of nils" do
        subject.minmax.each {|a| _(a).must_be_nil }
      end
    end

    describe "when the Sketch is rotated" do
      subject do
        s = Sketch.new { add_rectangle center:[0, -1.5], size:[6.5, 50.5] }
        s.transformation = Geometry::Transformation.new(angle:Math::PI/2)
        s
      end

      it "must have a min property that returns the lower left point of the bounding rectangle" do
        _(subject.min.x).must_be_close_to -23.75
        _(subject.min.y).must_be_close_to -3.25
      end
    end
  end

  describe "when the Sketch contains a group" do
    subject { Sketch::Builder.new(Sketch.new).evaluate { translate([1,2]) { circle([1,-2], 3); circle([-1,2], 3) } } }

    it "must have a max property" do
      _(subject.max).must_equal Point[5,7]
    end

    it "must have a min property" do
      _(subject.min).must_equal Point[-3,-3]
    end

    it "must have a minmax property" do
      _(subject.minmax).must_equal [Point[-3,-3], Point[5,7]]
    end
  end
end
