gsub_file 'Gemfile', /(group :development, :test do.*?)end/m, <<~GEMS.chomp
gem 'slim-rails'

\\1
  gem 'factory_bot_rails'

  gem 'rspec-rails'

  gem 'rubocop'
  gem 'rubocop-factory_bot'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end
GEMS

create_file('.rubocop.yml', <<~TEXT
require:
  - rubocop-rspec
  - rubocop-rails
  - rubocop-performance
  - rubocop-factory_bot

AllCops:
  NewCops: disable

Metrics:
  Enabled: false

Layout/LineLength:
  Enabled: false

RSpec/ExampleLength:
  Enabled: false

Style/Documentation:
  Enabled: false
TEXT
)

after_bundle do
  run 'bundle binstubs rspec-core'
  run 'bundle binstubs rubocop'

  generate 'rspec:install'

  # Integrates factory bot to rspec
  uncomment_lines(
    'spec/rails_helper.rb',
    /spec\/support\/\*\*/
  )
  create_file('spec/support/factory_bot.rb', <<~TEXT
    RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
    end
    TEXT
  )

  # Creates home page
  generate(*%i[controller home show --no-helper --skip-routes --no-request-specs --no-view-specs]) 
  route "root to: 'home#show'"

  # Format code base
  run 'bin/rubocop -A --no-parallel --format=worst'

  git :init
  git add: '.'
  git commit: "-a -m 'Initialize project'"
end

