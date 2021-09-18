class PositionLevelsController < ApplicationController
  load_and_authorize_resource :except => [:create]
  before_action :set_position_level, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @position_levels = PositionLevel.all
    respond_with(@position_levels)
  end

  def show
    respond_with(@position_level)
  end

  def new
    @position_level = PositionLevel.new
    respond_with(@position_level)
  end

  def edit
  end

  def create
    @position_level = PositionLevel.new(position_level_params)
    @position_level.save
    respond_with(@position_level)
  end

  def update
    @position_level.update(position_level_params)
    respond_with(@position_level)
  end

  def destroy
    @position_level.destroy
    respond_with(@position_level)
  end

  private
    def set_position_level
      @position_level = PositionLevel.find(params[:id])
    end

    def position_level_params
      params.require(:position_level).permit(:name)
    end
end
