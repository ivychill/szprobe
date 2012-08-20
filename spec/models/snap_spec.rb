require 'spec_helper'

describe Snap do
  before(:each) do
    @attr = { 
      :ts => Time.now,
      :city => "shenzhen"
    }
    @congested_road_attr = { 
      :rn => "shennan road",
      :href => "http://wap.szicity.com"
    }
  end
  
  it "should create a new instance given a valid attribute" do
    snap = Snap.create!(@attr)
  end

  it "should create a new instance with one congested road" do
    snap = Snap.create!(@attr)
    congested_roads = snap.congested_roads.create!(@congested_road_attr)
  end


end
