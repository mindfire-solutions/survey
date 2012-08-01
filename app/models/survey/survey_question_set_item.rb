#app/models/survey/survey_question_set_item.rb

module Survey
	class SurveyQuestionSetItem < ActiveRecord::Base
		set_table_name "survey_question_set_items"

		attr_accessible :question_reference_type, :question_reference_id, :question_conditions, :item_conditions_attributes

		belongs_to :question_set, :class_name => "SurveyQuestionSet", :foreign_key => :question_set_id
		belongs_to :question_reference, :polymorphic => true

		has_many :item_conditions, :class_name => "SurveyQuestionSetItemCondition",
						 :dependent => :destroy,
						 :foreign_key => :question_set_item_id, :inverse_of => :question_set_item
		has_many :survey_questions, :class_name => "SurveyQuestion", :through => :item_conditions,
						 :source => :reference, :source_type => 1
		has_many :survey_question_sets, :through => :item_conditions, :source => :reference,
						 :source_type => 2

		has_many :evaluation_items, :class_name => "SurveyEvaluationItem",
						 :foreign_key => :question_set_item_id

		accepts_nested_attributes_for :item_conditions, :allow_destroy => true

		validates :question_set, :presence => true
		validates :question_reference_type, :presence => true,
							:inclusion => { :in => ["Survey::SurveyQuestion", "Survey::SurveyQuestionSet"] }
		validates :question_reference_id, :presence => true
		validates_associated :item_conditions

		before_validation :add_question_conditions
		#before_create :belongs_to_a_set

		private

			def belongs_to_a_set
				question_set.blank?
			end

			def add_question_conditions
				if self.question_reference_type == 'Survey::SurveyQuestion' and !self.item_conditions.blank?
					conditions_count = 0
					destroy_count = 0
					self.item_conditions.each do |cond|
						conditions_count += 1
						if cond._destroy
							destroy_count += 1
						end
					end
				
					if conditions_count == destroy_count
						self.question_conditions = false
					else
						self.question_conditions = true
					end
				else
					self.question_conditions = false
				end
				return true
			end

	end
end
