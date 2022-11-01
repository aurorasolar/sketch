require 'minitest/autorun'
require 'sketch/layout'

describe Sketch::Layout do
  Group = Sketch::Group

  describe "when constructed" do
    describe "with no arguments" do
      subject { Sketch::Layout.new }

      it "must have an identity transformation" do
        assert_equal subject.transformation.identity?, true
      end

      it "must be empty" do
        assert_equal subject.elements.size, 0
      end
    end

    describe "with a transformation" do
      subject { Sketch::Layout.new origin:[1,2] }

      it "must set the transformation property" do
        assert_equal subject.transformation, Geometry::Transformation.new(origin:Point[1,2])
      end
    end
  end

  describe "when horizontal" do
    subject { Sketch::Layout.new :horizontal }

    it "must layout primitive objects" do
      subject.push Geometry::Rectangle.new(from:[0,0], to:[5,5])
      subject.push Geometry::Rectangle.new(from:[0,0], to:[6,6])

      assert_kind_of Geometry::Rectangle, subject.first
      assert_kind_of Sketch::Group, subject.last

      assert_equal subject.last.transformation.translation, Point[5,0]
    end

    it "must layout groups" do
      group = Group.new
      group.push Geometry::Rectangle.new(from:[0,0], to:[5,5])
      subject.push group

      group = Group.new
      group.push Geometry::Rectangle.new(from:[0,0], to:[6,6])
      subject.push group

      assert_equal subject.elements.count, 2

      assert_nil subject.first.transformation.translation
      assert_equal subject.last.transformation.translation, Point[5,0]
    end

    describe "with spacing" do
      subject { Sketch::Layout.new :horizontal, spacing:1 }

      it "must add space between the elements" do
        group = Group.new.push Geometry::Rectangle.new(from:[0,0], to:[5,5])
        subject.push group

        group = Group.new.push Geometry::Rectangle.new(from:[0,0], to:[6,6])
        subject.push group

        assert_nil subject.first.transformation.translation
        assert_equal subject.last.transformation.translation, Point[6,0]
      end
    end

    describe "when bottom aligned" do
      subject { Sketch::Layout.new :horizontal, align: :bottom }

      it "must bottom align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new(from:[0,-1], to:[5,5])
        subject.push Group.new.push Geometry::Rectangle.new(from:[0,-1], to:[6,6])

        assert_equal subject.first.transformation.translation, Point[0,1]
        assert_equal subject.last.transformation.translation, Point[5,1]
      end
    end

    describe "when top aligned" do
      subject { Sketch::Layout.new :horizontal, align: :top }

      it "must top align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new(from:[0,0], to:[5,5])
        subject.push Group.new.push Geometry::Rectangle.new(from:[0,0], to:[6,6])

        assert_equal subject.elements.count, 2

        assert_equal subject.first.transformation.translation, Point[0,1]
        assert_equal subject.last.transformation.translation, Point[5,0]
      end
    end
  end

  describe "when vertical" do
    subject { Sketch::Layout.new :vertical }

    it "must layout groups" do
      group = Group.new
      group.push Geometry::Rectangle.new(from:[0,0], to:[5,5])
      subject.push group

      group = Group.new
      group.push Geometry::Rectangle.new(from:[0,0], to:[6,6])
      subject.push group

      assert_nil subject.first.transformation.translation
      assert_equal subject.last.transformation.translation, Point[0,5]
    end

    describe "with spacing" do
      subject { Sketch::Layout.new :vertical, spacing:1 }

      it "must add space between the elements" do
        group = Group.new.push Geometry::Rectangle.new(from:[0,0], to:[5,5])
        subject.push group

        group = Group.new.push Geometry::Rectangle.new(from:[0,0], to:[6,6])
        subject.push group

        assert_nil subject.first.transformation.translation
        assert_equal subject.last.transformation.translation, Point[0,6]
      end
    end

    describe "when left aligned" do
      subject { Sketch::Layout.new :vertical, align: :left }

      it "must left align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new(from:[-1,0], to:[5,5])
        subject.push Group.new.push Geometry::Rectangle.new(from:[-1,0], to:[6,6])

        assert_equal subject.first.transformation.translation, Point[1,0]
        assert_equal subject.last.transformation.translation, Point[1,5]
      end

      it "must left align primitive objects" do
        subject.push Geometry::Rectangle.new(from:[-1,-1], to:[5,5])
        subject.push Geometry::Rectangle.new(from:[0,0], to:[6,6])

        assert_kind_of Sketch::Group, subject.first
        assert_kind_of Sketch::Group, subject.last

        assert_equal subject.first.transformation.translation, Point[1,1]
        assert_equal subject.last.transformation.translation, Point[0,6]
      end
    end

    describe "when right aligned" do
      subject { Sketch::Layout.new :vertical, align: :right }

      it "must right align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new(from:[0,0], to:[5,5])
        subject.push Group.new.push Geometry::Rectangle.new(from:[0,0], to:[6,6])

        assert_equal subject.elements.count, 2

        assert_equal subject.first.transformation.translation, Point[1,0]
        assert_equal subject.last.transformation.translation, Point[0,5]
      end
    end
  end
end
