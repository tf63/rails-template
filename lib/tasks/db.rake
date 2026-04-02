namespace :db do
  desc "execute migration"
  task migrate: [ :environment ] do |_task, _args|
    system("bundle exec ridgepole --env #{Rails.env} -c config/database.yml  --file ./db/schemas/Schemafile -a")
    system("bundle exec ridgepole --env #{Rails.env} -c config/database.yml --export -o db/schemas/schema.rb")
    ApplicationRecord.descendants.map(&:reset_column_information)
    system("bundle exec annotaterb models") if Rails.env.development?
  end

  namespace :migrate do
    desc "execute migration dry-run"
    task dry_run: [ :environment ] do |_task, _args|
      system("bundle exec ridgepole --env #{Rails.env} -c config/database.yml --file ./db/schemas/Schemafile -a --dry-run")
    end
  end
end
