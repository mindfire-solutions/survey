#app/models/survey/survey_question_set_item_condition_validation.rb

module Survey
	class SurveyQuestionSetItemConditionValidation < ActiveRecord::Base
		set_table_name "survey_question_set_item_condition_validations"

		attr_accessible :condition_id, :validation_id, :validation_param_1, :validation_param_2

		belongs_to :item_condition, :class_name => "SurveyQuestionSetItemCondition", :foreign_key => :condition_id
		belongs_to :item_validation, :class_name => "SurveyValidation", :foreign_key => :validation_id

		validates :item_condition, :presence => true
		validates :validation_id, :presence => true
		validates :validation_param_1, :presence=> true, :unless => Proc.new { |a| a.item_validation.param_1_caption.nil? }
		validates :validation_param_2, :presence => true, :unless => Proc.new { |a| a.item_validation.param_2_caption.nil? }

	end
end
