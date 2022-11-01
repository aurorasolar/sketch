require 'minitest/autorun'
require 'sketch/builder/path'

describe Sketch::Builder::Path do
  Path = Sketch::Path
  Point = Geometry::Point

  let(:builder) { Sketch::Builder::Path.new }

  it "must build a Path from a block" do
    assert_kind_of Path, builder.evaluate {}
  end
end
