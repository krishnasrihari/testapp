require 'spec_helper'

describe "gallery_images/index" do
  subject { render }

  let(:dev) { stub_model(Development, id: 123) }
  before { assign(:development, dev) }
  before { assign(:gallery_image, stub_model(GalleryImage, id: nil)) }

  before { assign(:gallery_images, [stub_model(GalleryImage, id: 333, development: dev)]) }

  it { should have_selector "form.new_gallery_image" }
  it { should have_selector "form[enctype='multipart/form-data']" }

  it { should have_selector "form input#gallery_image_image[type=file]" }
  it { should have_selector "form input[type=file][name='gallery_image[image]']" }

  it { should have_selector "form input[type=file][data-url='/developments/123/gallery_images']" }

  it { should have_selector "label", content: 'Image' }

  it { should have_selector ".uploading.hidden" }
end

