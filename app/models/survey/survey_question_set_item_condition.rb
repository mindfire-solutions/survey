#app/models/survey/survey_question_set_item_condition.rb

module Survey
	class SurveyQuestionSetItemCondition < ActiveRecord::Base
		set_table_name "survey_question_set_item_conditions"

		attr_accessible :question_set_item_id, :reference_type, :title, :reference_id, :question_set_item,
										:survey_question, :reference, :condition_validations_attributes,
										:condition_selections_attributes, :validation

		belongs_to :question_set_item, :class_name => "SurveyQuestionSetItem",
							 :foreign_key => :question_set_item_id
		belongs_to :reference, :polymorphic => true

		has_many	 :condition_validations, :class_name => "SurveyQuestionSetItemConditionValidation",
							 :dependent => :destroy, :foreign_key => :condition_id, :inverse_of => :item_condition
		has_many	 :validations, :class_name => "SurveyValidation", :through => :condition_validations

		has_many	 :condition_selections, :class_name => "SurveyQuestionSetItemConditionSelection",
							 :dependent => :destroy, :foreign_key => :condition_id, :inverse_of => :item_condition
		has_many	 :selections, :class_name => "SurveyQuestionSelection", :through => :condition_selections

		accepts_nested_attributes_for :condition_validations, :allow_destroy => true
		accepts_nested_attributes_for :condition_selections, :allow_destroy => true,
																	:reject_if => proc { |attributes| attributes['selection_id'].blank? }

		validates :question_set_item, :presence => true
		validates :title, :presence =>true
		validates :reference_type, :presence =>true
		validates :reference_id, :presence => true
		validates :condition_validations, :presence => true,
							:if => :has_validations?
		validates :condition_selections, :presence => true,
						 	:if => :has_selections?
						 	
		validates_associated :condition_validations,
				 								 :if => :has_validations?
		validates_associated :condition_selections,
					 							 :if => :has_selections?
	
		private

			def has_validations?
				if self.question_set_item.question_reference_type == "SurveyQuestion"
					self.question_set_item.question_reference.question_type == "Text Box"
				else
					false
				end
			end
		
			def has_selections?
				if self.question_set_item.question_reference_type == "SurveyQuestion"
					ques_type = self.question_set_item.question_reference.question_type
					ques_type != "Text Box(Date)" && ques_type != "Text Box"
				else
					false
				end
			end
	end
end
