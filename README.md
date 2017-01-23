# Images
Image config files and packer templates for building images across platforms.

## Build a image
1. Download [packer](https://www.packer.io/downloads.html)
2. `cp variables.example.json variables.json`, change the variables with your credentials and AMI ID.
3. `packer build --var-file variables.json images/client.json`
