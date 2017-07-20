# Images
Image config files and packer templates for building images across platforms.

## Build a image
1. Download [packer](https://www.packer.io/downloads.html)
2. `cp variables.example.json variables.json`, change the variables with your credentials, source_ami should be left empty.
3. `packer build --var-file variables.json images/base_image.json`
4. Add the ami for the image built in step 2)  to `variables.json`
5. `packer build --var-file variables.json images/client.json`
