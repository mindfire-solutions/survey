class CreateSurveyQuestionSelections < ActiveRecord::Migration
  def change
    create_table :survey_question_selections do |t|
      t.integer :question_id
      t.string :text

      t.timestamps
    end
  end
end
