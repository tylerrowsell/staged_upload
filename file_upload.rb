require 'rest-client'

class FileUpload

  def initialize(staged_upload_data)
    @url = staged_upload_data.url
    @original_filename = staged_upload_data.original_filename
    @parameters = staged_upload_data.parameters
  end

  def upload
    RestClient.post(@url, @parameters.merge(file: File.new(@original_filename)))
  end
  
end
