class BusinessUnitsController < ApplicationController
  load_and_authorize_resource :except => [:create]
  before_action :set_business_unit, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @business_units = BusinessUnit.all
    respond_with(@business_units)
  end

  def show
    respond_with(@business_unit)
  end

  def new
    @business_unit = BusinessUnit.new
    respond_with(@business_unit)
  end

  def edit
  end

  def create
    @business_unit = BusinessUnit.new(business_unit_params)
    @business_unit.save
    respond_with(@business_unit)
  end

  def update
    @business_unit.update(business_unit_params)
    respond_with(@business_unit)
  end

  def destroy
    @business_unit.destroy
    respond_with(@business_unit)
  end

  private
    def set_business_unit
      @business_unit = BusinessUnit.find(params[:id])
    end

    def business_unit_params
      params.require(:business_unit).permit(:name, :status)
    end
end
