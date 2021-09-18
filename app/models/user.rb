require 'role_model'
class User < ActiveRecord::Base

  has_attached_file :avatar, styles: { small: '100x100#', large: '500x500>' }, processors: [:cropper], default_url: :set_default_url_on_gender
  validates_attachment :avatar, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  #after_update :reprocess_avatar, :if => :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  def set_default_url_on_gender
    if self.gender == 1
      '/avatars/:style/missing-boy.png'
    elsif self.gender == 0
      '/avatars/:style/missing-girl.png'
    else
      '/avatars/:style/missing-boy.png'
    end
  end

  belongs_to :position
  belongs_to :company
  belongs_to :area
  belongs_to :group
  belongs_to :localization
  belongs_to :business_unite
  belongs_to :country
  belongs_to :city
  belongs_to :role
  belongs_to :period_notes_detail


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
  attr_accessor :login

  validates :role_id,:name,:last_name,:gender,:username,:email,:encrypted_password,:identity, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format: { :with => VALID_EMAIL_REGEX}

  # Validamos que el identificador solo sea numerico
  validates :identity, numericality: { only_integer: true}
  # Validamos que el identificador tenga entre 8 a 12 caracteres
  validates :identity, length: { in: 8..20 }
  # Validamos que el identification sea unico
  #validates :identity, uniqueness: {case_sensitive: false}
  
  #validates :encrypted_password, length: { in: 8..20 , message: "debe tener entre 8 y 20 caracteres"}
  # Validamos que el email sea unico
  #validates :email, uniqueness: {case_sensitive: false}
  # Validamos que el username sea unico
  #validates :username, uniqueness: {case_sensitive: false}

  devise :database_authenticatable,
  :recoverable, :rememberable, :trackable, :validatable,
  :authentication_keys => [:username]
  #:registerable,

  include RoleModel

  roles_attribute :role_id
  roles :superadmin, :admin, :teacher, :student

  #NOMBRE COMPLETO (NOMBRES, APELLIDOS)
  def complete_name
    name.split(' ').each{|word| word.capitalize!}.join(' ') + ' ' + last_name.split(' ').each{|word| word.capitalize!}.join(' ')
  end
  #NOMBRE COMPLETO (APELLIDO, NOMBRE)
  def reverse_complete_name
    last_name.split(' ').each{|word| word.capitalize!}.join(' ') + ' ' + name.split(' ').each{|word| word.capitalize!}.join(' ')
  end

  private

  def reprocess_avatar
    avatar.reprocess!
  end
end
