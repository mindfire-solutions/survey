Survey::Engine.routes.draw do
	resources :survey_question_categories
	resources :survey_question_set_items
	resources :survey_validations
	resources :survey_questions do
		collection do
			get 'get_questions'
		end
	end
	resources :survey_question_sets do
		collection do
			get 'get_question_sets'
			get 'add_condition'
		end
	end
	resources :survey_evaluations, :except => [ :new, :show ] do
		collection do
			get 'evaluate_question'
			get 'add_condition_reference'
			get 'get_evaluations'
		end
	end
	root :to => 'survey_evaluations#index'
end
