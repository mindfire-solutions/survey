class CreateSurveyQuestionSetItemConditionSelections < ActiveRecord::Migration
  def change
    create_table :survey_question_set_item_condition_selections do |t|
      t.integer :condition_id
      t.integer :selection_id

      t.timestamps
    end
  end
end
