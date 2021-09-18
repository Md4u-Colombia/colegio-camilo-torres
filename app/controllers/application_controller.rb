class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :except => [:automatic_avatar]
  before_action :set_locale

  include ApplicationHelper

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Usted no se encuentra autorizado para ejecutar esta accion"
    redirect_to root_path
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end
end
