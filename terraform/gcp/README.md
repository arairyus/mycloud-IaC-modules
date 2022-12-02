# GCP IaC

## Terraform

### TIPS

Check your project api enabled

```sh
gcloud services list --available
gcloud services enable SERVICE_NAME
```

When you run terraform, the terraform.tfvars file in the current directory and a suffix file named \*.auto.tfvars are automatically loaded.

### Auth

This repository use your cloud credentials.
To use your gcloud credentials, run

```sh
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

### Use

```sh
terraform plan --var-file secret.tfvars
terraform apply --var-file secret.tfvars
```
