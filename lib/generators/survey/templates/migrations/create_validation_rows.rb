class CreateValidationRows < ActiveRecord::Migration
  def up
  	Survey::SurveyValidation.create :title => "is_not_blank?"
  	Survey::SurveyValidation.create :title => "is_number?"
  	Survey::SurveyValidation.create :title => "range", :param_1_caption => "From", :param_2_caption => "To"
  	Survey::SurveyValidation.create :title => "max_char", :param_1_caption => "Size"
  	Survey::SurveyValidation.create :title => "equal_to", :param_1_caption => "Compared To"
  	Survey::SurveyValidation.create :title => "not_equal_to", :param_1_caption => "Compared To"
  	Survey::SurveyValidation.create :title => "greater_than", :param_1_caption => "Compared To"
  	Survey::SurveyValidation.create :title => "greater_than_equal_to", :param_1_caption => "Compared To"
  	Survey::SurveyValidation.create :title => "less_than", :param_1_caption => "Compared To" 
  	Survey::SurveyValidation.create :title => "less_than_equal_to", :param_1_caption => "Compared To" 
  end

  def down
  	execute "TRUNCATE TABLE `survey_validations`"
  end
end
