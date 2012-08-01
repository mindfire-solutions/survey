class CreateSurveyValidations < ActiveRecord::Migration
  def change
    create_table :survey_validations do |t|
      t.string :title
      t.string :param_1_caption
      t.string :param_2_caption

      t.timestamps
    end
  end
end
