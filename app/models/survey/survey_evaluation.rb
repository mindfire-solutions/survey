#app/models/survey_evaluation.rb
module Survey
	class SurveyEvaluation < ActiveRecord::Base
		set_table_name "survey_evaluations"

		attr_accessible :question_set_id, :status, :user_id, :evaluation_items_attributes

		has_many :evaluation_items, :class_name => "SurveyEvaluationItem", :foreign_key => :evaluation_id

		belongs_to :question_set, :class_name => "SurveyQuestionSet", :foreign_key => :question_set_id
    belongs_to :user, :class_name => USER_RESOURCE

		accepts_nested_attributes_for :evaluation_items,
																	:reject_if => proc { |attributes| attributes['answer_text'].blank? }

		validates :question_set_id, :presence => true
		#validates :status, :presence => true, :inclusion => { :in => ['started', 'completed']}
		validates_associated :evaluation_items
	end
end
