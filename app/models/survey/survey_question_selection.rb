#app/models/survey/survey_question_selection.rb

module Survey
	class SurveyQuestionSelection < ActiveRecord::Base
		set_table_name "survey_question_selections"

		attr_accessible :question_id, :text

		belongs_to :question, :class_name => "SurveyQuestion", :foreign_key => :question_id

		has_many :condition_selections, :class_name => "SurveyQuestionSetItemConditionSelection",
						 :foreign_key => :condition_id
		has_many :item_conditions, :class_name => "SurveyQuestionSetItemCondition", :through => :condition_selections
	
		validates :question, :presence => true
		validates :text, :presence => true
	end
end
