pipeline {

    parameters {
        string(name: "DockerHubRepo", defaultValue: "mywebapp_boxfuser")
        string(name: "DockerHubLogin")
        password(name: "DockerHubPassword")
        password(name: "AWS_ACCESS_KEY_ID")
        password(name: "AWS_SECRET_ACCESS_KEY")
    }

    agent any

    environment {
        // AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        // AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_ACCESS_KEY_ID     ="${AWS_ACCESS_KEY_ID}"
        AWS_SECRET_ACCESS_KEY = "${AWS_SECRET_ACCESS_KEY}"
        sshCredsID = 'AWS_UBUNTU_INSTANCE_SSH_KEY'
    }


    stages {

        stage('Terraform init and plan') {
            steps {
                sh 'terraform init -input=false'
                sh "terraform plan -input=false -out tfplan"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Apply Terraform plan') {
            steps {
                sh "terraform apply -input=false tfplan"
                script {
                    builderDnsName = sh(
                       script: "terraform output -raw builder_dns_name",
                       returnStdout: true
                    ).trim()
                    webserverDnsName = sh(
                       script: "terraform output -raw webserver_dns_name",
                       returnStdout: true
                    ).trim()
                }
            }
        } 


        stage('Prepare instances via Ansible') {

            steps {
                sh "if [ -f hosts ]; then rm hosts; fi"
                sh "echo '[builder]' >> hosts"
                sh "[ '${builderDnsName}' = '' ] || echo ${builderDnsName} >> hosts"
                sh "echo '[webserver]' >> hosts"
                sh "[ '${webserverDnsName}' = '' ] || echo ${webserverDnsName} >> hosts"
                ansiblePlaybook(
                    playbook: 'readiness.yml',
                    inventory: 'hosts',
                    credentialsId: "${sshCredsID}",
                    disableHostKeyChecking: false,
                    become: true,
                )
            }
        } 

        stage('Build and push Docker image') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${builderDnsName}"
            }
            steps {
                sshagent( credentials:["${sshCredsID}"] ) {
                    sh "docker build -t ${DockerHubLogin}/${DockerHubRepo}:latest ."
                    sh "echo ${DockerHubPassword} | docker login -u ${DockerHubLogin} --password-stdin"
                    sh "docker push ${DockerHubLogin}/${DockerHubRepo}:latest"

                }
            }
        }

        stage('Delete existing docker containers') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${webserverDnsName}"
            }
            steps {
                sshagent( credentials:["${sshCredsID}"] ) {
                    sh "for ID in \$(docker ps -q); do docker stop \$ID; done"
                    sh "for ID in \$(docker ps -a -q); do docker rm \$ID; done"
                    sh "for ID in \$(docker images -q); do docker rmi \$ID; done"}
                }
            }

        stage('Run Docker container on the websrever') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${webserverDnsName}"
            }
            steps {
                sshagent( credentials:["${sshCredsID}"] ) {
                    sh "docker run -d -p 8080:8080 ${DockerHubLogin}/${DockerHubRepo}"
                    echo "########################################################################################"
                    echo "### go to http://${webserverDnsName}:8080/hello-1.0/"
                    echo "########################################################################################"}
                }
            }

    } 
}