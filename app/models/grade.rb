class Grade < ActiveRecord::Base
	validates :education_level_id, presence: true
	validates :name, presence: true
	validates :name, uniqueness: true

	belongs_to :education_level
	has_many :sub_grades
	has_many :educational_asignatures

  def get_education_level_of_grade
    "#{education_level.name} / #{name}".html_safe
  end
end
