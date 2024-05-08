# lib/tasks/disable_assets_precompile.rake

Rake::Task["assets:precompile"].clear

namespace :assets do
  task 'precompile' do
    puts "Precompiling only assets in config/secrets/ directory..."
    # Define the directory to precompile assets from
    assets_directory = Rails.root.join("config/secrets")

    # Get all files in the directory
    files = Dir.glob("#{assets_directory}/*")

    # Precompile each file
    files.each do |file|
      # Check if the file is a regular file (not a directory)
      if File.file?(file)
        # Precompile the file
        puts "Precompiling: #{file}"
        `RAILS_ENV=#{Rails.env} bundle exec rake assets:precompile:primary RAILS_ASSETS_PRECOMPILE_PATHS=#{file}`
      end
    end
  end
end
