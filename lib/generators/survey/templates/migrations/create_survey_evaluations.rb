class CreateSurveyEvaluations < ActiveRecord::Migration
  def change
    create_table :survey_evaluations do |t|
      t.integer :question_set_id
      t.text :reference_type
      t.integer :reference_id
      t.text :status
      t.integer :user_id

      t.timestamps
    end
  end
end
