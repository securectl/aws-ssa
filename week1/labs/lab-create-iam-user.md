# LAB – Create IAM User

In this lab you will learn how to create AWS EBS device and attach to instance during creation time and after EC2 creation. For this lab to work, set your region to “us-east-1”

### Objective 

  -	Create AWS IAM user 
  - Authenticate with IAM user 

#### 1. Create IAM User 

* Create IAM account
    * As root user login to your AWS account
    * In search bar type IAM
    * In left pane, click users
    * Click “add user” 
    * Provide the username (must not be the original email)
    * Select “Programmatic access” & “AWS Management Console access” 
    * Click “Next”
    * There are 3 options:
      * Add User to group, Copy permissions from existing user, Attach existing policies directly.
    * For this exercise, select option: Attach existing policies directly.
    * In search box type “AdministratorAccess” and select policy 
    * Click next on tags, click "Next: Review" & Click "Create user"
* Review and Create
    * Review the password (you will need this for login) 
    * Download the credentials file and keep it in safe place

#### 2. Authenticate with IAM User 
* Open the excel/csv file can capture the url from content (Console login link)
* Does the login page look different? If so, what do you see?
* Authenticate with newly IAM user created in section 2 & authenticate.
* AWS will ask you to reset your password, once done use the new password to login.
* How is this account different from root account?


### Conclusion 

What did we learn? With AWS IAM we can create individual access allowing least privileges when user needs limited access. 
