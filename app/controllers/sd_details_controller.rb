class SdDetailsController < ApplicationController
  load_and_authorize_resource :except => [:create]
  before_action :set_sd_detail, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @sd_details = SdDetail.order("name")
    @search = @sd_details.search(params[:q])
    @sd_details = @search.result.page(params[:page]).per(30)
    respond_with(@sd_details)
  end

  def show
    respond_with(@sd_detail)
  end

  def new
    @sd_details = SdDetail.order("name")
    @search = @sd_details.search(params[:q])
    @sd_details = @search.result.page(params[:page]).per(30)
    @sd_detail = SdDetail.new
    respond_with(@sd_detail)
  end

  def edit
    @sd_details = SdDetail.order("name")
    @search = @sd_details.search(params[:q])
    @sd_details = @search.result.page(params[:page]).per(30)
  end

  def create
    @sd_details = SdDetail.order("name")
    @search = @sd_details.search(params[:q])
    @sd_details = @search.result.page(params[:page]).per(30)
    @sd_detail = SdDetail.new(sd_detail_params)
    @sd_detail.save
    respond_with(@sd_detail, :location => new_sd_detail_url)
  end

  def update
    @sd_details = SdDetail.order("name")
    @search = @sd_details.search(params[:q])
    @sd_details = @search.result.page(params[:page]).per(30)
    @sd_detail.update(sd_detail_params)
    respond_with(@sd_detail, :location => new_sd_detail_url)
  end

  def destroy
    @sd_details = SdDetail.order("name")
    @search = @sd_details.search(params[:q])
    @sd_details = @search.result.page(params[:page]).per(30)
    @sd_detail.destroy
    respond_with(@sd_detail)
  end

  private
    def set_sd_detail
      @sd_detail = SdDetail.find(params[:id])
    end

    def sd_detail_params
      params.require(:sd_detail).permit(:name,:description)
    end
end
