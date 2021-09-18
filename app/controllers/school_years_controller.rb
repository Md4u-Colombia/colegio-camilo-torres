class SchoolYearsController < ApplicationController
  load_and_authorize_resource :except => [:create]
  before_action :set_school_year, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @school_years = SchoolYear.order("name")
    @search = @school_years.search(params[:q])
    @school_years = @search.result.page(params[:page]).per(30)
    respond_with(@school_years)
  end

  def show
    respond_with(@school_year)
  end

  def new
    @school_years = SchoolYear.order("name")
    @search = @school_years.search(params[:q])
    @school_years = @search.result.page(params[:page]).per(30)

    @school_year = SchoolYear.new
    respond_with(@school_year)
  end

  def edit
    @school_years = SchoolYear.order("name")
    @search = @school_years.search(params[:q])
    @school_years = @search.result.page(params[:page]).per(30)
  end

  def create
    @school_years = SchoolYear.order("name")
    @search = @school_years.search(params[:q])
    @school_years = @search.result.page(params[:page]).per(30)
    @school_year = SchoolYear.new(school_year_params)
    @school_year.save
    respond_with(@school_year, :location => new_school_year_url)
  end

  def update
    @school_years = SchoolYear.order("name")
    @search = @school_years.search(params[:q])
    @school_years = @search.result.page(params[:page]).per(30)
    @school_year.update(school_year_params)
    respond_with(@school_year, :location => new_school_year_url)
  end

  def destroy
    @school_years = SchoolYear.order("name")
    @search = @school_years.search(params[:q])
    @school_years = @search.result.page(params[:page]).per(30)
    @school_year.destroy
    respond_with(@school_year)
  end

  private
    def set_school_year
      @school_year = SchoolYear.find(params[:id])
    end

    def school_year_params
      params.require(:school_year).permit(:name, :description, :date_begin, :date_end)
    end
end