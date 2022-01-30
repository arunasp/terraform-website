#!/bin/bash

##### 
##### AWS Website infrastructure management
##### This script is using Terraform to deploy website on AWS cloud services
##### 



##### Global variables

[ -z "${TERRAFORM_VERSION}" ] && export TERRAFORM_VERSION="1.1.4"
[ -z "${AWS_PROFILE}" ] && export AWS_PROFILE="default"
[ -z "${AWS_REGION}" ] && export AWS_REGION="eu-west-2"
[ -z "${WEBSITE_PROJECT}" ] && export WEBSITE_PROJECT="https://github.com/arunasp/terraform-website-files"
[ -z "${MODULES_REF}" ] && export MODULES_REF="main"
[ -z "${STACK}" ] && export STACK="website"
[ -z "${STAGE}" ] && export STAGE="dev"

[ -z "${TERRAFORM_S3_BUCKET}" ] && export TERRAFORM_S3_BUCKET="${STACK}-${STAGE}-${AWS_REGION}-terraform-state"

[ -z "${EC2_ADMIN_CIDR}" ] && export EC2_ADMIN_CIDR=""

##### 

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

##### Functions

function error()
{
 echo -e "${RED}Error:${NC} $1"
 exit 1
}

function setup_terraform()
{
processor=$(uname -m)

 if [ "$processor" == "x86_64" ]; then
   arch="amd64"
 elif [ "$processor" == "arm64" ]; then
   arch="arm64"
 else
   arch="386"
 fi

 case "$(uname -s)" in
   Darwin*)
     os="darwin_${arch}"
     ;;
   MINGW64*)
     os="windows_${arch}"
     ;;
   MSYS_NT*)
     os="windows_${arch}"
     ;;
   *)
     os="linux_${arch}"
     ;;
 esac

 echo -e "${GREEN}Downloading Terraform v${TERRAFORM_VERSION} local binary${NC}"
 [ ! -f "terraform/bin/terraform_"${TERRAFORM_VERSION}"_"${os}".zip" ] && \
  curl -so terraform/bin/terraform_"${TERRAFORM_VERSION}"_"${os}".zip https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_"${os}".zip
 pushd "terraform/bin"
 unzip -o terraform_"${TERRAFORM_VERSION}"_"${os}".zip
 popd
 # TODO: Link terraform.exe binary on Windows OS 
 [ -f ./terraform_x64 ] && rm -f ./terraform_x64
 ln -s "terraform/bin/terraform" ./terraform_x64
 rm -f tterraform/bin/erraform_"${TERRAFORM_VERSION}"_"${os}".zip
}


# Check for dependencies
function environment_check()
{
  [ -z $(which make) ] && error "Could not find make binary in system path. Please install Make and try again."
  [ -z $(which curl) ] && error "Could not find curl binary in system path. Please install CURL and try again."
  [ -z $(which unzip) ] && error "Could not find unzip binary in system path. Please install unzip and try again."
  [ -z $(which git) ] && error "Could not find git binary in system path. Please install Git and try again."
  [ -z $(which aws) ] && error "Could not find AWS-CLI binary in system path. Please install AWS-CLI from https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html and try again."
  [ ! -x ./terraform_x64 ] && setup_terraform

}

function aws_env()

{
 echo -e "${GREEN}Preparing AWS environment credentials${NC}"

 echo "AWS_ACCESS_KEY_ID=$(aws --profile ${AWS_PROFILE} configure get default.aws_access_key_id --profile '${AWS_PROFILE}')"  > .env-aws
 [ $? -ne 0 ] && error "could not get AWS access key ID. Exiting."
 echo "AWS_SECRET_ACCESS_KEY=$(aws --profile ${AWS_PROFILE} configure get default.aws_access_key_id --profile '${AWS_PROFILE}')" >> .env-aws
 [ $? -ne 0 ] && error "could not get AWS secret access key. Exiting."
 echo "AWS_ACCOUNT='$(aws --profile ${AWS_PROFILE} sts get-caller-identity --query Account --output text)'" >> .env-aws

 source ./.env-aws

 echo -e "${GREEN}Preparing Terraform environment variables${NC}"
 echo "bucket = \"${TERRAFORM_S3_BUCKET}\"" > terraform/backend.tfvars
 cat > terraform/terraform.tfvars <<EOC
create     = true
account_id = "${AWS_ACCOUNT}"
stack      = "${STACK}"
stage      = "${STAGE}"
region     = "${AWS_REGION}"
EOC

}

