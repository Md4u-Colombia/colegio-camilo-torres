class LocalizationsController < ApplicationController
  load_and_authorize_resource :except => [:create]
  before_action :set_localization, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @localizations = Localization.all
    respond_with(@localizations)
  end

  def show
    respond_with(@localization)
  end

  def new
    @localization = Localization.new
    respond_with(@localization)
  end

  def edit
  end

  def create
    @localization = Localization.new(localization_params)
    @localization.save
    respond_with(@localization)
  end

  def update
    @localization.update(localization_params)
    respond_with(@localization)
  end

  def destroy
    @localization.destroy
    respond_with(@localization)
  end

  private
    def set_localization
      @localization = Localization.find(params[:id])
    end

    def localization_params
      params.require(:localization).permit(:name, :parent_id, :status)
    end
end
