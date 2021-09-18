class EducationalAsignature < ActiveRecord::Base
  has_many :teacher_asignatures
  has_many :student_progresses
  has_many :educational_performances
  has_many :educational_asignatures
  belongs_to :educational_area

  validates :educational_area_id, :name,  presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
