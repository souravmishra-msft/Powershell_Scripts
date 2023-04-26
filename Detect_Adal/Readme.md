# Powershell Script to detect ADAL in your code repo

### This powershell script helps you in identifying if your current project (hosted on github) uses adal or not. It also helps you find traces of adal in the code repo.

## For test purposes the following code repo is used: https://github.com/idaceappdev/AdalToMsal

To test this code, please following the steps mentioned below:
1. Generate a github personal access_token and update the $accessToken with that value.
2. Update the $repoOwner and $repoName as per requirement.
3. Update the $repoPath with the directory in the repo that you would like to scan.

[Note:] Currently this script scans for .Net, Python, Java and Javascript.

Please use this code and share your suggestions, also feel free to fork and update the code to make this an awesome code scanner to help our customers in their ADAL_to_MSAL journey.

