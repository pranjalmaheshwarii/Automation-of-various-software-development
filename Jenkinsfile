pipeline {
    agent any
    environment {
        GOOGLE_CREDENTIALS = credentials('gcp-terraform-service-account') // Set the ID of the GCP credentials
        SSH_KEY = credentials('gcp-ssh-key') // Set the SSH Key credential ID
        PROJECT_ID = "black-outlet-438804-p8"
    }
    stages {
        stage('Download GCP Service Account Key') {
            steps {
                // Download the JSON key from the GCS bucket to the Jenkins workspace
                sh '''
                gsutil cp gs://bucket_2607/tf-k8-key/black-outlet-438804-p8-7ce3a755dbe1.json .
                '''
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
                
                // Run Terraform apply to create the VM in GCP using the downloaded JSON key
                sh '''
                terraform apply -var="project_id=${PROJECT_ID}" \
                                -var="credentials_path=./black-outlet-438804-p8-7ce3a755dbe1.json" \
                                -auto-approve
                '''
            }
        }

        stage('Install Prerequisites') {
            steps {
                script {
                    def vm_ip = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()

                    // Install Docker
                    sshagent(['SSH_KEY']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no your-ssh-user@${vm_ip} \
                        'sudo apt update && sudo apt install -y docker.io'
                        """
                    }

                    // Install Helm, Terraform, Terragrunt, kubectl, and Ansible
                    sshagent(['SSH_KEY']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no your-ssh-user@${vm_ip} << EOF
                        # Install Helm
                        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                        
                        # Install Terraform
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                        sudo apt-get update && sudo apt-get install terraform

                        # Install Terragrunt
                        wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.16/terragrunt_linux_amd64
                        sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
                        sudo chmod +x /usr/local/bin/terragrunt

                        # Install kubectl
                        sudo apt-get install -y apt-transport-https ca-certificates curl
                        sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
                        echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
                        sudo apt-get update
                        sudo apt-get install -y kubectl

                        # Install Ansible
                        sudo apt-get install -y ansible
                        EOF
                        """
                    }
                }
            }
        }

        stage('Verify Installation') {
            steps {
                script {
                    def vm_ip = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()

                    // Check if installations were successful
                    sshagent(['SSH_KEY']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no your-ssh-user@${vm_ip} << EOF
                        docker --version
                        helm version
                        terraform version
                        terragrunt --version
                        kubectl version --client
                        ansible --version
                        EOF
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up the Terraform state (optional)
            sh 'terraform destroy -auto-approve'
        }
    }
}
