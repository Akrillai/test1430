# Certification Task

1) Launch Orchestrator Server
    -1a. Install Jenkins (plugins: SSH Agent, Ansible, Terraform, Mask Password, Docker), terraform, aws cli, ansible 

2) Jenkins: Pipeline script from SCM (https://github.com/Akrillai/test1430.git) + add to Jenkins credentials your AWS private key (please create in AWS if needed) to establish ssh connectivity: 
   Kind: *SSH Username with private key*  
   ID: *AWS_UBUNTU_INSTANCE_SSH_KEY*  
   Username: *ubuntu*
   
   Jenkins File user inputs:
        - string(name: "DockerHubRepo", defaultValue: "mywebapp_boxfuser")
        - string(name: "DockerHubLogin")
        - password(name: "DockerHubPassword")
        - password(name: "AWS_ACCESS_KEY")
        - password(name: "AWS_SECRET_KEY")

   
3) Jenkins pipeline description: terraform launches two identical ec2 instances, attaching an existing private key to them and writing out the created instances' public IPs. Then, ansible hosts get automatically updated with those recorded public IPS and a playbook (readiness.yml) prepares both servers (builder and webserver) by installing on them all the dependencies (i.e. Docker) and putting on the build server src+pom.xml to maven-package the java boxfuse app and create a .jar artefact. Then, a DOCKERFILE creates a tomcat container and loading that jar to the webapps dir. Then, the container gets published to the docker hub. After that, we run that published container on the web server where it hosted. The pipeline is rerunnable because the existing container gets destroyed every time before a new one is created.


4) To Destroy the infrastructure go to /var/lib/jenkins/workspace/****job_name****
   terraform destroy