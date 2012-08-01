class CreateSurveyQuestionSetItems < ActiveRecord::Migration
  def change
    create_table :survey_question_set_items do |t|
			t.integer :question_set_id
      t.string :question_reference_type
      t.integer :question_reference_id
      t.boolean :question_conditions

      t.timestamps
    end
  end
end
