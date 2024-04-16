Installation manual:
1. Install AWS command line interface
2. Log into aws console and create an access key through Identity and Access Management (IAM)
3. Open terminal (mac) or cmd (windows)
4. Run "aws configure" and fill in your access key ID and secret access key. Leave the rest of the options empty.
5. Install Terraform by following the steps in this manual: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
6. Open terminal (mac) or cmd (windowws) again and navigate to the folder where this readme file is residing.
7. Run "Terraform apply" and type "yes" when prompted
8. Open a browser and go to the aws console and log in.
9. In the search field search for "Cloudfront" and find the domain name for the distribution.
10. Now this can be copied and pasted into the browser URL to view the static website.
