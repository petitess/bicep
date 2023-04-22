# Governance

This Git repository is part of the a hub-and-spoke network topology and contains a governance structure built on Infrastructure-as-Code (IaC) and Continuous Integration/Continuous Delivery (CI/CD).

The entire framework can be found in the following `Azure DevOps` project:  
https://dev.azure.com/xxxx/Infrastruktur/_git/xxx-governance

## Getting started
This project is developed cross-platform and can be managed and deployed from `Windows`, `Linux` and `Mac`.  
In addition, it can very easily be integrated into a CI/CD tool, such as `Azure Pipelines`.

### Prerequisites
In order to deploy this project you will need an account that is assigned the directory roles `Application Administrator`, `Privileged Role Administrator` and `User Administrator` in the `Azure AD` tenant and also the Azure role `Owner` on the subscriptions in use.

There are also a number of prerequisites that need to be installed on your local machine before you can succesfully manage and deploy this project.  
Simply follow the instructions below for the operating system in use.

### `Windows`

#### 1. Install `Git`, `Visual Studio Code`, `Bicep`, and the latest version of `PowerShell Core` by running the following cmdlets in an elevated `PowerShell` prompt:
```powershell
winget install Git.Git
winget install Microsoft.VisualStudioCode
winget install Microsoft.PowerShell
winget install Microsoft.Bicep
```


#### 2. Install the following `Azure modules` and `Visual Studio Code extensions` in the `Powershell` prompt:

The Azure modules:
```powershell
Install-Module Az
```

