pipeline {

    parameters {
        string(name: "DockerHubRepo", defaultValue: "mywebapp_boxfuser")
        string(name: "DockerHubLogin")
        password(name: "DockerHubPassword")
        password(name: "AWS_ACCESS_KEY")
        password(name: "AWS_SECRET_KEY")
    }

    agent any

    environment {
        AWS_ACCESS_KEY     ="${AWS_ACCESS_KEY}"
        AWS_SECRET_KEY = "${AWS_SECRET_KEY}"
        sshec2key = 'AWS_UBUNTU_INSTANCE_SSH_KEY'
    }


    stages {

        stage('Terraform init and plan') {
            steps {
                sh 'terraform init -input=false'
                sh "terraform plan -input=false -out tfplan"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Apply Terraform plan and obtain IPs of the instances created') {
            steps {
                sh "terraform apply -input=false tfplan"
                script {
                    builder_public_ip = sh(
                       script: "terraform output -raw builder_ip_name",
                       returnStdout: true
                    ).trim()
                    webserver_public_ip = sh(
                       script: "terraform output -raw webserver_ip_name",
                       returnStdout: true
                    ).trim()
                }
            }
        }


        stage('Prepare instances via Ansible') {

            steps {
                sh "if [ -f hosts ]; then rm hosts; fi"
                sh "echo '[builder]' >> hosts"
                sh "[ '${builder_public_ip}' = '' ] || echo ${builder_public_ip} >> hosts"
                sh "echo '[webserver]' >> hosts"
                sh "[ '${webserver_public_ip}' = '' ] || echo ${webserver_public_ip} >> hosts"
                
                ansiblePlaybook(
                    playbook: 'readiness.yml',
                    inventory: 'hosts',
                    credentialsId: "${sshec2key}",
                    disableHostKeyChecking: false,
                    become: true,
                )
            }
        } 

        stage('Build and push Docker image') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${builder_public_ip}"
            }
            steps {
                sshagent( credentials:["${sshec2key}"] ) {
                    sh "docker build -t ${DockerHubLogin}/${DockerHubRepo}:latest ."
                    sh "echo ${DockerHubPassword} | docker login -u ${DockerHubLogin} --password-stdin"
                    sh "docker push ${DockerHubLogin}/${DockerHubRepo}:latest"

                }
            }
        }

        stage('Delete existing docker containers') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${webserver_public_ip}"
            }
            steps {
                sshagent( credentials:["${sshec2key}"] ) {
                    sh "for ID in \$(docker ps -q); do docker stop \$ID; done"
                    sh "for ID in \$(docker ps -a -q); do docker rm \$ID; done"
                    sh "for ID in \$(docker images -q); do docker rmi \$ID; done"
                }
            }
        }

        stage('Run Docker container on the websrever') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${webserver_public_ip}"
            }
            steps {
                sshagent( credentials:["${sshec2key}"] ) {
                    sh "docker run -d -p 8080:8080 ${DockerHubLogin}/${DockerHubRepo}"
                    echo "########################################################################################"
                    echo "########################################################################################"
                    echo "########################################################################################"
                    echo "### go to http://${webserver_public_ip}:8080/hello-1.0/"
                    echo "########################################################################################"
                    echo "########################################################################################"
                    echo "########################################################################################" }
                }
            }

    } 
}