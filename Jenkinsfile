pipeline {
    agent any
    environment {
        PROJECT_ID = 'black-outlet-438804-p8' // GCP project ID
        GCP_CREDENTIALS = 'black-outlet-438804-p8-7ce3a755dbe1.json' // GCP service account key filename
        BUCKET_PATH = 'gs://bucket_2607/tf-k8-key' // GCS bucket path to store the credentials
        VM_NAME = 'software-automation-vm2' // Name of the VM to create
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

        stage('Verify Software Installations') {
            steps {
                // SSH into the VM and check installed software versions
                sh """
                    gcloud compute ssh ${VM_NAME} --zone ${VM_ZONE} --command "
                    echo 'Verifying installations...';
                    if command -v docker &> /dev/null; then
                        echo 'Docker version: \$(docker --version)';
                    else
                        echo 'Docker installation failed.';
                    fi;
                    if command -v helm &> /dev/null; then
                        echo 'Helm version: \$(helm version --short)';
                    else
                        echo 'Helm installation failed.';
                    fi;
                    if command -v terraform &> /dev/null; then
                        echo 'Terraform version: \$(terraform version)';
                    else
                        echo 'Terraform installation failed.';
                    fi;
                    if command -v ansible &> /dev/null; then
                        echo 'Ansible version: \$(ansible --version | head -n 1)';
                    else
                        echo 'Ansible installation failed.';
                    fi;
                    echo 'Verification completed.';
                    "
                """
            }
        }
    }

    post {
        always {
            // Optional: Clean up the Terraform resources (destroy the VM)
            // sh 'terraform destroy -auto-approve'
            echo "Pipeline completed successfully. The VM has been created and will remain available."
        }
    }
}
