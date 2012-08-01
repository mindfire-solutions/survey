#app/models/survey/survey_evaluation_item.rb

module Survey
	class SurveyEvaluationItem < ActiveRecord::Base
		set_table_name "survey_evaluation_items"

		attr_accessible :parent_id, :evaluation_id, :question_id, :answer_text, :level, :children_attributes
		attr_accessible :question_set_item_id

		belongs_to	:evaluation, :class_name => "SurveyEvaluation", :foreign_key => :evaluation_id

		has_many 		:children, :class_name => "SurveyEvaluationItem", :dependent => :destroy, :foreign_key => "parent_id"
		belongs_to 	:parent, :class_name => "SurveyEvaluationItem"

		belongs_to 	:question, :class_name => "SurveyQuestion", :foreign_key => :question_id
		belongs_to	:set_item, :class_name => "SurveyQuestionSetItem", :foreign_key => :question_set_item_id

		accepts_nested_attributes_for :children, :reject_if => proc { |attributes| attributes['answer_text'].blank? }

		validates :question_id, :presence => true
		validates :answer_text, :presence => true
		validates :level, :presence => true
		validate :validate_question

		before_save :add_evaluation_id

		def validate_question
			x = true
			if question.question_type == "Text Box"
				question.survey_question_validations.each do |ques_val|
					validation = ques_val.validation
					validation_method = validation.title
					validation_params = []
					validation_params << answer_text
					validation_params << ques_val.validation_param_1 unless validation.param_1_caption.nil?
					validation_params << ques_val.validation_param_2 unless validation.param_2_caption.nil?
			
					unless self.send validation_method, validation_params
						x = false
						errors.add( :answer_text, "Invalid entry!")
					end
				end
			end
			x
		end

		def is_not_blank?( param_list )
			input_text = param_list[0]
			!input_text.blank?
		end

		def is_number?( param_list )
			input_text = param_list[0]
			begin
		  	Float( input_text )
			rescue
		  	false # not numeric
			else
		  	true # numeric
			end
		end

		def range( param_list )
			input_text = param_list[0]
			range_from = param_list[1].to_i
			range_to	 = param_list[2].to_i
			input_text.length > range_from && input_text.length < range_to
		end

		def max_char( param_list )
			input_text = param_list[0]
			size = param_list[1].to_i
			input_text.length <= size
		end

		def equal_to( param_list )
			input_text = param_list[0]
			compare_to = param_list[1]

			input_text == compare_to
		end

		def not_equal_to( param_list )
			input_text = param_list[0]
			compare_to = param_list[1]

			input_text != compare_to
		end

		def greater_than( param_list )
			input_text = param_list[0]
			compare_to = param_list[1]

			input_text > compare_to
		end

		def greater_than_equal_to( param_list )
			input_text = param_list[0]
			compare_to = param_list[1]

			input_text >= compare_to
		end

		def less_than( param_list )
			input_text = param_list[0]
			compare_to = param_list[1]

			input_text < compare_to
		end

		def less_than_equal_to( param_list )
			input_text = param_list[0]
			compare_to = param_list[1]

			input_text <= compare_to
		end

		private

			def add_evaluation_id
				self.parent_id = 0 if parent.nil?

				if evaluation.blank? && !parent.nil?
					self.evaluation_id = parent.evaluation_id
				end
			end

	end
end
