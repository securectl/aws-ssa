#!/bin/bash
set -eo pipefail

vpcs_file=".vpcs"
write_vpc_to_file() {
echo $AWS_VPC >> $vpcs_file
}

([[ ! -z $(tail -n 1 $vpcs_file) ]] && $[[ $(tail -n 1 $vpcs_file | tr -cd ' \t' | wc -c ) != 8 ]]) && echo "Something went wrong with the last vpc creation and not all of the required information is available. You need to delete and re-create the last VPC before creating a new one." && exit

if [[ $1 == "-create" ]]; then

[[ -z $2 ]] && echo "ARG 2 (after -create) needs to be the availability zone you want the VPC in" && exit
AZ=$2

trap write_vpc_to_file EXIT

## Create a VPC
AWS_VPC_ID=$(aws ec2 create-vpc \
-cidr-block 10.0.0.0/16 \
-query 'Vpc.{VpcId:VpcId}' \
-output text)
AWS_VPC="$AWS_VPC_ID"

## Enable DNS hostname for your VPC
aws ec2 modify-vpc-attribute \
-vpc-id $AWS_VPC_ID \
-enable-dns-hostnames "{\"Value\":true}"

## Create a public subnet
AWS_SUBNET_PUBLIC_ID=$(aws ec2 create-subnet \
-vpc-id $AWS_VPC_ID -cidr-block 10.0.1.0/24 \
-availability-zone $AZ -query 'Subnet.{SubnetId:SubnetId}' \
-output text)
AWS_VPC="$AWS_VPC $AWS_SUBNET_PUBLIC_ID"

## Enable Auto-assign Public IP on Public Subnet
aws ec2 modify-subnet-attribute \
-subnet-id $AWS_SUBNET_PUBLIC_ID \
-map-public-ip-on-launch

## Create an Internet Gateway
AWS_INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
-query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
-output text)
AWS_VPC="$AWS_VPC $AWS_INTERNET_GATEWAY_ID"

## Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
-vpc-id $AWS_VPC_ID \
-internet-gateway-id $AWS_INTERNET_GATEWAY_ID

## Create a route table
AWS_CUSTOM_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
-vpc-id $AWS_VPC_ID \
-query 'RouteTable.{RouteTableId:RouteTableId}' \
-output text)
AWS_VPC="$AWS_VPC $AWS_CUSTOM_ROUTE_TABLE_ID"

## Create route to Internet Gateway
aws ec2 create-route \
-route-table-id $AWS_CUSTOM_ROUTE_TABLE_ID \
-destination-cidr-block 0.0.0.0/0 \
-gateway-id $AWS_INTERNET_GATEWAY_ID

## Associate the public subnet with route table
AWS_ROUTE_TABLE_ASSOID=$(aws ec2 associate-route-table \
-subnet-id $AWS_SUBNET_PUBLIC_ID \
-route-table-id $AWS_CUSTOM_ROUTE_TABLE_ID \
-output text | head -1)
AWS_VPC="$AWS_VPC $AWS_ROUTE_TABLE_ASSOID"

## Create a security group
aws ec2 create-security-group \
-vpc-id $AWS_VPC_ID \
-group-name myvpc-security-group \
-description 'My VPC non default security group'

## Get security group ID's
AWS_DEFAULT_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
-filters "Name=vpc-id,Values=$AWS_VPC_ID" \
-query 'SecurityGroups[?GroupName == default].GroupId' \
-output text)
AWS_VPC="$AWS_VPC $AWS_DEFAULT_SECURITY_GROUP_ID"

AWS_CUSTOM_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
-filters "Name=vpc-id,Values=$AWS_VPC_ID" \
-query 'SecurityGroups[?GroupName == myvpc-security-group].GroupId' \
-output text)
AWS_VPC="$AWS_VPC $AWS_CUSTOM_SECURITY_GROUP_ID"

