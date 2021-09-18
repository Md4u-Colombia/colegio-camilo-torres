class EducationalPerformancesList < ActiveRecord::Base
  # attr_accessor :perform_validation_grade_id, :perform_validation_educational_asignature_id
  belongs_to :grade
  
  # validate :perform_validation_of_field
  validates :description, :grade_id, presence: true

  validates_uniqueness_of :grade_id, scope: :description, message: "El desempeño ya ha sido creado para el grado y la asignatura escogida"

  # def perform_validation_of_field
  #   if self.perform_validation_grade_id
  #     errors.add(:grade_asignature_id, " Grado es requerido")      
  #   end

  #   if self.perform_validation_educational_asignature_id
  #     errors.add(:grade_asignature_id, " Asignatura es requerido")      
  #   end
  # end

  # validates_each :grade_id, :educational_asignature_id do |record, attr, value|
  #   puts "****************value: #{value} grade_id: #{grade_id}"
  #   record.errors.add attr, "starts with z.#{value[0]}" if value.blank?
  # end
end
