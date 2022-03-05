#!/bin/bash

#This is for configuring access to your aws console.
Access_Key=""
Secret_Access_Key=""
Default_Region_Name="us-east-1"
Default_Output_Format="json"

#Using the variables above we run aws configure to setup the access
printf "$Access_Key\n$Secret_Access_Key\n$Default_Region_Name\n$Default_Output_Format" | aws configure
echo ""

#This is the cidr block for the VPC.
vpc_cidr_block="10.0.0.0/16"

#We run this command to create a Virtual Private Cloud and assigned the output which is the VPC ID to var "create_vpc" for later use.
create_vpc=$(aws ec2 create-vpc --cidr-block $vpc_cidr_block --query Vpc.VpcId --output text)

#Just so we can see what the actual id of the VPC is.
printf "\nVPC ID: $create_vpc\n"

#This is the cidr block for the subnet.
    cidr_block="10.0.0.0/24"

#Using the variables "cidr_block" and "create_vpc" we create a subnet inside the vpc.
subnet=$(aws ec2 create-subnet --vpc-id $create_vpc --cidr-block $cidr_block --query Subnet.SubnetId --output text)

#Lets print the subnet ID out.
printf "Subnet ID: $subnet\n"

#Lets create an internet gateway and assign the IGW ID to the var "internet_gateway".
internet_gateway=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)

#Print out the actual IGW ID.
printf "IGW ID: $internet_gateway\n"

#We need to attach the internet gateway to the VPC using the variables "create_vpc" and "internet_gateway".
aws ec2 attach-internet-gateway --vpc-id $create_vpc --internet-gateway-id $internet_gateway

#Now lets create a route table using the variable "create_vps" and output the Route Table ID to "route_table".
route_table=$(aws ec2 create-route-table --vpc-id $create_vpc --query RouteTable.RouteTableId --output text)

#Create a route that points all trafic to the internet gateway.
aws ec2 create-route --route-table-id $route_table --destination-cidr-block 0.0.0.0/0 --gateway-id $internet_gateway > /dev/null

#Display route table information to esure everything is correct.
#aws ec2 describe-route-tables --route-table-id $route_table

#We need to associate the route table to a subnet so that traffic is routed to the internet gateway within the VPC.
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$create_vpc" > /dev/null

#Now we need to associate the route table to the subnet.
aws ec2 associate-route-table  --subnet-id $subnet --route-table-id $route_table > /dev/null

#We want to modify the subnet to allow public ips to be assigned when we launch and instance in the subnet.
aws ec2 modify-subnet-attribute --subnet-id $subnet --map-public-ip-on-launch > /dev/null 

#Now we want to create a keypair for us to SSH into an instance.
aws ec2 create-key-pair --key-name MyKeyPair --query "KeyMaterial" --output text > MyKeyPair2.pem

#Only us should be able to read the pem file.
chmod 400 MyKeyPair.pem

#Now lets create a security group name SSHAccess for our VPC and assign the groupid to variable "security_group".
security_group=$(aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id $create_vpc | sed 's/[^sg]*\(sg[^ .]*\)/\1\n/g' | grep sg | sed 's/.$//')

printf "Security Group ID: $security_group\n"

#Now lets create a linux instance and add the security group and keypair in the subnet.
aws ec2 run-instances --image-id ami-a4827dc9 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids $security_group --subnet-id $subnet > /dev/null