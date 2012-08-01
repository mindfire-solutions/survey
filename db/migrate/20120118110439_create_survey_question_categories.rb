class CreateSurveyQuestionCategories < ActiveRecord::Migration
  def change
    create_table :survey_question_categories do |t|
      t.string :title
			t.integer :parent_id

      t.timestamps
    end
  end
end
