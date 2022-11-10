pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
		DOCKERHUB_CREDENTIALS=credentials('dockerhub')
        sshCredsID = 'AWS_UBUNTU_INSTANCE_SSH_KEY'
    }


    options([
    parameters([
        password(name: 'KEY', description: 'Encryption key')
                ])  
            ])  


    stages {

        stage('Plan') {
            steps {
                sh 'terraform init -input=false'
                sh "terraform plan -input=false -out tfplan"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Apply') {
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


        stage('Ansible playbook') {

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


        stage('Builder fetch and build') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${builderDnsName}"
            }
            steps {
                sshagent( credentials:["${sshCredsID}"] ) {
                    sh "docker build -t brandani/mywebapp_boxfuser:latest ."
                    // sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh "echo ${KEY} | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh 'docker push brandani/mywebapp_boxfuser:latest'

                }
            }
        }

        stage('Webserver stop and remove') {
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

        stage('Run Docker container on remote hosts') {
            environment {
                DOCKER_HOST="ssh://ubuntu@${webserverDnsName}"
            }
            steps {
                sshagent( credentials:["${sshCredsID}"] ) {
                    sh "docker run -d -p 8080:8080 brandani/mywebapp_boxfuser"
                    echo "########################################################################################"
                    echo "### go to http://${webserverDnsName}:8080/hello-1.0/"
                    echo "########################################################################################"}
                }
            }

    } 
}