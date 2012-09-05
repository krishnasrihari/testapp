require 'spec_helper'

describe GalleryImagesController do
  ignore_authorization!

  let(:dev) { stub_model(Development) }
  before { Development.stub(:find).with('123').and_return dev }


  describe "#index" do
    it "authorises" do
      should_authorize_for(:edit, dev)
      get(:index, 'development_id' => '123')
    end

    it "assigns variables" do
      dev.should_receive(:gallery_images).and_return ['one', 'two']
      get(:index, 'development_id' => '123')
      assigns(:development).should == dev
      assigns(:gallery_image).should be_an_instance_of(GalleryImage)
      assigns(:gallery_images).should == ['one', 'two']
    end
  end


  describe "#create" do
    let(:image) { stub save!: true }
    before { dev.stub_chain(:gallery_images, :build).with(params).and_return image }
    let(:params) { {'image' => '/an/image.png'} }

    it "authorises" do
      should_authorize_for(:edit, dev)
      post(:create, 'development_id' => '123', 'gallery_image' => params)
    end

    it "saves the image" do
      image.should_receive(:save!)
      post(:create, 'development_id' => '123', 'gallery_image' => params)
    end

    it "renders new image html" do
      post(:create, 'development_id' => '123', 'gallery_image' => params)
      response.should render_template partial: '_image_thumb' #TODO: also assert the locals
    end

  end

  describe "#update" do
    let(:image) { stub update_attributes!: true }
    before { dev.stub_chain(:gallery_images, :find).with('111').and_return image }
    let(:params) { {'image' => '/an/image.png'} }

    it "authorises" do
      should_authorize_for(:edit, dev)
      post(:update, 'development_id' => '123', 'id' => '111', 'gallery_image' => params)
    end

    it "updates the image" do
      image.should_receive(:update_attributes!).with params
      post(:update, 'development_id' => '123', 'id' => '111', 'gallery_image' => params)
    end
  end

  describe "#destroy" do
    let(:image) { stub destroy: true }
    before { dev.stub_chain(:gallery_images, :find).with('111').and_return image }

    it "authorises" do
      should_authorize_for(:edit, dev)
      post(:destroy, 'development_id' => '123', 'id' => '111')
    end

    it "deletes the image" do
      image.should_receive(:destroy)
      post(:destroy, 'development_id' => '123', 'id' => '111')
    end
  end

  describe "#position" do
    let(:image) { stub position_to: true }
    before { dev.stub_chain(:gallery_images, :find).with('111').and_return image }

    it "authorises" do
      should_authorize_for(:edit, dev)
      post :position, 'development_id' => '123', 'gallery_image_id' => '111', 'position' => '5'
    end

    it "repositions the image" do
      image.should_receive(:position_to).with(5)
      post :position, 'development_id' => '123', 'gallery_image_id' => '111', 'position' => '5'
    end
  end
end
