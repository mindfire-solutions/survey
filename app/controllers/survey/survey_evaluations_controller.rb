#app/controllers/survey_evaluations_controller.rb

module Survey
	class SurveyEvaluationsController < ApplicationController
		before_filter :add_class
		before_filter :redirect_unless_logged_in

		unloadable #marks the class for reloading inbetween requests.

    def index
      @survey_question_sets = SurveyQuestionSet.where( "published = ? AND question_set_type = ?", true, 'Assembly')
      @survey_question_categories = SurveyQuestionCategory.all
    end

    def create
      @survey_question_set = SurveyQuestionSet.find( params[:question_set_id] )
      @survey_evaluation = @survey_question_set.evaluations.create!( {:status => params[:status], :user_id => current_user.id} )

      render :edit
    end

    def edit
      @survey_evaluation = SurveyEvaluation.find( params[:id] )
      @survey_question_set = @survey_evaluation.question_set

      respond_to do |format|
        format.js
        format.html
      end
    end

    def update
      @survey_evaluation = SurveyEvaluation.find( params[:id] )

      if @survey_evaluation.update_attributes( params[:survey_evaluation] )
        flash[:notice] = "Survey Evaluation updated successfully!"
        redirect_to survey_evaluations_path
      else
        @survey_evaluation = SurveyEvaluation.find( params[:id] )
        @survey_question_set = @survey_evaluation.question_set
        render 'edit'
      end
    end

    def destroy
      @survey_evaluation = SurveyEvaluation.find( params[:id] )
      @survey_evaluation.destroy
      flash[:notice] = "Survey Evaluation successfully destroyed!"
      redirect_to survey_evaluations_path
    end

    def evaluate_question
      items = params[:item_id].include?('_') ? nil : SurveyQuestionSetItem.where(:id => params[:item_id])
      @level = params[:level] ? params[:level] : 1
      @object = params[:object].nil? ? "survey_evaluation[evaluation_items_attributes]" : params[:object] + "[children_attributes]"
      @evaluation = SurveyEvaluation.find( params[:eval_id] ) if params[:eval_id]

      unless items.blank?
        @question_set_item = items.first
        if @question_set_item.question_reference_type == "Survey::SurveyQuestion"
          @question = @question_set_item.question_reference
        end

        if @evaluation
          @evaluation_item = @evaluation.evaluation_items.where('question_id = ? AND level = ? AND question_set_item_id = ?', @question.id, @level, @question_set_item.id ).first
        else
          @evaluation_item = SurveyEvaluationItem.where('question_id = ? AND level = ? AND question_set_item_id = ?',
                                                      @question.id, @level, @question_set_item.id ).first
        end
      end

      @question = SurveyQuestion.find( params[:question_id] ) if params[:question_id]
      @item_id = params[:item_id]

      if @evaluation_item.blank?
      	if @evaluation && params[:question_id]
      		@evaluation_item = @evaluation.evaluation_items
      			.where('question_id = ? AND level = ? AND question_set_item_id IS NULL',
      				 params[:question_id], @level ).first
      	else
        	@evaluation_item = SurveyEvaluationItem.new
        end
      end

      if @question.question_type == "Text Box"
        @question_validations = @question.survey_question_validations
      else
        @question_selections = @question.selections
      end

      respond_to do |format|
        format.js
      end

    end

    def add_condition_reference
      @question_set_item = SurveyQuestionSetItem.find( params[:item_id] )
      eval_item = SurveyEvaluationItem.new
      @conditions = []
      @level = params[:level].to_i + 1;
      @object = params[:object]
      @selected_value = params[:text].kind_of?(Array) ? params[:text].join('-') : params[:text]
      unless @question_set_item.nil?
        @valid = true
        @errors = []
        @question_set_item.item_conditions.each do |condition|
          if @question_set_item.question_reference.question_type == "Text Box"
            @param_list = []
            @param_list << params[:text]
            condition.condition_validations.each do |condition_val|
              @param_list << condition_val.validation_param_1 if condition_val.validation_param_1
              @param_list << condition_val.validation_param_2 if condition_val.validation_param_2
              validation_method = condition_val.item_validation.title
              unless eval_item.send validation_method, @param_list
                @errors << "error"
                @valid = false
              else
              	@errors = []
              	@valid = true
              end
            end
            if @valid
              @conditions << condition
            end
          
          elsif @question_set_item.question_reference.question_type != "Text Box(Date)"
          	selections = []
            condition.condition_selections.each do |condition_selection|
              selections << condition_selection.selection_id.to_s
            end
            
            if params[:text].kind_of?(Array)
              @size = params[:text].join(',')
              unless selections.sort! == params[:text].sort!
                @errors << "error"
                @valid = false
              else
              	@errors = []
              	@valid = true
              end
            else
            	puts selections.inspect
            	puts '###'+params[:text]
              unless selections.include?(params[:text])
                @errors << "error"
                @valid = false
              else
              	@errors = []
              	@valid = true
              end
            end
            if @valid
              @conditions << condition
            end
          end
        end

      end
    end

    def get_evaluations
      @survey_question_set = SurveyQuestionSet.find(params[:set_id])
      @evaluations = @survey_question_set.evaluations.where('user_id = ?', current_user.id)

      respond_to do |format|
        format.js
      end
    end

    private

      def add_class
        @html_class = "survey_evaluation"
      end
  end
end
