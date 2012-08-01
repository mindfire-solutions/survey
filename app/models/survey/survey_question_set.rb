#app/models/survey/survey_question_set.rb

module Survey
	class SurveyQuestionSet < ActiveRecord::Base
		set_table_name "survey_question_sets"

		attr_accessible :title, :version, :published, :active
		attr_accessible :question_set_type, :question_category_id, :items_attributes
		#include CommonFunctions

		belongs_to :category, :class_name => "SurveyQuestionCategory", :foreign_key => "question_category_id"
	
		has_many :items, :class_name => "SurveyQuestionSetItem", :foreign_key => :question_set_id,
						 :inverse_of => :question_set

		has_one  :question_set_items, :class_name => "SurveyQuestionSetItem",
						 :foreign_key => :question_reference_id, :as => :question_reference

		has_many :item_conditions, :class_name => "SurveyQuestionSetItemCondition", :as => :reference
		has_many :set_items, :class_name => "SurveyQuestionSetItems",
						 :through => :item_conditions

		has_many :evaluations, :class_name => "SurveyEvaluation", :foreign_key => :question_set_id

		accepts_nested_attributes_for :items, :allow_destroy => true,
																	:reject_if => proc { |attributes| attributes['question_reference_id'].blank? }

		validates :title, :presence => true, :uniqueness => { :scope => :version,
        :case_sensitive => false }
		validates	:question_set_type, :presence => true, :inclusion => { :in => ['Assembly', 'Sub-assembly'] }
		validates	:version, :presence => true
		validates :question_category_id, :presence => true
		#validates :published, :presence => true
		#validates :active, :presence => true
		validates :items, :presence => { :presence => true, :message => "Choose atleast one QuestionSet Item." }
		validates_associated :items

		before_validation :add_version
		after_initialize  :set_default_values

		def title_with_version
			"#{title} (#{version})"
		end
		
		def add_version
			obj = Survey::SurveyQuestionSet.where( "title = ?", self.title ).order("version DESC").first

			if obj.nil?
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
