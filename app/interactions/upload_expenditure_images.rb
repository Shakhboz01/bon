class UploadExpenditureImages < ActiveInteraction::Base
  object :expenditure
  array :images

  def execute
    # Attach images to the expenditure
    images.each do |image|
      expenditure.images.attach(image)
    end
  end
end