function terraform_check_s3_statefile()
{
  # Check if Terraform state bucket already exists
  echo -e "${GREEN}Checking Terraform state on AWS S3${NC}"
  aws --profile ${AWS_PROFILE} s3api head-bucket --bucket "${TERRAFORM_S3_BUCKET}" > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    echo -e "${GREEN}Initialising Terraform state bucket ${TERRAFORM_S3_BUCKET} on AWS S3${NC}"
    pushd terraform/bootstrap
    ../../terraform_x64 init
    [ $? -ne 0 ] && exit $?
    ../../terraform_x64 plan
    [ $? -ne 0 ] && exit $?
    ../../terraform_x64 apply -auto-approve
    [ $? -ne 0 ] && exit $?
    # Ensure we backup latest version of local Terraform state file to s3
    ../../terraform_x64 apply -auto-approve
    [ $? -ne 0 ] && exit $?
    popd
  else
      # Check if we have local Terraform state backup on AWS S3
      # And restore from backup if missing
      if [ ! -f terraform/bootstrap/terraform.tfstate -a ! -f terraform/bootstrap/terraform.tfstate.backup ]
      then
          aws s3api head-object --bucket "${TERRAFORM_S3_BUCKET}" --key bootstrap/terraform.tfstate > /dev/null 2>&1
          [ $? -eq 0 ] && aws --profile "${AWS_PROFILE}" s3 cp "s3://${TERRAFORM_S3_BUCKET}/bootstrap/terraform.tfstate" ./terraform/bootstrap/
          aws s3api head-object --bucket "${TERRAFORM_S3_BUCKET}" --key bootstrap/terraform.tfstate.backup > /dev/null 2>&1
          [ $? -eq 0 ] && aws --profile "${AWS_PROFILE}" s3 cp "s3://${TERRAFORM_S3_BUCKET}/bootstrap/terraform.tfstate.backup" ./terraform/bootstrap/
      fi
  fi

}

function terraform_bootstrap()
{
  environment_check
  aws_env
  terraform_check_s3_statefile
  if [ ! -f ec2_key ]
  then
       echo -e "${GREEN}Creating SSH key for EC2 remote access${NC}"
       ssh-keygen -f ec2_key -P "" -C "${USER}@terraform"
  fi
  # Use current machine external IP address when no EC2_ADMIN_CIDR environment variable is defined
  [ -z "${EC2_ADMIN_CIDR}" ] && echo -e "${GREEN}Retrieving your external IP address for EC2 access${NC}" || echo -e "${GREEN}using ${EC2_ADMIN_CIDR} values for EC2 access${NC}"
  [ -z "${EC2_ADMIN_CIDR}" ] && EXTERNAL_IP="$(curl -s 'https://api.ipify.org?format=text')" || echo -n
  retval="$?"
  [ ! -z "${EC2_ADMIN_CIDR}" ] && EXTERNAL_IP="${EC2_ADMIN_CIDR}"
  if [ "$retval" -ne 0 -o -z "${EXTERNAL_IP}" ]
  then
      read -p "Could not determine your external IP address. Please enter CIDR (v.x.y.z/mask): " EXTERNAL_IP
      if [ -z "${EXTERNAL_IP}" ]
      then
          echo -e "${RED}No CIDR entered, please update variable admin_cidr_blocks manually in terraform/terraform.tfvars${NC}"
          echo 'admin_cidr_blocks = ["127.0.0.0/8"]' >> terraform/terraform.tfvars
      else
          echo "admin_cidr_blocks = [\"${EXTERNAL_IP}\"]" >> terraform/terraform.tfvars
      fi
  else
      [ -z "${EC2_ADMIN_CIDR}" ] && echo "admin_cidr_blocks = [\"${EXTERNAL_IP}/32\"]" >> terraform/terraform.tfvars
      [ ! -z "${EC2_ADMIN_CIDR}" ] && echo "admin_cidr_blocks = [${EC2_ADMIN_CIDR}]" >> terraform/terraform.tfvars
  fi

  echo -e "\n${GREEN}Terraform bootstrap complete. Please run when ready:${NC} make create_website"

}

function terraform_init()
{
  environment_check
  terraform_check_s3_statefile
  module="$1"
  shift

  pushd terraform/"${module}"
  ../../terraform_x64 init -backend-config=backend.tfvars $*
  [ $? -ne 0 ] && error "Failed to initialise Terraform in ${module}"
  popd

}

function terraform_plan()
{
  module="$1"
  shift
  pushd terraform/"${module}"
  ../../terraform_x64 plan $*
  [ $? -ne 0 ] && error "Failed to run Terraform infrastructure plan in ${module}"
  popd

}

function terraform_deploy()
{
  module="$1"
  shift
  pushd terraform/"${module}"
  ../../terraform_x64 apply -auto-approve $*
  [ $? -ne 0 ] && error "Failed to run Terraform infrastructure deployment in ${module}"
  popd
}

function terraform_output()
{
  module="$1"
  shift
  pushd terraform/"${module}"
  ../../terraform_x64 output $*
  [ $? -ne 0 ] && error "Failed to retrieve Terraform module output in ${module}"
  popd
}

