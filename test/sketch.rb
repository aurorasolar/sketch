require 'minitest/autorun'
require 'sketch'
require 'set'

describe Sketch do
  Size = Geometry::Size

  let(:sketch)    { Sketch.new }

  it "should create a Sketch object" do
    assert_kind_of Sketch, sketch
  end

  it "should have a read only elements accessor" do
    _(sketch).must_respond_to :elements
    _(sketch).wont_respond_to :elements=
  end

  it "must have a push method that pushes an element" do
    sketch.push Rectangle.new(size:[5, 5])
    assert_kind_of Rectangle, sketch.elements.last
  end

  it "must push a sketch with a transformation" do
    sketch.push Sketch.new(), origin:[1,2]
    assert_kind_of Sketch, sketch.elements.last
    assert_equal sketch.elements.last.transformation, Geometry::Transformation.new(origin:[1,2])
  end

  describe "parameters" do
    it "must define custom parameters" do
      Sketch.define_parameter(:a_parameter) { 42 }
      assert_equal Sketch.new.a_parameter, 42
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
    assert_kind_of Geometry::Circle, circle
    assert_equal circle.center, Point[1,2]
    assert_equal circle.radius, 3
  end

  it "should have a point creation method" do
    point = sketch.add_point(5,6)
    assert_kind_of Sketch::Point, point
    assert_equal point.x, 5
    assert_equal point.y, 6
  end

  it "have a line creation method" do
    line = sketch.add_line([5,6], [7,8])
    assert_kind_of Sketch::Line, line
  end

  it "have a rectangle creation method" do
    rectangle = sketch.add_rectangle size:[10, 20]
    assert_kind_of Geometry::Rectangle, rectangle
    assert_equal rectangle.points, [Point[0,0], Point[0,20], Point[10,20], Point[10,0]]
  end

  it "should have a method for adding a square" do
    square = sketch.add_square 10
    assert_kind_of Geometry::Square, square
    assert_equal square.width, 10
    assert_equal square.height, 10
    assert_equal square.center, Point[0,0]
    assert_equal square.points.to_set, [Point[-5,-5], Point[5,-5], Point[5,5], Point[-5,5]].to_set
  end

  describe "when constructed with a block" do
    before do
      @sketch = Sketch.new do
        add_circle [1,2], 3
      end
    end

    it "should execute the block" do
      circle = @sketch.elements.last
      assert_kind_of Geometry::Circle, circle
      assert_equal circle.center, Point[1,2]
      assert_equal circle.radius, 3
    end
  end

  describe "object creation" do
    it "must create an Arc" do
      arc = sketch.add_arc center:[1,2], radius:3, start:0, end:90
      assert_kind_of Geometry::Arc, sketch.elements.last
      assert_equal arc.center, Point[1,2]
      assert_equal arc.radius, 3
      assert_equal arc.start_angle, 0
      assert_equal arc.end_angle, 90
    end

    it "triangle" do
      triangle = sketch.add_triangle [0,0], [1,0], [0,1]
      assert_kind_of Geometry::Triangle, sketch.elements.last
    end
  end

  describe "properties" do
    subject { Sketch.new { add_circle([1,-2], 3); add_circle([-1,2], 3) } }

    it "must have a bounds rectangle" do
      assert_equal subject.bounds, Rectangle.new(from:[-4,-5], to:[4,5])
    end

    it "must have an accessor for the first element" do
      _(subject.first).must_be_instance_of(Geometry::Circle)
    end

    it "must have an accessor for the last element" do
      _(subject.last).must_be_instance_of(Geometry::Circle)
    end

    it "must have a max property that returns the upper right point of the bounding rectangle" do
      assert_equal subject.max, Point[4,5]
    end

    it "must have a min property that returns the lower left point of the bounding rectangle" do
      assert_equal subject.min, Point[-4,-5]
    end

    it "must have a minmax property that returns the corners of the bounding rectangle" do
      assert_equal subject.minmax, [Point[-4,-5], Point[4,5]]
    end

    it "must have a size" do
      assert_equal subject.size, Size[8,10]
      _(subject.size).must_be_instance_of(Size)
    end

    describe "when the Sketch is empty" do
      subject { Sketch.new }

      it "max must return nil" do
        assert_nil subject.max
      end

      it "min must return nil" do
        assert_nil subject.min
      end

      it "minmax must return an array of nils" do
        subject.minmax.each {|a| assert_nil a }
      end
    end

    describe "when the Sketch is rotated" do
      subject do
        s = Sketch.new { add_rectangle center:[0, -1.5], size:[6.5, 50.5] }
        s.transformation = Geometry::Transformation.new(angle:Math::PI/2)
        s
      end

      it "must have a min property that returns the lower left point of the bounding rectangle" do
        assert_in_epsilon subject.min.x, -23.75
        assert_in_epsilon subject.min.y, -3.25
      end
    end
  end

  describe "when the Sketch contains a group" do
    subject { Sketch::Builder.new(Sketch.new).evaluate { translate([1,2]) { circle([1,-2], 3); circle([-1,2], 3) } } }

    it "must have a max property" do
      assert_equal subject.max, Point[5,7]
    end

    it "must have a min property" do
      assert_equal subject.min, Point[-3,-3]
    end

    it "must have a minmax property" do
      assert_equal subject.minmax, [Point[-3,-3], Point[5,7]]
    end
  end
end
