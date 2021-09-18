class GradeAsignature < ActiveRecord::Base
	validates :school_year_id, :educational_asignature_id,:grade_id,:internal_order, presence: true

	validates :educational_asignature_id, uniqueness: {scope: [:grade_id, :school_year_id], :message => ' ya se encuentra asignada.'}

	has_many :student_progresses
	belongs_to :educational_asignature
	belongs_to :grade
	belongs_to :school_year
end
