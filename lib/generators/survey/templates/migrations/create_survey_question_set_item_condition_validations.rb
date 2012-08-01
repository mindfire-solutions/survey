class CreateSurveyQuestionSetItemConditionValidations < ActiveRecord::Migration
  def change
    create_table :survey_question_set_item_condition_validations do |t|
      t.integer :condition_id
      t.integer :validation_id
      t.string :validation_param_1
      t.string :validation_param_2

      t.timestamps
    end
  end
end
