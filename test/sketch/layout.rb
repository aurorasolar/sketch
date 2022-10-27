require 'minitest/autorun'
require 'sketch/layout'

describe Sketch::Layout do
  Group = Sketch::Group

  describe "when constructed" do
    describe "with no arguments" do
      subject { Sketch::Layout.new }

      it "must have an identity transformation" do
        _(subject.transformation.identity?).must_equal true
      end

      it "must be empty" do
        _(subject.elements.size).must_equal 0
      end
    end

    describe "with a transformation" do
      subject { Sketch::Layout.new origin:[1,2] }

      it "must set the transformation property" do
        _(subject.transformation).must_equal Geometry::Transformation.new(origin:Point[1,2])
      end
    end
  end

  describe "when horizontal" do
    subject { Sketch::Layout.new :horizontal }

    it "must layout primitive objects" do
      subject.push Geometry::Rectangle.new from:[0,0], to:[5,5]
      subject.push Geometry::Rectangle.new from:[0,0], to:[6,6]

      _(subject.first).must_be_kind_of Geometry::Rectangle
      _(subject.last).must_be_kind_of Sketch::Group

      _(subject.last.transformation.translation).must_equal Point[5,0]
    end

    it "must layout groups" do
      group = Group.new
      group.push Geometry::Rectangle.new from:[0,0], to:[5,5]
      subject.push group

      group = Group.new
      group.push Geometry::Rectangle.new from:[0,0], to:[6,6]
      subject.push group

      _(subject.elements.count).must_equal 2

      assert_nil subject.first.transformation.translation
      _(subject.last.transformation.translation).must_equal Point[5,0]
    end

    describe "with spacing" do
      subject { Sketch::Layout.new :horizontal, spacing:1 }

      it "must add space between the elements" do
        group = Group.new.push Geometry::Rectangle.new from:[0,0], to:[5,5]
        subject.push group

        group = Group.new.push Geometry::Rectangle.new from:[0,0], to:[6,6]
        subject.push group

        _(subject.first.transformation.translation).must_be_nil
        _(subject.last.transformation.translation).must_equal Point[6,0]
      end
    end

    describe "when bottom aligned" do
      subject { Sketch::Layout.new :horizontal, align: :bottom }

      it "must bottom align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new from:[0,-1], to:[5,5]
        subject.push Group.new.push Geometry::Rectangle.new from:[0,-1], to:[6,6]

        _(subject.first.transformation.translation).must_equal Point[0,1]
        _(subject.last.transformation.translation).must_equal Point[5,1]
      end
    end

    describe "when top aligned" do
      subject { Sketch::Layout.new :horizontal, align: :top }

      it "must top align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new from:[0,0], to:[5,5]
        subject.push Group.new.push Geometry::Rectangle.new from:[0,0], to:[6,6]

        _(subject.elements.count).must_equal 2

        _(subject.first.transformation.translation).must_equal Point[0,1]
        _(subject.last.transformation.translation).must_equal Point[5,0]
      end
    end
  end

  describe "when vertical" do
    subject { Sketch::Layout.new :vertical }

    it "must layout groups" do
      group = Group.new
      group.push Geometry::Rectangle.new from:[0,0], to:[5,5]
      subject.push group

      group = Group.new
      group.push Geometry::Rectangle.new from:[0,0], to:[6,6]
      subject.push group

      _(subject.first.transformation.translation).must_be_nil
      _(subject.last.transformation.translation).must_equal Point[0,5]
    end

    describe "with spacing" do
      subject { Sketch::Layout.new :vertical, spacing:1 }

      it "must add space between the elements" do
        group = Group.new.push Geometry::Rectangle.new from:[0,0], to:[5,5]
        subject.push group

        group = Group.new.push Geometry::Rectangle.new from:[0,0], to:[6,6]
        subject.push group

        _(subject.first.transformation.translation).must_be_nil
        _(subject.last.transformation.translation).must_equal Point[0,6]
      end
    end

    describe "when left aligned" do
      subject { Sketch::Layout.new :vertical, align: :left }

      it "must left align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new from:[-1,0], to:[5,5]
        subject.push Group.new.push Geometry::Rectangle.new from:[-1,0], to:[6,6]

        _(subject.first.transformation.translation).must_equal Point[1,0]
        _(subject.last.transformation.translation).must_equal Point[1,5]
      end

      it "must left align primitive objects" do
        subject.push Geometry::Rectangle.new from:[-1,-1], to:[5,5]
        subject.push Geometry::Rectangle.new from:[0,0], to:[6,6]

        _(subject.first).must_be_kind_of Sketch::Group
        _(subject.last).must_be_kind_of Sketch::Group

        _(subject.first.transformation.translation).must_equal Point[1,1]
        _(subject.last.transformation.translation).must_equal Point[0,6]
      end
    end

    describe "when right aligned" do
      subject { Sketch::Layout.new :vertical, align: :right }

      it "must right align the elements" do
        subject.push Group.new.push Geometry::Rectangle.new from:[0,0], to:[5,5]
        subject.push Group.new.push Geometry::Rectangle.new from:[0,0], to:[6,6]

        _(subject.elements.count).must_equal 2

        _(subject.first.transformation.translation).must_equal Point[1,0]
        _(subject.last.transformation.translation).must_equal Point[0,5]
      end
    end
  end
end
