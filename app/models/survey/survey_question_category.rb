#app/models/survey/survey_question_category.rb

module Survey
	class SurveyQuestionCategory < ActiveRecord::Base
		set_table_name "survey_question_categories"

		attr_accessible :title, :parent_id

		has_many :children, :class_name => "SurveyQuestionCategory", :dependent => :destroy, :foreign_key => "parent_id"
		belongs_to :parent, :class_name => "SurveyQuestionCategory"
		has_many :questions, :class_name => "SurveyQuestion", :foreign_key => "question_category_id", :dependent => :destroy

		#scope :parents, where("parent_id IS NULL")

		validates :title, :presence => true, :length => { :maximum => 50 }, :uniqueness => { :case_sensitive => false }

		def descendants
		  all = []
		  self.children.each do |category|
		    all << category.id
		    root_children = category.descendants.flatten
		    all << root_children unless root_children.empty?
		  end
		  return all.flatten
		
		end

	end
end
