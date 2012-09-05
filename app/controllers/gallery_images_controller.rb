class GalleryImagesController < ApplicationController
  before_filter { @development = Development.find params[:development_id] }
  before_filter { authorize! :edit, @development }

  def index
    @gallery_image = GalleryImage.new
    @gallery_images = @development.gallery_images
  end

  def create
    @gallery_image = @development.gallery_images.build params[:gallery_image]
    @gallery_image.save!
    render partial: 'image_thumb', locals: {image: @gallery_image}
  end

  def update
    @gallery_image = @development.gallery_images.find params[:id]
    @gallery_image.update_attributes!(params[:gallery_image])
    render json: {action: :nothing}
  end

  def destroy
    @gallery_image = @development.gallery_images.find params[:id]
    @gallery_image.destroy
    render json: {action: :destroy}
  end

  def position
    @gallery_image = @development.gallery_images.find params[:gallery_image_id]
    @gallery_image.position_to(params[:position].to_i)
    render json: {ok: true}
  end

end
