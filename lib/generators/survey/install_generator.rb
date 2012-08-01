#lib/generators/survey/survey_generator.rb
require 'rails/generators'
require 'rails/generators/migration'

module Survey
  class InstallGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number(path)
      unless @prev_migration_nr
        @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
      else
        @prev_migration_nr += 1
      end
      @prev_migration_nr.to_s
    end

    def copy_migrations
      migration_template "migrations/create_survey_question_categories.rb", "db/migrate/create_survey_question_categories.rb"
      migration_template "migrations/create_survey_questions.rb", "db/migrate/create_survey_questions.rb"
      migration_template "migrations/create_survey_question_sets.rb", "db/migrate/create_survey_question_sets.rb"
      migration_template "migrations/create_survey_question_set_items.rb", "db/migrate/create_survey_question_set_items.rb"
      migration_template "migrations/create_survey_validations.rb", "db/migrate/create_survey_validations.rb"
      migration_template "migrations/create_survey_question_validations.rb", "db/migrate/create_survey_question_validations.rb"
      migration_template "migrations/create_survey_question_selections.rb", "db/migrate/create_survey_question_selections.rb"
      migration_template "migrations/create_survey_question_set_item_conditions.rb", "db/migrate/create_survey_question_set_item_conditions.rb"
      migration_template "migrations/create_survey_question_set_item_condition_validations.rb", "db/migrate/create_survey_question_set_item_condition_validations.rb"
      migration_template "migrations/create_survey_question_set_item_condition_selections.rb", "db/migrate/create_survey_question_set_item_condition_selections.rb"
      migration_template "migrations/create_survey_evaluations.rb", "db/migrate/create_survey_evaluations.rb"
      migration_template "migrations/create_survey_evaluation_items.rb", "db/migrate/create_survey_evaluation_items.rb"
    end

    def add_intializer
      #template "initializer.rb", "config/initializers/survey_initializer.rb"
      create_file "config/initializers/survey_initializer.rb",
        "# replace User with your member resource.
USER_RESOURCE = '" + file_name.camelize + "'"
    end

    def add_routes
      engine_mount  = "mount Survey::Engine, :at => '/survey'"
      route engine_mount
    end

  end
end