The Visual Studio Code extensions:
```powershell
code --install-extension waderyan.gitblame
code --install-extension redhat.vscode-yaml
code --install-extension ms-vscode.powershell
code --install-extension yzhang.markdown-all-in-one
code --install-extension ms-azuretools.vscode-bicep
code --install-extension gurumukhi.selected-lines-count
code --install-extension josin.kusto-syntax-highlighting
code --install-extension ms-azure-devops.azure-pipelines
code --install-extension msazurermtools.azurerm-vscode-tools
```
#### 3. Generate Git credentials from `Azure DevOps`:
[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> \<repo-name\> -> Clone -> Generate Git credentials
### 4.Run the following code line by line to clone the Git repository to your computer:
```powershell
cd <path-to-where-to-save-the-project>
git clone <url>
```
#### 6. Open `Visual Studio Code` from the current working directory:
```powershell
code .
```
### `Linux`
#### 1. Run the following code block to install all prerequisites:
```shell
read -p "Firstname Lastname: " userName ; read -p "Email: " userEmail

sudo apt update

sudo apt install -y jq

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo apt install -y git &&
    git config --global user.name "${userName}" &&
    git config --global user.email "${userEmail}" &&
    git config --global credential.helper "cache --timeout=86400"
```

#### 2. Get the Git Clone URL from `Azure DevOps`:
[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> \<repo-name\> -> Clone -> Copy clone URL to clipboard


#### 3. Generate Git credentials from `Azure DevOps`:
[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> \<repo-name\> -> Clone -> Generate Git credentials

#### 4. Run the following code line by line to clone the Git repository to your computer:
```shell
read -p "Git Clone URL: " cloneUrl

path=~/repos

mkdir -p "${path}" &&
    cd "${path}"

git clone "${cloneUrl}"
```

#### 5. Customize shell prompt to include current Git branch (Optional):
```shell
vim ~/.bashrc

# Add the following line of code:
export PS1="\[\033[00;32m\]\u@\h\[\033[00m\]:\[\033[00;35m\]\w\[\033[36m\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')\[\033[00m\] $ "
```

<br>

### `Mac`

#### 1. Run the following code blocks one by one to install all prerequisites:
```shell
read -p "Firstname Lastname: " userName ; read -p "Email: " userEmail
```

```shell
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/main/install)"

brew install bash

if [[ -z "$(cat /etc/shells | grep -- /usr/local/bin/bash)" ]]; then
    echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
fi

chsh -s /usr/local/bin/bash ; sudo chsh -s /usr/local/bin/bash
```

```shell
brew install coreutils

brew install jq

brew install azure-cli

brew install git &&
    git config --global user.name "${userName}" &&
    git config --global user.email "${userEmail}" &&
    git config --global credential.helper osxkeychain

brew cask install visual-studio-code && (
    code --install-extension waderyan.gitblame
    code --install-extension redhat.vscode-yaml
    code --install-extension ms-vscode.powershell
    code --install-extension yzhang.markdown-all-in-one
    code --install-extension ms-azuretools.vscode-bicep
    code --install-extension gurumukhi.selected-lines-count
    code --install-extension josin.kusto-syntax-highlighting
    code --install-extension ms-azure-devops.azure-pipelines
    code --install-extension msazurermtools.azurerm-vscode-tools
)
```

#### 2. Get the Git Clone URL from `Azure DevOps`:
[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> \<repo-name\> -> Clone -> Copy clone URL to clipboard

#### 3. Generate Git credentials from `Azure DevOps`:
[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> \<repo-name\> -> Clone -> Generate Git credentials

#### 4. Run the following code line by line to clone the Git repository to your computer:
```shell
read -p "Git Clone URL: " cloneUrl

path=~/repos

mkdir -p "${path}" &&
    cd "${path}"

git clone "${cloneUrl}"
```

#### 5. Customize shell prompt to include current Git branch (Optional):
```shell
vim ~/.bash_profile

# Add the following line of code:
export PS1="\[\033[00;32m\]\u@\h\[\033[00m\]:\[\033[00;35m\]\w\[\033[36m\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')\[\033[00m\] $ "
```

#### 6. Open `Visual Studio Code` from the current working directory:
```shell
code .
```
# Build and Test
## Compatible versions

The following software versions have been tested and verified to be compatible with this project:

| Software   | Version      |
| ---------- | ------------ |
| Windows    | 11 (22H2)    |
| Linux      | Ubuntu 22.10 |
| xmacOS     | 11.3.1       |
| Powershell | 7.3.4        |
| azure CLI  | 2.45.0       |
| git        | 2.39.1       |
| xHomebrew  | 3.1.9        |
| VSCode     | 1.77.0       |

## Deployment

### 1. Environment files

The governance structure consists only of `production` environment and is common for all landing zones and platform. 

### 2. First-time deployment

To be able to deploy this governance repository, a subscription in needed. Hub subscription `sub-platform-prod-01` is used for this purpose.   

### 3. CI/CD

The directory [ci](/ci/) contains two YAML files `ci.yml` and `cd.yml`. When the code is pushed for the first time, pipelines have to be created manually. Use the following syntax to run the script:

```powershell
./scripts/devops.ps1 
```

### 4. Service Principal

In order for the CI/CD pipeline to run successfully, a service principal must first be created in `Azure AD` on the `Tenant` scope. It must be done with a powershell script. 

#### 1. Access to root management group
In order to get access on the root management group go to the `Azure portal`.

Then you go to `Azure Active Directory` and click `Properties`.

Under `Access management for Azure resources` you change it to `Yes` 

#### 2. Create the service principal by going to service connection in DevOps

URL: [Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> \<_Settings\> -> \<adminservices\>

or

Manually: [Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> \<Project settings\> -> \<Service connections\>

Click on `New service connection` -> `Azure Resource Manager` -> `Service principal (automatic)` and choose `Subscription` as Scope level.

Choose the `sub-platform-prod-01` and the name of the Service connection. Then click Save.

#### 3. Assign the permission on tenant scope

Go to the subscription `sub-platform-prod-01` > Access control (IAM). Find the name of the serivice principal. Run the script to assign the permission on tenant scope: 

```powershell
$app = Get-AzADServicePrincipal -DisplayName "<service prinicpal name>"
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $app.Id
```

### 5. Managed identity for Azure AD groups deployment

When the first deployment is made the subscriptions `sub-platform-prod-01` contains a managed identity `id-script-governance-prod-we-01` in the resource group `rg-governance-prod-we-01`. This managed identity is used to deploy Azure AD groups and permissions. Hence it needs the role `Groups Administrator` in Azure AD and `Owner` on the `Tenant` scope.

To assign the role `Groups Administrator` to this managed identity run the script:

```powershell
cd scripts
./GroupsAdministrator.ps1
```
Or do it manually.
`Azure Active Directory` > `Roles and administrators` > `Groups Administrator` > Assign the role to `id-script-governance-prod-we-01`

To assign the role `Owner` to this managed identity run the script:

```powershell
$app = Get-AzADServicePrincipal -DisplayName "id-script-governance-prod-we-01"
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $app.Id
```

Go back to `Azure Active Directory` and click `Properties`

Change `Access management for Azure resources` to `No`




### 6. Pipeline deployment

The CI/CD pipeline defined in `ci.yml` and `cd.yml` is configured to trigger on the Git branch `main`, meaning that a deployment will start as soon as a new commit is pushed there.  
To avoid unnecessary deployments, there are certain files that are excluded from triggering the pipeline, for example `README.md`.

As expected, the stages defined in the CI/CD pipeline are deployed sequentially, meaning that if a previous stage fails, the remaining stages will not run.

### 7. Branch policies

Since every push to `main` will trigger the pipeline, it is highly recommended to configure a branch policy that blocks direct pushes to the `main` branch.  
Instead, all changes should be made in short-lived feature branches. A pull request is then created to merge the changes into the `main` branch, which in turn will trigger a deployment. Once the merge is complete, the feature branch in question is removed from the repository.


To configure a branch policy at the repository level, go to:

[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> Branches

Click the `More...` icon on `main` and select `Branch policies`.

Tick the checkbox `Require a minimum number of reviewers` and enter the desired minimum number of reviewers.

In order to keep the commit history linear and more legible, it's also a good practice to limit the allowed merge types to `Squash merge` only, meaning that all commits from the source branch will be consolidated into a single commit in `main`, as opposed to individual commits.  
This is done by simply ticking the checkbox `Limit merge types` and then make sure to only tick the checkbox `Squash merge`.


### 8. Feature branches

Since direct pushes to `main` are now blocked, all consequent changes to this repository need to be made in separate feature branches.  
It's advisable to prefix the names of all feature branches with the string `feature/`, as this will in fact show as a directory in `Azure Repos`.  
Also, avoid using spaces and special characters in the branch name.

In order to create and check out a new feature branch based on `main`, run the following commands:
```shell
git checkout main

git pull

git checkout -b <branch-name>
```

Once the desired changes have been made in the new branch, push a commit to `origin` by running the following commands:
```shell
git status

git add .

git commit --message "<message>"

git push --set-upstream origin <branch-name>

git log
```


### 9. Pull requests

The remaining step to actually trigger a deployment is to merge the feature branch into `main`, which is done by creating a new pull request in `Azure DevOps`:

[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> Pull requests -> New pull request

- Select your feature branch as the source and the `main` branch as the destination.  
- Under `Reviewers`, add the appropriate people to review and approve the pull request.
- Click `Create`.

In order to approve a pull request, follow these steps:

[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> Pull requests -> Active

- Click on the pull request in question.
- Click `Approve`.
- Click `Complete`, change `Merge type` to "Squash commit" and click `Complete merge`.
- Remove the feature branch locally by running:
```shell
git checkout main

git branch --delete <branch-name>

git pull --prune
```

If you ever need to revert the changes introduced in a pull request, follow these steps:

[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Repos -> Pull requests -> Completed

- Click on the pull request in question.
- Click `Revert` twice.
- Click `Create Pull Request` and follow the previous instructions on how to create and approve a pull request.


### 10. Environment approvals

To improve traceability and require approval between stages, the pipeline is configured with deployment jobs that reference the environment in question.  
In order to require approval for deployments to the `prod` environment, follow these steps:

[Azure DevOps](https://dev.azure.com/) -> \<org-name\> -> \<project-name\> -> Pipelines -> Environments -> prod -> More... -> Approvals and checks

Click the `Add check` icon, select `Approvals` and click `Next`.

Add the desired approvers, click `Advanced`, untick the checkbox `Allow approvers to approve their own runs` and click `Create`.