Survey
======
Survey is a basic questionaire gem. The basic idea behind this gem was to create a system where we can manage the questions & sets of questions and as well as the evaluation at one place. Initially it was started as a basic survey application where an admin can create a question set(set of questions for a survey) that contains a lot of questions and sub-sets as well as the conditional questions (e.g. If there is a question “Which car do you own?” and you have to choose one of the selections. Using the conditions we can add a question/sub-set based on the selection made.). The other users can just participate to fill in the survey, they are not allowed to create/delete any of the questions/sets though they can manage their evaluations(answers to a survey). After following up  we found a need of having a small gem for rails applications so that we can add this system any of the existing applications.

Prerequisites
-------------
* Ruby 1.9 or higher
* Ruby on Rails 3.1.3 or higher
* Application must have an authentication system with admin and normal user privileges.
* As the gem is using jQuery, so your application must support(include) jQuery-rails gem.

Getting Started
---------------
Survey is a mountable engine created in rails 3.1.3 environment. It can be integrated to any rails application > 3.1.3.
Basically, Survey is questionaire system that includes questions, question sets and evaluations parts.

The Questions and Sets can be managed by the admin only. And the Evaluations can be accessed by all the users. So for using this gem you must setup an authentication system in your application which can identify the admin among all users.

Below are instruction to setup survey in your application:

* Add the survey gem to your Gemfile:
```ruby
gem "survey", '0.0.1', :git => "git://github.com/minfire-solutions/survey.git"
```

* Run the bundler.
```console
bundle install
```

* Install the gem by running following command in the terminal
```console
rails generate survey:install MODEL
```
	Replace MODEL with the name of the model class, the application is using for authentication etc. e.g User.
  This will generate the required migrations, initializers and routes for the survey module to work.

* Run the migrations.
```console
rake  db:migrate
```

* Now, Include Stylesheets and javascript to the layout (application.html.erb)
```erb
<%= stylesheet_link_tag "survey/application" %>
<%= javascript_include_tag "survey/application" %>
```

* Override a these two methods/actions in application controller so that the survey can identify the user access. `user_signed_in?`, `current_user`, `current_user.admin?` are supposed to be helper methods, they can be different in your case. Please use the appropriate methods to replace them. `new_user_session_path` and `root_path` are the routing helper methods.
```ruby
  def redirect_unless_logged_in
  	unless user_signed_in?
  		flash[:error] = 'Please log in.'
  		redirect_to main_app.new_user_session_path
  	end
  end
  
  def redirect_unless_admin
  	if !user_signed_in?
  		flash[:error] = 'Please log in.'
  		redirect_to new_user_session_path
  	elsif !current_user.admin?
  		flash[:error] = 'You do not have permission to view this page.'
  		respond_to do |format|
  			format.js {render :js => "window.location = '" + root_path + "';"}
  			format.html {redirect_to(root_path)}
  		end
  	end
  end
```
  
* To add the links for Question, Question Set and Evaluation pages add the following to your view file if you are using erb otherwise use haml equivalent.
```erb
<%= link_to "Questions", survey.survey_questions_path %>
<%= link_to "Question Sets", survey.survey_question_sets_path %>
<%= link_to "Evaluations", survey.survey_evaluations_path %>
```

* If you are getting any conflicts in routes or if the application is showing error message for the defined routes, you can separate the routes by calling the route helper mathod on main_app object. e.g.
```ruby
main_app.destroy_session_path etc.
```

* That's it you are ready to launch survey!!.. :) Point your browser to yourdomain/survey.