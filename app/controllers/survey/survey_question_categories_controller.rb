#app/controllers/survey_question_categories_controller.rb

module Survey
	class SurveyQuestionCategoriesController < ApplicationController
		before_filter :redirect_unless_admin
    
		unloadable #marks the class for reloading inbetween requests.

    def index
      @title = "Survey Question Categories"
      @survey_question_categories = SurveyQuestionCategory.all

      respond_to do |format|
        format.js { @set_id = params[:id] }
      end
    end

    def new
      @title = "Add Survey Question Categories"
      @survey_question_category = SurveyQuestionCategory.new
    end

    def create
      @survey_question_category =  SurveyQuestionCategory.new( params[:survey_question_category] )
      @facebox_id = params[:facebox_id]

      if @survey_question_category.save
        flash[:notice] = "Survey Question Category created successfully!"
        respond_to do |format|
          format.js {render :js => "window.location = '" + request.referer + "';"}
        end
      else
        @title = "Add Survey Question Categories"
        respond_to do |format|
          format.js { render 'new' }
        end
      end

    end

    def edit
      @title = "Edit Survey Question Categories"
      @survey_question_category = SurveyQuestionCategory.find( params[:id] )
    end

    def update
      @survey_question_category = SurveyQuestionCategory.find( params[:id] )

      if @survey_question_category.update_attributes( params[:survey_question_category] )
        flash[:notice] = "Survey Question Category updated successfully!"
        redirect_to survey_question_categories_path
      else
        @title = "Edit Survey Question Categories"
        render 'edit'
      end

    end

    def get_conditions_form
      respond_to do |format|
        format.js
      end
    end

	end
end
