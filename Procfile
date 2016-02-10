web: bundle exec unicorn -E production -p $PORT -c ./config/unicorn.rb
worker: env RAILS_ENV=production bundle exec rake jobs:work
