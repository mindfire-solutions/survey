module Survey
	module ApplicationHelper

		# Return a title on a page
    def title
      base_title = "Mindfire Survey"
      if @title.nil?
        base_title
      else
        "#{@title} | #{base_title}"
      end
    end

    #return the logo of the app
    def logo
      image_tag( "rails.png", :alt => "Survey", :class => "round" )
    end

    #return the validations list
    def setup_question

      ( SurveyValidation.all - @survey_question.validations ).each do |validation|
        @survey_question.survey_question_validations.build(:validation => validation)
      end

      @survey_question.selections.build if @survey_question.selections.nil?
      @survey_question
      #question/tmp/clean-controllers.md.html
    end

    def evaluate_sets( set, return_string = "", level = 1 )
      return_string += '<ul class="hierarchy">'
      set.items.each do |item|
        return_string += '<li>'
        return_string += evaluate_item(item, level)
        return_string += '</li>'
      end
      return_string += '</ul>'
    end

    def evaluate_ref(evaluation_id, item)
      eval_item = item.evaluation_items.find_by_evaluation_id(evaluation_id)
      return_string = ''
      
      unless eval_item.blank?
        eval_item.children.each do |child|
          return_string += '<ul class="reference">'
          return_string += '<li>'
          
          if child.set_item
            return_string += evaluate_item(child.set_item, child.level, eval_item)
          else
            return_string += evaluate_item(child.question, child.level, eval_item)
          end
          
          return_string += '</li>'
          return_string += '</ul>'
        end
      end
      return return_string
    end

    def evaluate_item(item, level, parent_item = nil)
      return_string = ''

      if item.class.name == "Survey::SurveyQuestion"
      	item_id = parent_item.question_set_item_id.to_s + '_opt'
      	item_id += parent_item.answer_text.gsub(',', '-') + '_q' + item.id.to_s
        return_string += '<span class="title item_'+item_id+'">' + hidden_field_tag("item_id", item_id)
        return_string += hidden_field_tag("question_id", item.id)
        return_string += hidden_field_tag("level", level)
        return_string += hidden_field_tag("object", @object) unless @object.nil?
        return_string += item.text + '</span>'
      elsif item.question_reference_type == "Survey::SurveyQuestionSet"
        return_string += '<span class="expand_or_collapse">'
        return_string +=		'<span class="expand">[+]</span>'
        return_string +=		'<span class="collapse">[-]</span>'
        return_string +=	'</span>'
        return_string +=  '<span class="title">' + item.question_reference.title.to_s + '</span>'
        return_string += evaluate_sets( item.question_reference, '', level )
      else
        return_string += '<span class="title item_'+item.id.to_s+'">' + hidden_field_tag( "item_id", item.id )
        return_string += hidden_field_tag( "level", level )
        return_string += hidden_field_tag( "object", @object ) unless @object.nil?
        return_string += item.question_reference.text.to_s + '</span>'

        return_string += evaluate_ref(@survey_evaluation.id, item) if @survey_evaluation
      end

      return return_string
    end
	end
end
