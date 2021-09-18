class UsersController < ApplicationController
  load_and_authorize_resource :except => [:create, :import_data, :automatic_avatar]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def automatic_avatar
    @user = User.where("username = ?", params[:username])
    if @user.any?
      avatar_url = @user.first.avatar.url(:small)
    else
      avatar_url = ""
    end

    respond_to do |format|
      format.html { render text: avatar_url}
    end
  end

  # GET /users
  # GET /users.json

  def import_data
    if(params[:commit].to_s == "Importar")
      require 'csv'
      infile = params[:file].read
      n, errs = 0, []
      source_encoding = "UTF-8"
      CSV.parse(infile, encoding: source_encoding) do |row|
        n += 1
        next if n == 1 or row.join.blank?
        ok=0
        unless(row[2].nil?)
          if(User.exists?(:identity => row[2])) #ACTUALIZA EL USUARIO
            #NOMBRE DE USUARIO
            unless(row[0].nil?)
              tmp_name = row[0]
              User.update_attribute(:name, tmp_name)
            end
            #APELLIDO DE USUARIO
            unless(row[1].nil?)
              tmp_last_name = row[1]
              User.update_attribute(:last_name, tmp_last_name)
            end
            #GENERO
            unless(row[3].nil?)
              tmp_gender = row[3]
              User.update_attribute(:gender, tmp_gender)
            end
            #USERNAME
            unless(row[4].nil?)
              tmp_username = row[4]
              User.update_attribute(:username, tmp_username)
            end
            #CORREO
            unless(row[5].nil?)
              tmp_email = row[5]
              User.update_attribute(:email, tmp_email)
            end
            #CONTRASEÑA
            unless(row[6].nil?)
              tmp_encrypted_password = BCrypt::Password.create(row[6])
              User.update_attributes(:password, tmp_encrypted_password)
            end
            #GENERO
            unless(row[3].nil?)
              tmp_gender = row[3]
              User.update_attribute(:gender, tmp_gender)
            end
            #COMPAÑIA
            unless(row[7].nil?)
              tmp_company_id = row[7]
              User.update_attribute(:company_id, tmp_company_id)
            end
            #LOCALIZATION
            unless(row[9].nil?)
              tmp_localization_id = row[9]
              User.update_attribute(:localization_id, tmp_localization_id)
            end
            #PAIS
            unless(row[13].nil?)
              tmp_country_id = row[13]
              User.update_attribute(:country_id, tmp_country_id)
            end
            #CIUDAD
            unless(row[14].nil?)
              tmp_city_id = row[14]
              User.update_attribute(:city_id, tmp_city_id)
            end
            #ESTADO
            unless(row[15].nil?)
              tmp_status = row[15]
              User.update_attribute(:status, tmp_status)
            end
            #ROLE
            unless(row[16].nil?)
              tmp_role_id = row[16]
              User.update_attribute(:role_id, tmp_role_id)
            end
          else #CREA EL USUARIO
            tmp_name = ""
            tmp_last_name = ""
            tmp_gender = 0
            tmp_username = "nuevo_usuario"
            tmp_email = "nuevo_usuario@iecamilotorreszipa.edu.co"
            tmp_encrypted_password = BCrypt::Password.create(123456789)
            tmp_company_id = 0
            tmp_area_id = 0
            tmp_localization_id = 0
            tmp_position_id = 0
            tmp_group_id = 0
            tmp_business_unite_id = 0
            tmp_country_id = 1
            tmp_city_id = 1
            tmp_status = 1
            tmp_role_id = 3
            tmp_created_at = Time.now
            tmp_updated_at = Time.now
            #NOMBRE DE USUARIO
            unless(row[0].nil?)
              tmp_name = row[0]
            end
            #APELLIDO DE USUARIO
            unless(row[1].nil?)
              tmp_last_name = row[1]
            end
            #GENERO
            unless(row[3].nil?)
              tmp_gender = row[3]
            end
            #USERNAME
            unless(row[4].nil?)
              tmp_username = row[4]
            end
            #CORREO
            unless(row[5].nil?)
              tmp_email = row[5]
            end
            #CONTRASEÑA
            unless(row[6].nil?)
              tmp_encrypted_password = BCrypt::Password.create(row[6])
            end
            #COMPAÑIA
            unless(row[7].nil?)
              tmp_company_id = row[7]
            end
            #AREA
            unless(row[8].nil?)
              tmp_area_id = row[8]
            end
            #LOCALIZATION
            unless(row[9].nil?)
              tmp_localization_id = row[9]
            end
            #CARGO
            unless(row[10].nil?)
              tmp_position_id = row[10]
            end
            #GRUPO
            unless(row[11].nil?)
              tmp_group_id = row[11]
            end
            #UNIDAD DE NEGOCIO
            unless(row[12].nil?)
              tmp_business_unite_id = row[12]
            end
            #PAIS
            unless(row[13].nil?)
              tmp_country_id = row[13]
            end
            #CIUDAD
            unless(row[14].nil?)
              tmp_city_id = row[14]
            end
            #ESTADO
            unless(row[15].nil?)
              tmp_status = row[15]
            end
            #ROLE
            unless(row[16].nil?)
              tmp_role_id = row[16]
            end
            User.new(:name=>tmp_name, :last_name=>tmp_last_name,:username=>tmp_username, :email=>tmp_email.to_s, :password=>tmp_encrypted_password, :identity=>row[2], :gender=>tmp_gender, :since_date=>Time.now.strftime('%Y-%m-%d'), :company_id=>tmp_company_id, :area_id=>tmp_area_id, :localization_id=>tmp_localization_id, :position_id=>tmp_position_id, :group_id=>tmp_group_id, :business_unite_id=>tmp_business_unite_id, :country_id=>tmp_country_id, :city_id=>tmp_city_id, :status=>tmp_status,:role_id=>tmp_role_id).save
          end
        end
      end
      respond_to do |format|
        format.html { redirect_to users_url}
      end
    end
  end

  def change_password
    flash[:success] = ""
    flash[:error] = ""
    @user = User.find(params[:id])
    if(params[:commit].to_s == "Modificar")
      new_password = params[:change_password][:encrypted_password]
      if(new_password.to_s != "")
        if(new_password.length.to_i < 8)
          flash[:error] = "Su nueva contraseña debe contener mínimo 8 caracteres.".html_safe
        else
          new_password = BCrypt::Password.create(new_password.to_s)
            @user.update_attribute(:encrypted_password,new_password)
          flash[:success] = "Su contraseña a sido modificada exitosamente.".html_safe
        end
      else
        flash[:error] = "Digite nueva contraseña.".html_safe
      end
    end
    render :layout => false
  end

  def index
    @usersT = User.where("role_id <> 0").order("last_name")
    @searchT = @usersT.search(params[:q])
    @usersT = @searchT.result

    @users = User.where("role_id <> 0").order("last_name")
    @search = @users.search(params[:q])
    @users = @search.result.page(params[:page]).per(30)
    respond_with(@users)
  end

  # GET /users/1
  # GET /users/1.json
  def show

  end

  # GET /users/new
  def new
    @usersT = User.where("role_id <> 0").order("last_name")
    @searchT = @usersT.search(params[:q])
    @usersT = @searchT.result

    @users = User.where("role_id <> 0").order("last_name")
    @search = @users.search(params[:q])
    @users = @search.result.page(params[:page]).per(30)
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @usersT = User.where("role_id <> 0").order("last_name")
    @searchT = @usersT.search(params[:q])
    @usersT = @searchT.result

    @users = User.where("role_id <> 0").order("last_name")
    @search = @users.search(params[:q])
    @users = @search.result.page(params[:page]).per(30)
  end

  # POST /users
  # POST /users.json
  def create
    @usersT = User.where("role_id <> 0").order("last_name")
    @searchT = @usersT.search(params[:q])
    @usersT = @searchT.result

    @users = User.where("role_id <> 0").order("last_name")
    @search = @users.search(params[:q])
    @users = @search.result.page(params[:page]).per(30)
    @user = User.new(user_params)
    my_password = BCrypt::Password.create(params[:user][:password])
    @user.encrypted_password = my_password
    # respond_to do |format|
      if @user.save
        if params[:user][:avatar].blank?
          # format.html {
          if(!@user.crop_x.blank? && !@user.crop_y.blank? && !@user.crop_w.blank? &&  !@user.crop_h.blank?)
             @user.avatar.reprocess!
          end
          redirect_to new_user_path, notice: 'Usuario creado satisfactoriamente.'
          # } format.json { render :show, status: :created, location: new_user_path }
        else
          render action: "crop"
        end
      else
        # format.html {
        render :new
        # } format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    # end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @usersT = User.where("role_id <> 0").order("last_name")
    @searchT = @usersT.search(params[:q])
    @usersT = @searchT.result

    @users = User.where("role_id <> 0").order("last_name")
    @search = @users.search(params[:q])
    @users = @search.result.page(params[:page]).per(30)
    # respond_to do |format|
      if @user.update(user_params)
        if params[:user][:avatar].blank?
          # format.html {
          if(!@user.crop_x.blank? && !@user.crop_y.blank? && !@user.crop_w.blank? &&  !@user.crop_h.blank?)
             @user.avatar.reprocess!
          end
          redirect_to edit_user_path(@user.id), notice: 'Usuario actualizado satisfactoriamente.'
        # }
        # format.json { render :show, status: :ok, location: @user, :location => new_user_path }
        else
          render action: "crop"
        end
      else
        # format.html {
        render :edit
        # }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    # end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @usersT = User.where("role_id <> 0").order("last_name")
    @searchT = @usersT.search(params[:q])
    @usersT = @searchT.result

    @users = User.where("role_id <> 0").order("last_name")
    @search = @users.search(params[:q])
    @users = @search.result.page(params[:page]).per(30)
    @user.destroy
    respond_to do |format|
      format.html { redirect_to new_user_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :last_name, :username, :email, :password, :identity, :gender, :since_date, :company_id, :area_id, :localization_id, :position_id, :group_id, :business_unite_id, :country_id, :city_id, :status, :role_id, :avatar_file_name, :avatar, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :crop_x, :crop_y, :crop_h, :crop_w)
    end
end
