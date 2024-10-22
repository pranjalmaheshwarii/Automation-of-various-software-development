pipeline {
    agent any
    environment {
        SSH_KEY_FILE = 'jenkins_ssh_key' // Name of the SSH key file (private key)
        PROJECT_ID = 'black-outlet-438804-p8' // GCP project ID
        GCP_CREDENTIALS = 'black-outlet-438804-p8-7ce3a755dbe1.json' // GCP service account key filename
        BUCKET_PATH = 'gs://bucket_2607/tf-k8-key' // GCS bucket path to store the credentials
        VM_NAME = 'software-automation-vm' // Name of the VM to create
        VM_ZONE = 'us-central1-a' // GCP zone where the VM will be created
    }
    stages {
        stage('Generate SSH Key') {
            steps {
                script {
                    // Generate SSH key pair dynamically
                    sh 'ssh-keygen -t rsa -b 4096 -f ${SSH_KEY_FILE} -q -N ""'
                }
            }
        }

        stage('Download GCP Service Account Key') {
            steps {
                // Download the JSON key from the GCS bucket
                sh '''
                gsutil cp ${BUCKET_PATH}/${GCP_CREDENTIALS} .
                '''
            }
        }

        stage('Terraform Init & Apply - Create VM') {
            steps {
                // Initialize Terraform
                sh 'terraform init'

                // Apply Terraform to create the GCP VM
                sh '''
                terraform apply -var="project_id=${PROJECT_ID}" \
                                -var="credentials_path=./${GCP_CREDENTIALS}" \
                                -var="vm_name=${VM_NAME}" \
                                -var="vm_zone=${VM_ZONE}" \
                                -auto-approve
                '''
            }
        }

        stage('Add SSH Key to GCP VM Metadata') {
            steps {
                script {
                    def vm_ip = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()

                    // Add public key to GCP VM metadata using gcloud CLI
                    sh """
                    gcloud compute instances add-metadata ${VM_NAME} \
                    --metadata ssh-keys="jenkins-user:${readFile('${SSH_KEY_FILE}.pub')}" \
                    --zone ${VM_ZONE} \
                    --project ${PROJECT_ID}
                    """
                }
            }
        }

        stage('Install Prerequisite Software on VM') {
            steps {
                script {
                    def vm_ip = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()

                    // Install Docker, Helm, Terraform, kubectl, Terragrunt, Ansible, etc.
                    sshagent (credentials: ['gcp-ssh-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} jenkins-user@${vm_ip} << EOF
                        sudo apt update
                        sudo apt install -y docker.io
                        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                        sudo apt-get install -y software-properties-common
                        sudo add-apt-repository --yes --update ppa:ansible/ansible
                        sudo apt install -y ansible
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com \$(lsb_release -cs) main"
                        sudo apt-get update && sudo apt-get install terraform
                        sudo apt-get install -y wget
                        wget -O /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.31.0/terragrunt_linux_amd64
                        chmod +x /usr/local/bin/terragrunt
                        sudo snap install kubectl --classic
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

                    // Verify the installations of the tools
                    sshagent (credentials: ['gcp-ssh-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} jenkins-user@${vm_ip} << EOF
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
            // Optional: Clean up the Terraform resources (destroy the VM)
            sh 'terraform destroy -auto-approve'
        }
        cleanup {
            // Clean up generated SSH keys
            sh 'rm -f ${SSH_KEY_FILE} ${SSH_KEY_FILE}.pub'
        }
    }
}
