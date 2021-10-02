# SESSION 6 – LAB 1

## CREATE RDS WITH APPLICATION

## FRONTEND

### In this lab you will learn how to create RDS instance and create

### application frontend.

- Create RDS MySQL database

- Create EC2 instance

- Configure EC2 instance to connect to database

- Configure WordPress application

- Connect and Verify WordPress

- Create blog post

## For this lab to work, you will need IAM admin access or policy to allow

## creation of RDS, EC2 and VPC access.

## This lab is written to work with region us-east- 1

## Note: This lab might incurr cost, please verify billing activities and

## terminate stack after you are done.

## 1. Objective

- Create RDS instance (MySQL)

- Create EC

- Install WordPress

- Configure WordPress with MySQL

- Create Blog post


- Clean-up

## 2. Create AWS RDS MySQL

#### 2.1. Login to AWS console and in find services search for

#### “RDS”

#### 2.2. From VPC Dashboard, click the “Create Database”

#### 2.3. Select box “Easy Create”

#### =

#### 2.4. Select MySQL and Free Tier


#### 2.5. Input following in form:

#### Database name: wordpress

#### Master Username: admin

#### Master Password Your_own_password



##### 2.6. Veiw default settings for easy create

#### 2.7. Click Create – (this might take 10-15 mins)


#### 2.8. Verify the Security group and allow port 3306 for

#### MySQL to be accessible

#### 2.9. Modify the instance by selecting and click modify

#### 2.10. Under Connectivity, verify the public access for the

#### RDS instance and allow RDS instance public access (Note:


#### This is for lab purpose - do not do this in real life).

#### 2.11. Click continue and verify


### 3. Create EC

##### 3.1. From the AWS console, search for EC2, under instances, select instances

##### 3.2. Launch instances and select ami-id “ami-0947d2ba12ee1ff75” or the first Amazon

```
Linux 2 AMI
```
##### 3.3. Keep the shape t2.micro and click configure instance details


##### 3.4. On instance details, set the VPC to default vpc (or vpc where RDS instance was created)

##### 3.5. Scroll down to the bottom and under user data paste following:

#!/bin/bash
yum update -y amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.
yum install -y httpd mariadb-server wget
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www

##### 3.6. Click Add storage and leave it default; click add tags and then configure security group


##### 3.7. Select the security group created earlier (access-security-group)


##### 3.8. Review and launch – select your key-pair

##### 3.9. After the instance boot-up is complete, note the ec2 public IP and verify If you can

```
access the webpage.
```

## 4. Install & Configure WordPress

##### 4.1. Connect to EC2 instance

##### 4.2. Create database & database user for wordpress application as this will be used to

```
connect to database from webserver.
4.2.1. Connect to mysql database from webserver:
```
```
mysql -h your_database_endpoint -P 3306 -u admin -p
```

4.2.2. Create wordpress user

```
show databases;
create database wordpress;
CREATE USER 'wordpress' IDENTIFIED BY 'W0rdPr3ss123';
GRANT ALL PRIVILEGES ON wordpress.* TO wordpress;
FLUSH PRIVILEGES;
show databases;
exit
```

##### 4.3. Login to newly created ec2 and run following commands:

```
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cd wordpress
cp wp-config-sample.php wp-config.php
```
##### 4.4. Locate file the config file wp-config.php

```
ls wp-config.php
```
##### 4.5. Modify following lines with in wp-config.php using vi or nano

```
vi wp-config.php
```
###### DB_NAME wordpress^ Database name

```
created in step 4.
```
###### DB_USER wordpress^ Username created^ in

```
step 4.
```
###### DB_PASSWORD W0rdPr3ss12^3 Password^ created^ in

```
step 4.
```
###### DB_HOST Your_RDS_endpoint^

##### 4.6. Generate the SALT tokens for wordpress application from url below:

```
https://api.wordpress.org/secret-key/1.1/salt/
```

##### 4.7. Copy and paste the output in section “Authenticate Unique Keys and Salts” in wp-

```
config.php
```
##### 4.8. Copy the wordpress config and software to /var/www/html - copy content to notepad

```
and fix any line wrap.
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.
cd /home/ec2-user
sudo cp -r wordpress/* /var/www/html/
sudo service httpd restart
```
##### 4.9. If everything works, you should see this page when you connect to EC2 public IP


##### 4.10. Setup the wordpress site by inputting your values for Siter title, username, password &

```
email; Install Wordpress.
```



##### 4.11. Login to site


##### 4.12. Create a blog post

##### 4.13. Add a post


##### 4.14. Add a random post

##### 4.15. View the post by going to your post


## 5. Clean-Up

##### 5.1. From EC2 console, select your instance you created – right click and

###### select “Instance State.”


##### 5.2. Click Terminate

##### 5.3. Once it is terminated you should see instance status changed to

###### “Terminated.”

##### 5.4. In AWS console search for RDS and click databases

##### 5.5. Select the wordpress database


##### 5.6. Don’t take the backup

##### 5.7. This will delete the RDS instance.

## Conclusion

###### You learned how to create RDS instance, create webserver and connect the

###### webserver to RDS databases. Also, you learned how to deploy wordpress

###### application with RDS and EC2.


