class TeacherAsignature < ActiveRecord::Base
	validates :teacher_id, presence: true
	validates :sub_grade_id, presence: true
	validates :educational_asignature_id, presence: true
	validate :exist_row #, :on => :create
	
	belongs_to :teacher, :class_name => "User", :foreign_key => "teacher_id"
	belongs_to :sub_grade
	belongs_to :educational_asignature
	has_many :period_notes_details
	belongs_to :sub_grade_teacher

	def exist_row
		if(TeacherAsignature.exists?(:teacher_id => self.teacher_id, :sub_grade_id => self.sub_grade_id, :educational_asignature_id => self.educational_asignature_id))
			errors.add(:teacher_id)
		end
	end
end
