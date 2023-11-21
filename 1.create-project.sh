#!/bin/bash
set -e

# Set your desired project ID and name
PROJECT_PREFIX="prj-futurae"
PROJECT_NAME="Futurae assignment"

# 

#PROJECT_ID_HASH=$(echo $RANDOM | md5sum | head -c 4)
PROJECT_ID_HASH="d51c"
PROJECT_ID="$PROJECT_PREFIX"-"$PROJECT_ID_HASH"

# Check if the project exists
if gcloud projects describe "$PROJECT_ID" &>/dev/null; then
  echo "Project $PROJECT_ID' already exists."
else
  # Create the new project
  gcloud projects create "$PROJECT_ID" --name="$PROJECT_NAME"
  echo "Project '$PROJECT_ID' created"
fi 

# Set the project configuration
gcloud config set project "$PROJECT_ID"
echo "Project '$PROJECT_ID' set as the default project."

#update terraform variables values 
echo "Update values in variables.auto.tfvars"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
PROJECT_REGION=$(gcloud config get-value compute/region)
sed -i "s/^project_id = .*/project_id = \"$PROJECT_ID\"/" variables.auto.tfvars
sed -i "s/^project_number = .*/project_number = \"$PROJECT_NUMBER\"/" variables.auto.tfvars
sed -i "s/^project_region = .*/project_region = \"$PROJECT_REGION\"/" variables.auto.tfvars
TERRAFORM_STATE_BUCKET=$PROJECT_PREFIX-terraform-state-$PROJECT_ID_HASH
sed -i "s/bucket = .*/bucket = \"$TERRAFORM_STATE_BUCKET\"/" backend.tf


#create PROJECT_ID environmental variable
export PROJECT_ID=$PROJECT_ID

#Obtains user access credentials via a web , to be used locally  instead of service account
gcloud auth application-default login

#create terraform state bucket
# Run gsutil ls -b to check if the bucket exists
if gsutil ls -b gs://$TERRAFORM_STATE_BUCKET &> /dev/null; then
  echo "Bucket '$TERRAFORM_STATE_BUCKET' exists."
else
  echo "Creating Bucket '$TERRAFORM_STATE_BUCKET' "
  gcloud storage buckets create gs://$TERRAFORM_STATE_BUCKET \
  --project=$PROJECT_ID \
  --default-storage-class=STANDARD \
  --location="europe-west1" \
  --uniform-bucket-level-access
fi
#set versioning on terraform state bucket to ensure terraform rollback
gcloud storage buckets update gs://$TERRAFORM_STATE_BUCKET --versioning






