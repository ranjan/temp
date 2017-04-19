namespace :property do
  desc 'Delete records older than 60 days'
  task :prune_old_records => :environment do
    PropertyAddress.where('created_at < ?', 1.days.ago).each do |pa|
      pa.destroy
    end
  end
end