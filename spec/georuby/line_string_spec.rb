require 'spec_helper'

describe GeoRuby::SimpleFeatures::LineString do

  subject { line_string "0 0,1 1,0 0" }

  describe "#to_rgeo" do
    it "should create a RGeo Geos geometry" do
      subject.to_rgeo.should be_kind_of(RGeo::Geos::GeometryImpl)
    end

    context "returned RGeo LineString" do
      it "should have the same srid" do
        subject.to_rgeo.srid.should == subject.srid
      end
      it "should have the points" do
        line_string("0 0,1 1,0 0").to_rgeo.should == rgeo_line_string("0 0,1 1,0 0")
      end
    end 
  end

  describe "#==" do
    
    it "should be true when points are same" do
      line_string("0 0,1 1").should == line_string("0 0,1 1")
    end

    it "should be true when the other is LineRing with the same points" do
      line_string("0 0,1 1,0 0").should == line_string("0 0,1 1,0 0").to_ring
    end

  end

  describe "#to_ring" do

    it "should be a GeoRuby::SimpleFeatures::LinearRing" do
      subject.to_ring.should be_instance_of(GeoRuby::SimpleFeatures::LinearRing)
    end
    
    context "returned LinearRing" do
      
      it "should have the same srid" do
        subject.to_ring.should have_same(:srid).than(subject)
      end

      context "when line is closed" do
        subject { line_string("0 0,1 1,0 0") }

        it "should have the same points" do
          subject.to_ring.points.should == subject.points
        end
      end

      context "when line isn't closed" do
        subject { line_string("0 0,1 1") }

        it "should have the line points and the first one" do
          subject.to_ring.points.should == (subject.points << subject.first)
        end
      end
                              
    end

  end

  describe "#change" do

    let(:other_points) { subject.points + points("3 3") }
    
    it "should change the points if specified" do
      subject.change(:points => other_points).points.should == other_points
    end

    it "should change the points if specified" do
      subject.change(:srid => 1).srid.should == 1
    end

    it "should not change unspecified attributes" do
      subject.change(:points => other_points).should have_same(:srid, :with_z, :with_m).than(subject)
    end

  end

  describe "#reverse" do
    
    it "should return a LineString with reversed points" do
      subject.reverse.points.should == subject.points.reverse
    end

    it "should not change other attributes" do
      subject.reverse.should have_same(:srid, :with_z, :with_m).than(subject)
    end

  end

  describe "#to_wgs84" do

    subject { line_string("0 0,1 1,0 0").to_google }

    it "should project all points into wgs84" do
      subject.to_wgs84.points.each_with_index do |wgs84_point, index|
        wgs84_point.should == subject[index].to_wgs84
      end
    end

    it "should have the srid 4326" do
      subject.to_wgs84.srid.should == 4326
    end

    it "should not change other attributes" do
      subject.reverse.should have_same(:with_z, :with_m).than(subject)
    end

  end

  it "should be closed when is_closed is true" do
    subject.stub :is_closed => true
    subject.should be_closed
  end

end