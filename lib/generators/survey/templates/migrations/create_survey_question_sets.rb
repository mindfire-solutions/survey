class CreateSurveyQuestionSets < ActiveRecord::Migration
  def change
    create_table :survey_question_sets do |t|
    	t.integer :question_category_id
      t.string :title
      t.string :question_set_type
      t.string :version
      t.boolean :published
      t.boolean :active

      t.timestamps
    end
  end
end
