class EduperScoreDetail < ActiveRecord::Base
  belongs_to :educational_performance
  belongs_to :sd_detail
  belongs_to :sub_grade_teacher

  belongs_to :sub_grade_teacher

  validates :name, :educational_performance_grade_id,:sd_detail_id, :weight, presence: true

  validates :name, length: { maximum: 15 }
end