function terraform_state()
{
  module="$1"
  shift
  pushd terraform/"${module}"
  ../../terraform_x64 state $*
  [ $? -ne 0 ] && error "Failed to retrieve Terraform module state in ${module}"
  popd
}

function terraform_destroy()
{
  module="$1"
  shift
  pushd terraform/"${module}"
  ../../terraform_x64 destroy -auto-approve $*
  [ $? -ne 0 ] && error "Failed to remove Terraform infrastructure in ${module}"
  popd
}

function terraform_create_website()
{
  environment_check
  aws_env
  terraform_check_s3_statefile
  shift

  for tfmodule in site web-service
  do
    echo -e "${YELLOW}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Deploying $module ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    terraform_init $tfmodule
    terraform_plan $tfmodule
    terraform_deploy $tfmodule
    [ "$tfmodule" == "site" ] && terraform_update_website
  done
  echo -e "${GREEN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Website deployment complete. Please use address above in few minutes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
}

function terraform_update_website()
{
  environment_check
  aws_env
  pushd website
  echo -e "${GREEN}Fetching files from Git reporitory ${WEBSITE_PROJECT}...${NC}"
  rm -rf ./files
  git clone -q --branch "${MODULES_REF}" "${WEBSITE_PROJECT}/" ./files/
  [ $? -ne 0 ] && error "Could not retrieve files. Exiting."
  rm -rf ./files/.git
  pushd ./files
  echo -e "${GREEN}Uploading files to S3 bucket s3://${STACK}-${STAGE}-"${AWS_REGION}"-website/${NC}"
  aws --profile "${AWS_PROFILE}" s3 sync ./ "s3://${STACK}-${STAGE}-"${AWS_REGION}"-website/"
  [ $? -ne 0 ] && error "Could not upload files to AWS S3. Exiting."
  echo -e "${GREEN}S3 bucket s3://${STACK}-${STAGE}-"${AWS_REGION}"-website/ update completed successfully.${NC}"
  popd
  popd
}

function terraform_clean()
{
  pushd terraform/$1
  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup website/files
  popd

}

function terraform_wipe()
{
  environment_check
  aws_env
  terraform_check_s3_statefile
  for module in web-service site bootstrap
  do
    echo -e "${YELLOW}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Removing $module from AWS Terraform managed infrastructure ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    terraform_init $module
    terraform_destroy $module
    terraform_clean $module
  done

}


function help()
{
  cat << EOF
AWS Website deployment using Terraform script.

Format: $(basename $0) <target> <component> <target arguments>

Avilable targets:

    bootstrap      - First time setup
    init           - Terraform init operations
    plan           - Prepare AWS infrastructure Terraform components deployment plan.
    tfplan         - Execute Terraform plan (skip init).
    deploy         - Deploy AWS infrastructure components.
    create_website - Create AWS site infrastructure and deploy website
    website        - Launch Terraform bootstrap and deploy full AWS infrastructure."
    update_website - Clone website git source to S3 for content updates
    tfstate        - Check and create AWS s3 Terraform state bucket
    state          - Terraform state operations
    output          - Show deployed module outputs
    clean          - Clean Terraform state and temporary files
    destroy        - Remove managed Terraform infrastructure components.
    wipe           - Remove managed Terraform infrastructure and clean repository

EOF
}


## Main script

cd $(dirname "$0")


case $1 in
    bootstrap)
    shift
    terraform_bootstrap
    ;;

    init)
    shift
    terraform_init $*
    ;;

    plan)
    shift
    terraform_init $*
    terraform_plan $*
    ;;

    tfplan)
    shift
    terraform_plan $*
    ;;

    deploy)
    shift
    terraform_deploy $*
    ;;

    output)
    shift
    terraform_output $*
    ;;

    state)
    shift
    terraform_state $*
    ;;

    destroy)
    shift
    terraform_destroy $*
    ;;

    create_website)
    terraform_create_website $*
    ;;

    website)
    terraform_bootstrap
    terraform_create_website $*
    ;;

    update_website)
    terraform_update_website $*
    ;;

    tfstate)
    terraform_check_s3_statefile $*
    ;;

    clean)
    echo -e "${GREEN}Cleaning generated files${NC}"
    for module in bootstrap site web-service
    do
      terraform_clean $module
    done
    rm -rf terraform_x64 terraform/bin/terraform ec2_key ec2_key.pub website/files
    cp -f /dev/null .env-aws
    cp -f /dev/null terraform/backend.tfvars
    cp -f /dev/null terraform/terraform.tfvars
    ;;

    wipe)
    echo -e "${RED}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Removing Terraform managed AWS infrastructure ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    terraform_wipe
    $0 clean
    ;;

    *)
    help
    ;;
esac
