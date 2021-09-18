class ScoreDetail < ActiveRecord::Base
  validates :name, :sd_detail_id, :sub_grade_teacher_id, :weight, presence: true
end
