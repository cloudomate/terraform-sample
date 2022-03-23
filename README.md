This is simple terraform code to create a keypair, create vpc, subnet, security group for ssh access , create ecs, assign a eip and associate with ecs

1. Setup the enviornment variable create a env file and source it before using

      G42_REGION_NAME="ae-ad-1"  
      G42_ACCESS_KEY="your ak"  
      G42_SECRET_KEY="you sk"  
      G42_PROJECT_NAME=<your project name> default value is ae-ad-1,if you are working on another project use ae-ad-1_project name

2. create an ssh key pair on your local machine copy the public key to the public_key field (line 69 of code)

3. create the infra
terraform init  
terraform apply  

4. Get EIP either using output method or by simply using "terraform state show g42cloud_vpc_eip.eip" to get the public ip
5. you can use the key and login to ecs , ssh -i your_key_file root@public_ip
