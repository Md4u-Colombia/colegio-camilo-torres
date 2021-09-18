class AddOrderingToSubGrades < ActiveRecord::Migration
  def change
    add_column :sub_grades, :ordering, :integer, after: :description
  end
end
