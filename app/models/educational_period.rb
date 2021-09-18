class EducationalPeriod < ActiveRecord::Base
  validates :name, :internal_order, :start_date, :end_date, presence: true
  validates :name, :internal_order, :start_date, :end_date, uniqueness: true
  validates :internal_order, numericality: { only_integer: true }

  has_many :period_notes_details
  has_many :student_progresses
end
