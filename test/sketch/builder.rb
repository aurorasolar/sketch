require 'minitest/autorun'
require 'geometry'
require 'sketch/builder'

describe Sketch::Builder do
  Builder = Sketch::Builder
  Rectangle = Geometry::Rectangle

  subject { Builder.new }

  describe "when initialized without a block" do
    let(:builder) { Builder.new }

    it "should create a new Sketch when initialized without a Sketch" do
      _(builder.sketch).must_be_instance_of(Sketch)
    end

    it "should use the given sketch when initialized with an existing Sketch" do
      sketch = Sketch.new
      _(Builder.new(sketch).sketch).must_be_same_as(sketch)
    end

    it "must have a push method that pushes elements" do
      builder.push Rectangle.new(size:[5, 5])
      assert_kind_of Rectangle, builder.sketch.elements.last
    end

    describe "command handlers" do
      it "must recognize the rectangle command" do
        _(builder.rectangle([1,2], [3,4])).must_be_instance_of(Rectangle)
        assert_kind_of Rectangle, builder.sketch.elements.last
      end
    end

    describe "when evaluating a block" do
      describe "with simple geometry" do
        before do
          builder.evaluate do
            square 5
          end
        end

        it "should create the commanded elements" do
          assert_kind_of Geometry::Square, builder.sketch.elements.last
        end

        it "triangle" do
          builder.evaluate { triangle [0,0], [1,0], [0,1] }
        end
      end

      describe "that defines a parameter" do
        before do
          builder.evaluate do
            let(:parameterA) { 42 }
            circle [1,2], parameterA
          end
        end

        it "must define the parameter" do
          assert_equal builder.sketch.parameterA, 42
        end

        it "must use the parameter" do
          _(builder.sketch.elements.last).must_be_instance_of Geometry::Circle
          assert_equal builder.sketch.elements.last.radius, 42
        end
      end

      describe "with a path block" do
        before do
          builder.evaluate do
            path do
            end
          end
        end

        it "must add a Path object to the Sketch" do
          _(builder.sketch.elements.last).must_be_instance_of Geometry::Path
        end
      end
    end
  end

  describe "when initialized with a block " do
    let(:builder) {
      Builder.new do
        square 5
      end
    }

    it "must evaluate the block" do
      assert_kind_of Geometry::Square, builder.sketch.elements.last
    end
  end

  describe "when adding a group" do
    describe "without a block" do
      before do
        subject.group origin:[1,2,3]
      end

      it "must have a group element" do
        assert_kind_of Sketch::Group, subject.sketch.elements.first
        assert_equal subject.sketch.elements.first.translation, Point[1,2,3]
      end
    end

    describe "with a block" do
      before do
        subject.group(origin:[1,2,3]) { circle(diameter:1) }
      end

      it "must have a group element" do
        assert_kind_of Sketch::Group, subject.sketch.elements.first
      end

      it "must have the correct property values" do
        assert_equal subject.sketch.elements.first.translation, Point[1,2,3]
      end
    end
  end

  describe "when adding a translation" do
    before do
      subject.translate([1,2]) { circle diameter:1 }
    end

    it "must have a group element" do
      assert_kind_of Sketch::Group, subject.sketch.elements.first
    end

    it "must have the correct property values" do
      assert_equal subject.sketch.elements.first.translation, Point[1,2]
    end

    it 'must reject higher dimensions' do
      assert_raises(ArgumentError) { subject.translate [1,2,3] }
    end
  end

  describe "when adding a nested translation" do
    before do
      subject.translate [1,2] do
        translate([3,4]) { circle diameter:2 }
      end
    end

    it "must have a group element" do
      assert_kind_of Sketch::Group, subject.sketch.elements.first
    end

    it "must have the correct property values" do
      assert_equal subject.sketch.elements.first.translation, Point[1,2]
    end

    it "must have a sub-group element" do
      outer_group = subject.sketch.elements.first
      assert_kind_of Sketch::Group, outer_group.elements.first
    end

    it "must set the sub-group properties" do
      outer_group = subject.sketch.elements.first
      assert_equal outer_group.elements.first.translation, Point[3,4]
    end
  end
end
