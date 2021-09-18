class EducationalPeriodsController < ApplicationController
  load_and_authorize_resource :except => [:create,:destroy]
  before_action :set_educational_period, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @search = @EducationalPeriod.search(params[:q])
    @educational_periods = @search.result
    respond_with(@educational_periods)
  end

  def show
    respond_with(@educational_period)
  end

  def new
    @educational_period = EducationalPeriod.new
    @search = EducationalPeriod.search(params[:q])
    @educational_periods = @search.result.page(params[:page]).per(20)
    respond_with(@educational_period)
  end

  def edit
    @search = EducationalPeriod.search(params[:q])
    @educational_periods = @search.result.page(params[:page]).per(20)
  end

  def create
    @educational_period = EducationalPeriod.new(educational_period_params)
    unless @educational_period.save
      @search = EducationalPeriod.search(params[:q])
      @educational_periods = @search.result.page(params[:page]).per(20)
    end
    respond_with(@educational_period, location: new_educational_period_url)
  end

  def update
    unless @educational_period.update(educational_period_params)
      @search = EducationalPeriod.search(params[:q])
      @educational_periods = @search.result.page(params[:page]).per(20)
    end
    respond_with(@educational_period, location: new_educational_period_url)
  end

  def destroy
    @educational_period.destroy
    respond_with(@educational_period, location: new_educational_period_url)
  end

  private
    def set_educational_period
      @educational_period = EducationalPeriod.find(params[:id])
    end

    def educational_period_params
      params.require(:educational_period).permit(:name, :description, :internal_order, :start_date, :end_date)
    end
end
