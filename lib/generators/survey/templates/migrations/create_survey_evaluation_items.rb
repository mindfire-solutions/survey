class CreateSurveyEvaluationItems < ActiveRecord::Migration
  def change
    create_table :survey_evaluation_items do |t|
      t.integer :parent_id
      t.integer :evaluation_id
      t.integer :question_id
      t.integer :question_set_item_id
      t.text :answer_text
      t.integer :level

      t.timestamps
    end
  end
end
