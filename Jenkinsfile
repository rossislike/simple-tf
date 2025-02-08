pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1' 
    }
    stages {
        stage('Set AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins' 
                ]]) {
                    sh '''
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
                    aws sts get-caller-identity
                    '''
                }
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/rossislike/simple-tf' 
            }
        }
        stage('Initialize Terraform') {
            steps {
                sh '''
                terraform init
                '''
            }
        }
        stage('Plan Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform plan -out=tfplan
                    '''
                }
            }
        }
        stage('Snyk Security Scan') {
            steps {
                sh '''
                # Install Snyk CLI (if not already installed)
                npm install -g snyk

                # Authenticate with Snyk (replace with your Snyk API token)
                snyk auth $SNYK_TOKEN

                # Scan the Terraform code for vulnerabilities
                snyk iac test --directory=.
                '''
            }
            environment {
                SNYK_TOKEN = credentials('snyk-token') // Assuming you have a Jenkins credential named 'snyk-token'
            }
        }
        stage('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'Terraform deployment completed successfully!'
        }
        failure {
            echo 'Terraform deployment failed!'
        }
    }
}
