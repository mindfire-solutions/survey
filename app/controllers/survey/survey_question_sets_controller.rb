#app/controllers/survey_question_sets_controller.rb

module Survey
	class SurveyQuestionSetsController < ApplicationController
		before_filter :add_class
		before_filter :require_categories, :only => [:new, :edit]
    before_filter :redirect_unless_logged_in
    before_filter :redirect_unless_admin

		unloadable #marks the class for reloading inbetween requests.

    def index
      @title = "Survey Question Sets"
      @survey_question_sets = SurveyQuestionSet.all
      @survey_question_categories = SurveyQuestionCategory.all
      respond_to do |format|
        format.html
        format.json  { render :json => SurveyQuestionSet.where( 'published = ?', true) }
      end
    end

    def show
      @title = "Survey Question Set"
      @survey_question_set = SurveyQuestionSet.find( params[:id] )
    end

    def new
      @title = "Add Survey Question Set"
      @survey_question_set = SurveyQuestionSet.new
      @survey_question_sets = SurveyQuestionSet.where( 'published = ? AND question_set_type = ?', true, "Sub-assembly" )
      @survey_questions = SurveyQuestion.where( 'published = ?', true )
    end

    def create
      @survey_question_set = SurveyQuestionSet.new( params[:survey_question_set] )

      if @survey_question_set.save
        flash[:notice] = "Survey Question Set created successfully!"
        respond_to do |format|
          format.js {render :js => "window.location = '"+survey_question_sets_path+"';"}
        end
      else
        @title = "Add Survey Question Set"
        @survey_question_sets = SurveyQuestionSet.where(  'published = ? AND question_set_type = ?', true, "Sub-assembly" )
        @survey_questions = SurveyQuestion.where( 'published = ?', true )
        @categories = SurveyQuestionCategory.find( :all, :order => :title)
        @facebox_id = params[:facebox_id]
        respond_to do |format|
          format.js { render 'update' }
        end
      end

    end

    def edit
      @title = "Edit Survey Question Set"
      @survey_question_set = SurveyQuestionSet.find( params[:id] )
      @survey_question_sets = SurveyQuestionSet.find( :all,
        :conditions => ['published = ? AND question_set_type = "Sub-assembly" AND id != ?', true, params[:id]] )
      @survey_questions = SurveyQuestion.where( 'published = ?', true )

      respond_to do |format|
        format.js
        format.html
      end
    end

    def update
      @survey_question_set = SurveyQuestionSet.find( params[:id] )
      if @survey_question_set.published
        @survey_question_set = SurveyQuestionSet.new( params[:survey_question_set] )
        if @survey_question_set.save
          success
        else
          failure
        end
      else
        items_count = 0
        destroy_count = 0

        params[:survey_question_set][:items_attributes].each do |key, item|
          if item[:question_reference_id]
            items_count += 1
            #if item[:_destroy] == "1"
              #destroy_count += 1
            #end
          end
        end

        #if items_count == destroy_count
        if items_count == 0
          @survey_question_set.errors.add( :items, "Choose atleast one Question Set Item.")
          failure
        else
          if @survey_question_set.update_attributes( params[:survey_question_set] )
            success
          else
            failure
          end
        end
      end

    end

    def destroy
      @survey_question_set = SurveyQuestionSet.find( params[:id] )
      @survey_question_set.destroy

      flash[:notice] = "Survey Question Set destroyed successfully!"
      redirect_to survey_question_sets_path
    end

    def get_question_sets
      @survey_question_sets = SurveyQuestionSet.where( 'published = ? AND question_set_type = ? AND id != ?', true, "Sub-assembly", params[:id] )

      respond_to do |format|
        format.js
      end

    end

    def add_condition
      @object = params[:object]
      @selected_question = SurveyQuestion.find( params[:question] )
      respond_to do |format|
        format.js
      end
    end

    private

      def success
        flash[:notice] = "Survey Question Set updated successfully!"
        respond_to do |format|
          format.js {render :js => "window.location = '"+survey_question_sets_path+"';"}
        end
      end

      def failure
        @title = "Edit Survey Question Set"
        @survey_question_sets = SurveyQuestionSet.find( :all, :conditions => ['published = ? AND question_set_type = "Sub-assembly" AND id != ?', true, params[:id]] )
        @survey_questions = SurveyQuestion.where( 'published = ?', true )
        @categories = SurveyQuestionCategory.find( :all, :order => :title)
        @facebox_id = params[:facebox_id]
        respond_to do |format|
          format.js
        end
      end

      def add_class
        @html_class = "survey_question_sets"
      end

      def require_categories
        @categories = SurveyQuestionCategory.find( :all, :order => :title)

        if @categories.empty?
          flash[:error] = "There is no question category in database. Please add a category first!"
          redirect_to new_survey_question_category_path
        end
      end

	end
end
