class PeriodNotesDetail < ActiveRecord::Base
	belongs_to :school_year
	belongs_to :teacher_asignature
	belongs_to :educational_performance
	belongs_to :sd_detail
	belongs_to :educational_period
	belongs_to :teacher, :class_name => "User", :foreign_key => "teacher_id"
	validate :exist_row #, :on => :create

	validates :school_year_id,:educational_period_id,:period_weight,:teacher_asignature_id,:educational_performance_id,:performance_weight,:sd_detail_id,:detail_weight, presence: true
	
	def exist_row
		if(PeriodNotesDetail.exists?(:teacher_id => self.teacher_id,:educational_period_id => self.educational_period_id,:sd_detail_id => self.sd_detail_id, :educational_performance_id => self.educational_performance_id))
			errors.add(:teacher_id)
		end
	end
end
