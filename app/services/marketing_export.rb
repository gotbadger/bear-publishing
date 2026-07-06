# frozen_string_literal: true

# Upload list of current users to marketing department shared drive
class MarketingExport
  require 'net/ftp'
  require 'csv'

  include Callable

  def call
    file = Tempfile.new(["#{Time.current.to_date.iso8601}_report",".csv"])
    Rails.logger.info("Created temp report: #{file.path}")
    file.write(csv_data)
    file.close
    upload_csv(file)
  end

  def csv_data
    CSV.generate do |csv|
      csv << ["Organization", "Name", "Email"]
      Organization.all.includes(:users).each do |organization|
        organization.users.each do |user|
          csv << [organization.name, user.name, user.email]
        end
      end
    end
  end

  def output_file(data)

  end

  def upload_csv(file)
    Net::SFTP.start(
      'marketing.example.com',
      'marketing',
      password: 'password123'
    ) do |sftp|
      sftp.upload!(file, "/remote/path/#{File.basename(file)}")
    end
  end
end

