require 'minitest/autorun'
require 'sketch/group'

describe Sketch::Group do
  describe "when constructed" do
    describe "with no arguments" do
      subject { Sketch::Group.new }

      it "must have an identity transformation" do
        assert_equal subject.transformation.identity?, true
      end

      it "must be empty" do
        assert_equal subject.elements.size, 0
      end
    end

    it "must accept valid Transformation arguments" do
      group = Sketch::Group.new origin:[1,2,3]
      assert_equal group.transformation.translation, Point[1,2,3]
    end
  end
end