## Create security group ingress rules
aws ec2 authorize-security-group-ingress \
-group-id $AWS_CUSTOM_SECURITY_GROUP_ID \
-ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "Allow SSH"}]}]'

aws ec2 authorize-security-group-ingress \
-group-id $AWS_CUSTOM_SECURITY_GROUP_ID \
-ip-permissions '[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "Allow HTTP"}]}]'

## Add a tag to the VPC
aws ec2 create-tags \
-resources $AWS_VPC_ID \
-tags "Key=Name,Value=myvpc"

## Add a tag to public subnet
aws ec2 create-tags \
-resources $AWS_SUBNET_PUBLIC_ID \
-tags "Key=Name,Value=myvpc-public-subnet"

## Add a tag to the Internet-Gateway
aws ec2 create-tags \
-resources $AWS_INTERNET_GATEWAY_ID \
-tags "Key=Name,Value=myvpc-internet-gateway"

## Add a tag to the default route table
AWS_DEFAULT_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
-filters "Name=vpc-id,Values=$AWS_VPC_ID" \
-query 'RouteTables[?Associations[0].Main != flase].RouteTableId' \
-output text)
AWS_VPC="$AWS_VPC $AWS_DEFAULT_ROUTE_TABLE_ID"

aws ec2 create-tags \
-resources $AWS_DEFAULT_ROUTE_TABLE_ID \
-tags "Key=Name,Value=myvpc-default-route-table"

## Add a tag to the public route table
aws ec2 create-tags \
-resources $AWS_CUSTOM_ROUTE_TABLE_ID \
-tags "Key=Name,Value=myvpc-public-route-table"

## Add a tags to security groups
aws ec2 create-tags \
-resources $AWS_CUSTOM_SECURITY_GROUP_ID \
-tags "Key=Name,Value=myvpc-security-group"

aws ec2 create-tags \
-resources $AWS_DEFAULT_SECURITY_GROUP_ID \
-tags "Key=Name,Value=myvpc-default-security-group"

elif [[ $1 == "-delete" ]]; then

AWS_VPC=$(tail -n 1 $vpcs_file)
[[ -z $AWS_VPC ]] && echo "nothing to delete!" && exit

AWS_VPC_ID=$(echo $AWS_VPC | cut -d ' ' -f1)
AWS_CUSTOM_SECURITY_GROUP_ID=$(echo $AWS_VPC | cut -d ' ' -f7)
AWS_INTERNET_GATEWAY_ID=$(echo $AWS_VPC | cut -d ' ' -f3)
AWS_ROUTE_TABLE_ASSOID=$(echo $AWS_VPC | cut -d ' ' -f5)
AWS_CUSTOM_ROUTE_TABLE_ID=$(echo $AWS_VPC | cut -d ' ' -f4)
AWS_SUBNET_PUBLIC_ID=$(echo $AWS_VPC | cut -d ' ' -f2)

## Delete custom security group
aws ec2 delete-security-group \
-group-id $AWS_CUSTOM_SECURITY_GROUP_ID || true

## Delete internet gateway
aws ec2 detach-internet-gateway \
-internet-gateway-id $AWS_INTERNET_GATEWAY_ID \
-vpc-id $AWS_VPC_ID || true

aws ec2 delete-internet-gateway \
-internet-gateway-id $AWS_INTERNET_GATEWAY_ID || true

## Delete the custom route table
aws ec2 disassociate-route-table \
-association-id $AWS_ROUTE_TABLE_ASSOID || true

aws ec2 delete-route-table \
-route-table-id $AWS_CUSTOM_ROUTE_TABLE_ID || true

## Delete the public subnet
aws ec2 delete-subnet \
-subnet-id $AWS_SUBNET_PUBLIC_ID || true

## Delete the vpc
aws ec2 delete-vpc \
-vpc-id $AWS_VPC_ID

sed -i " "/$AWS_VPC/d" $vpcs_file

else
echo "-create or -delete…"
exit
fi