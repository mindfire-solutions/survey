#app/controllers/survey_questions_controller.rb

module Survey
	class SurveyQuestionsController < ApplicationController
		before_filter :require_categories, :only => [:new, :edit]
		before_filter :add_class
    before_filter :redirect_unless_logged_in
    before_filter :redirect_unless_admin, :except => :get_questions
		
		unloadable #marks the class for reloading inbetween requests.

    def index
      @title = "Survey Questions"
      @survey_questions = SurveyQuestion.all
      @survey_question_categories = Survey::SurveyQuestionCategory.all
      respond_to do |format|
        format.json { render :json => SurveyQuestion.where( 'published = ?', true) }
        format.html
      end
    end

    def show
      @title = "Survey Question"
      @survey_question = SurveyQuestion.find( params[:id] )

    end

    def new
      @title = "Add Survey Question"
      @survey_question = SurveyQuestion.new
    end

    def create
      @survey_question = SurveyQuestion.new( params[:survey_question] )

      if @survey_question.save
        flash[:notice] = "New Survey Question created successfully!"
        respond_to do |format|
          format.js {render :js => "window.location = '" + survey_questions_path + "';"}
        end
      else
        @title = "Add Survey Question"
        @categories = SurveyQuestionCategory.find( :all, :order => :title)
        @facebox_id = params[:facebox_id]
        respond_to do |format|
          format.js { render 'new' }
        end
      end

    end

    def edit
      @title = "Edit Survey Question"
      @survey_question = SurveyQuestion.find( params[:id] )

      respond_to do |format|
        format.js
        format.html
      end
    end

    def update
      @survey_question = SurveyQuestion.find( params[:id] )

      if @survey_question.published
        @survey_question = SurveyQuestion.new( params[:survey_question] )
        if @survey_question.save
          success
        else
          failure
        end
      else
        if @survey_question.update_attributes( params[:survey_question] )
          success
        else
          failure
        end
      end

    end

    def destroy
      @survey_question = SurveyQuestion.find( params[:id] )
      @survey_question.destroy

      flash[:notice] = "Survey Question destroyed successfully!"
      redirect_to survey_questions_path
    end

    def validations
      @validations = SurveyValidation.all
      render :partial => "validations", :locals => { :validations => @validations }
    end

    def get_questions
      @item = params[:item]
      if params[:category] == "all"
        if @item.nil?
          @survey_questions = SurveyQuestion.where( 'published = ?', true )
          @survey_question_sets = SurveyQuestionSet.where( 'published = ? AND question_set_type = ?', true, "Sub-assembly" )
        else
          if @item == 'survey_question'
            @survey_questions = SurveyQuestion.all
          elsif @item == 'survey_question_set'
            @survey_question_sets = SurveyQuestionSet.all
          else
            @survey_question_sets = SurveyQuestionSet.where( 'published = ? AND question_set_type = ?', true, "Assembly" )
          end
        end
      else
        categories = SurveyQuestionCategory.find(params[:category]).descendants
        categories << params[:category]
        if @item.nil?
          @survey_questions = SurveyQuestion.find( :all, :conditions => ["published = ? AND question_category_id IN (?)", true, categories] )
          @survey_question_sets = SurveyQuestionSet.find( :all, :conditions => ["published = ? AND question_set_type = ? AND question_category_id IN (?)", true, "Sub-assembly", categories] )
        else
          if @item == 'survey_question'
            @survey_questions = SurveyQuestion.find( :all, :conditions => ["question_category_id IN (?)", categories] )
          elsif @item == 'survey_question_set'
            @survey_question_sets = SurveyQuestionSet.find( :all, :conditions => ["question_category_id IN (?)", categories] )
          else
            @survey_question_sets = SurveyQuestionSet.find( :all, :conditions => ["published = ? AND question_set_type = 'Assembly' AND question_category_id IN (?)", true, categories] )
          end
        end
      end

      unless params[:id].nil?
        if params[:id] == '0'
          @survey_question_set = SurveyQuestionSet.new
        else
          @survey_question_set = SurveyQuestionSet.find(params[:id])
        end
      end

      respond_to do |format|
        format.js
      end
    end

    private

      def require_categories
        @categories = SurveyQuestionCategory.find( :all, :order => :title)

        if @categories.empty?
          flash[:error] = "There is no question category in database. Please add a category first!"
          redirect_to new_survey_question_category_path
        end
      end

      def success
        flash[:notice] = "Survey Question updated successfully!"
        respond_to do |format|
          format.js {render :js => "window.location = '" + survey_questions_path + "';"}
        end
      end

      def failure
        @title = "Edit Survey Question"
        @categories = SurveyQuestionCategory.find( :all, :order => :title)
        @facebox_id = params[:facebox_id]
        respond_to do |format|
          format.js {render 'edit'}
        end
      end

      def add_class
        @html_class = "survey_questions"
      end

	end
end
