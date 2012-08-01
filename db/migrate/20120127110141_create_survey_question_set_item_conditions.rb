class CreateSurveyQuestionSetItemConditions < ActiveRecord::Migration
  def change
    create_table :survey_question_set_item_conditions do |t|
      t.integer :question_set_item_id
      t.string :title
      t.integer :reference_type
      t.integer :reference_id

      t.timestamps
    end
  end
end
