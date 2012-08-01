#app/models/survey/survey_question_set_item_condition_selection.rb

module Survey
	class SurveyQuestionSetItemConditionSelection < ActiveRecord::Base
		set_table_name "survey_question_set_item_condition_selections"

		attr_accessible :condition_id, :selection_id

		belongs_to :item_condition, :class_name => "SurveyQuestionSetItemCondition", :foreign_key => :condition_id
		belongs_to :selection, :class_name => "SurveyQuestionSelection", :foreign_key => :selection_id

		validates :item_condition, :presence => true
		validates :selection_id, :presence => true
	end
end
