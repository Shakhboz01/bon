# app/jobs/upload_images_job.rb
class UploadImagesJob < ApplicationJob
  queue_as :default

  def perform(model_id, model_class, file_path)
    model = model_class.constantize.find(model_id)

    # Attach the image to the model
    model.images.attach(io: File.open(file_path), filename: File.basename(file_path))

    # Optionally, you can remove the temporary file after attaching the image
    File.delete(file_path) if File.exist?(file_path)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Error in UploadImagesJob: #{e.message}"
  end
end
