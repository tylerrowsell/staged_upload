# Staged Upload for Shopify Media
Example of a ruby app that can perform a staged upload to Shopify Media

Replace `<SHOP_HANDLE>` with your shop handle in `shopify_ql`
Replace `<ACCESS TOKEN>` with your private app password in `shopify_ql`


Use `UploadMediaToProduct.new(<PATH_TO_MEDIA>, "gid://shopify/Product/<PRODUCT_ID>")` to upload.

Replace `<PATH_TO_MEDIA>` with the path to media on your local machine.
Replace `<PRODUCT_ID>` with the product id you'd like to upload media to.
