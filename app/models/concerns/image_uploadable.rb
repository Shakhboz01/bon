# app/models/concerns/image_uploadable.rb
module ImageUploadable
  extend ActiveSupport::Concern

  included do
    def save_images_to_temporary_location(images, model)
      Array(images).each do |image|
        next unless image.present? && image.respond_to?(:tempfile)

        file_path = Rails.root.join('tmp', 'uploads', image.original_filename)
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'wb') do |file|
          file.write(image.tempfile.read)
        end
        # Pass the file path to the background job
        UploadImagesJob.perform_later(model, file_path.to_s)
      end
    end
  end
end
