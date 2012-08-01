#app/models/survey_question.rb
module Survey
	class SurveyQuestion < ActiveRecord::Base
		set_table_name "survey_questions"

		attr_accessible :text, :question_category_id, :question_type, :version, :published, :active,
										:survey_question_validations_attributes, :selections_attributes
		#include Version

		belongs_to :category, :class_name => "SurveyQuestionCategory", :foreign_key => "question_category_id"

		has_many 	 :question_set_items, :class_name => "SurveyQuestionSetItem",
							 :foreign_key => :question_reference_id, :as => :question_reference

		has_many	 :survey_question_validations, :foreign_key => :question_id, :dependent => :destroy,
						 	 :validate => true
		has_many 	 :validations, :class_name => "SurveyValidation", :through => :survey_question_validations

		has_many 	 :selections, :class_name => "SurveyQuestionSelection", :foreign_key => :question_id,
						 	 :dependent => :destroy, :validate => true, :inverse_of => :question

		has_many	 :item_conditions, :class_name => "SurveyQuestionSetItemCondition", :as => :reference
		has_many	 :set_items, :class_name => "SurveyQuestionSetItems",
							 :through => :item_conditions

		has_many	 :evaluation_items, :class_name => "SurveyEvaluationItem", :foreign_key => :question_id

		accepts_nested_attributes_for :survey_question_validations, :allow_destroy => true
		accepts_nested_attributes_for :selections, :allow_destroy => true, :reject_if => :all_blank

		validates :text, :presence => true, :uniqueness => { :scope => :version, :case_sensitive => false }, :length => { :maximum => 100 }
      
		validates :question_type, :presence => true, :length => { :maximum => 20 }
		validates :version, :presence => true
		#validates :published, :presence => true
		#validates :active, :presence => true
		validates :question_category_id, :presence => true

		before_validation :set_default_values

		def title_with_version
			"#{text} (#{version})"
		end
	
		def add_version
			obj = SurveyQuestion.where( "text = ?", self.text ).order("version DESC").first
			
			if obj.blank?
			 self.version = '1.0.0'
			else
				if obj.published
					current_version = obj.version
					vrm = current_version.split '.'

					if vrm[2].to_i < 9
						vrm[2] = (vrm[2].to_i + 1).to_s
					else
						if vrm[1].to_i < 9
							vrm[1] = (vrm[1].to_i + 1).to_s
							vrm[2] = "0"
						else
							vrm[0, 1, 2] = [(vrm[0].to_i + 1).to_s, "0", "0"]
						end
					end

					self.version = vrm[0]+'.'+vrm[1]+'.'+vrm[2]
				else
					self.version = self.version
				end
			end

		end

		def set_default_values
			self.published = false if self.published.nil?
			self.active = false if self.active.nil?
		end

	end
end
