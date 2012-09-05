require 'spec_helper'

describe GalleryImage do

  its(:image_thumb_url) { should be_nil }
  its(:image_medium_url) { should be_nil }
  its(:image_large_url) { should be_nil }

  its(:description) { should be_nil }

  it { should belong_to(:development) }

  it "has the default description" do
    img = build :gallery_image, description: nil
    img.valid?
    img.description.should == img.image.name
  end

  describe "#position_to" do
    let(:dev) { create :development }
    let!(:img0) { create :gallery_image, development: dev }
    let!(:img1) { create :gallery_image, development: dev }
    let!(:img2) { create :gallery_image, development: dev }
    let!(:img3) { create :gallery_image, development: dev }

    before do
      [img0, img1, img2, img3].each_with_index {|i, idx| i.reload.position=idx; i.save! }
    end

    def positions
      [img0, img1, img2, img3].map{|x| x.reload.position}
    end

    it "is positioned initially correctly" do
      positions.should == [0,1,2,3]
    end

    it "changes the position to the given" do
      img2.position_to(99)
      img2.reload.position.should == 99
    end

    it "moving from the middle to the tail" do
      img1.position_to(3)
      positions.should == [0, 3, 1, 2]
    end

    it "moving from the middle to the front" do
      img2.position_to(1)
      positions.should == [0, 2, 1, 3]
    end

  end

  it "positions new images at the head so that every new image has position 0" do
    d = create :development
    img1 = create :gallery_image, development: d
    img2 = create :gallery_image, development: d

    img2.reload.position.should == 0
    img1.reload.position.should == 1
  end

  it "repositions images before deleting" do
    img1 = create :gallery_image
    img2 = create :gallery_image, development: img1.development
    img2.destroy
    img1.reload.position.should == 0
  end
end
