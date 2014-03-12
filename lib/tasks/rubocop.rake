# Runs rubocop without having to type out the entire command.
desc 'Run rubocop'
task :rubocop do
  exec "cd #{Rails.root} && rubocop --rails --config ./config/rubocop.yml ./lib ./spec ./app ./config"
end
