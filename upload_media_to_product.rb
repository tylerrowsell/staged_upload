require_relative 'file_upload'
require_relative 'shopify_ql'

class UploadMediaToProduct

  STAGED_UPLOAD_QUERY = ShopifyQL::Client.parse <<-GRAPHQL
  mutation($input: StagedUploadTargetGenerateInput!) {
      stagedUploadTargetGenerate(input: $input) {
      parameters{
          name
          value
      }
      url
      userErrors {
          field
          message
      }
    }
  }
  GRAPHQL

  ATTACH_MEDIA_QUERY = ShopifyQL::Client.parse <<-GRAPHQL
  mutation($id: ID!, $media: [CreateMediaInput!]!) {
      productCreateMedia(productId: $id, media: $media) {
        media {
          ... fieldsForMediaTypes
        }
        product {
          id
        }
        userErrors {
          field
          message
        }
      }
    }
    
    fragment fieldsForMediaTypes on Media {
      alt
      mediaContentType
      position
      previewImage {
        id
      }
      status
      ... on Video {
        id
        sources {
          height
          mimeType
          url
          width
        }
      }
      ... on ExternalVideo {
        id
        embeddedUrl
      }
    }
  GRAPHQL

  def initialize(filename, product_id)
    input = generate_upload_variables(filename)
    staged_upload_data = generate_staged_upload(input: input, original_filename: filename)
    FileUpload.new(staged_upload_data).upload
    add_media_to_product(staged_upload_data.url, product_id, input[:resource])
  end

  def generate_upload_variables(filename)
    size = File.size(filename)
    mime_type = mime_type_from_ext(File.extname(filename))
    file_name = File.basename(filename)
    resource_type = resource_type_from_ext(File.extname(filename))
    {resource: resource_type, filename: file_name, mimeType: mime_type, fileSize: size.to_s}
  end

  def mime_type_from_ext(extension)
    case extension
    when '.mp4'
      'video/mp4'
    end
  end

  def resource_type_from_ext(extension)
    case extension
    when '.mp4'
      "VIDEO"
    end
  end

  def generate_staged_upload(input:, original_filename:)
    response = ShopifyQL::Client.query(STAGED_UPLOAD_QUERY, variables: {input: input})
    
    url = response.original_hash["data"]["stagedUploadTargetGenerate"]["url"]
    
    response_parameters = response.original_hash["data"]["stagedUploadTargetGenerate"]["parameters"]
    parameters = response_parameters.each_with_object({}) do |parameter, hash|
      hash[parameter["name"]] = parameter["value"]
    end

    OpenStruct.new(url: url, parameters: parameters, original_filename: original_filename)
  end

  def add_media_to_product(url, product_id, content_type)
    ShopifyQL::Client.query(ATTACH_MEDIA_QUERY, 
      variables: { id: product_id, media: [{ originalSource: url, mediaContentType: content_type }] })
  end
end