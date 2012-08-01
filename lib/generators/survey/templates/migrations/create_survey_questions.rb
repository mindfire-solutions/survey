class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.string :text
      t.integer :question_category_id
      t.string :question_type
      t.string :version
      t.boolean :published
      t.boolean :active

      t.timestamps
    end
  end
end
