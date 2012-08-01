#app/controllers/survey_question_set_items_controller.rb

module Survey
	class SurveyQuestionSetItemsController < ApplicationController
    before_filter :redirect_unless_logged_in
    before_filter :redirect_unless_admin
    
		unloadable #marks the class for reloading inbetween requests.

    def index
      @title = "Survey Question Set Items"
      @survey_question_set_items = SurveyQuestionSetItem.all
    end

    def new
      @title = "Add Survey Question Set Item"
      @survey_question_set_item = SurveyQuestionSetItem.new
    end

    def create
      @survey_question_set_item = SurveyQuestionSetItem.new( params[:survey_question_set_item] )

      if @survey_question_set_item.save
        flash[:notice] = "Survey Question Set Item created successfully!"
        redirect_to survey_question_set_items_path
      else
        @title = "Add Survey Question Set Item"
        render 'new'
      end

    end

    def edit
      @title = "Edit Survey Question Set Item"
      @survey_question_set_item = SurveyQuestionSetItem.find( params[:id] )
    end

    def update
      @survey_question_set_item = SurveyQuestionSetItem.find( params[:id] )

      if @survey_question_set_item.update_attributes( params[:survey_question_set_item] )
        flash[:notice] = "Survey Question Set Item updated successfully!"
        redirect_to survey_question_set_items_path
      else
        @title = "Edit Survey Question Item"
        render 'edit'
      end
    end

    def destroy
      @survey_question_set_item = SurveyQuestionSetItem.find( params[:id] )
      @survey_question_set_item.destroy

      flash[:notice] = "Survey Question Set Item destroyed successfully!"
      redirect_to survey_question_set_items_path
    end

	end
end
