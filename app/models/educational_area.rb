class EducationalArea < ActiveRecord::Base
  validates :education_level_id, presence: true
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  belongs_to :education_level
  has_many :educational_asignatures
end
