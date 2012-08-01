#app/models/survey/survey_validation.rb

module Survey
	class SurveyValidation < ActiveRecord::Base
		set_table_name "survey_validations"

		attr_accessible :title, :param_1_caption, :param_2_caption

		has_many :survey_question_validations, :foreign_key => :validation_id
		has_many :questions, :class_name => "SurveyQuestion", :through => :survey_question_validations
		has_many :condition_validations, :class_name => "SurveyQuestionSetItemConditionValidation",
						 :foreign_key => :condition_id
		has_many :item_conditions, :class_name => "SurveyQuestionSetItemCondition", :through => :condition_validations

		validates :title, :presence => true, :length => { :maximum => 50 }
		#validates :param_1_caption, :presence => true
		#validates :param_2_caption, :presence => true
	end
end
