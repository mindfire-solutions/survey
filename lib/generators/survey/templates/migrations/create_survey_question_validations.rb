class CreateSurveyQuestionValidations < ActiveRecord::Migration
  def change
    create_table :survey_question_validations do |t|
      t.integer :question_id
      t.integer :validation_id
      t.string :validation_param_1
      t.string :validation_param_2

      t.timestamps
    end
  end
end
