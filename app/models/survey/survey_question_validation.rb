#app/models/survey/survey_question_validation.rb

module Survey
	class SurveyQuestionValidation < ActiveRecord::Base
		set_table_name "survey_question_validations"

		attr_accessible :validation_param_1, :validation_param_2, :validation, :validation_id

		belongs_to :validation, :class_name => "SurveyValidation", :foreign_key => :validation_id
		belongs_to :question, :class_name => "SurveyQuestion", :foreign_key => :question_id, :conditions => "question_type = 'Text Box'"

		validates :validation_param_1, :length => { :maximum => 100 }
		validates :validation_param_2, :length => { :maximum => 100 }
	end
end
