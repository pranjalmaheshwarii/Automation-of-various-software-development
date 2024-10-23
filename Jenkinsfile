pipeline {
    agent any
    environment {
        PROJECT_ID = 'black-outlet-438804-p8' // GCP project ID
        GCP_CREDENTIALS = 'black-outlet-438804-p8-7ce3a755dbe1.json' // GCP service account key filename
        BUCKET_PATH = 'gs://bucket_2607/tf-k8-key' // GCS bucket path to store the credentials
        VM_NAME = 'software-automation-vm' // Name of the VM to create
        VM_ZONE = 'us-central1-a' // GCP zone where the VM will be created
        VM_IP = '' // Placeholder for the VM IP address
    }
    
    stages {
        stage('Download GCP Service Account Key') {
            steps {
                // Download the JSON key from the GCS bucket
                sh 'gsutil cp ${BUCKET_PATH}/${GCP_CREDENTIALS} .'
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
                
                // Run a Terraform plan to check for changes
                sh 'terraform plan -var="project_id=${PROJECT_ID}" \
                                   -var="credentials_path=./${GCP_CREDENTIALS}" \
                                   -var="vm_name=${VM_NAME}" \
                                   -var="vm_zone=${VM_ZONE}"'
            }
        }

        stage('Terraform Apply - Create VM') {
            steps {
                // Apply Terraform to create the GCP VM
                sh 'terraform apply -var="project_id=${PROJECT_ID}" \
                                   -var="credentials_path=./${GCP_CREDENTIALS}" \
                                   -var="vm_name=${VM_NAME}" \
                                   -var="vm_zone=${VM_ZONE}" \
                                   -auto-approve'
            }
        }

        stage('Capture VM IP') {
            steps {
                script {
                    // Capture the VM IP address from Terraform output
                    VM_IP = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    echo "VM IP: ${VM_IP}"
                }
            }
        }
    }

    post {
        always {
            // Optional: Clean up the Terraform resources (destroy the VM)
            //sh 'terraform destroy -auto-approve'
            echo "Pipeline completed successfully. The VM has been created and will remain available."
        }
    }
}
