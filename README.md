# Changelog
- Kubernetes Cluster deployment using Ansible, Docker & Jenkins on Vmware platform.
- This deployment will setup a Kubernetes Cluster of:
  - Master Node: 1
  - Worker Nodes: 3
- Mediawiki deployment along with MariaDB on kubernetes platform using nodeport based service method.

![k8d-deployment-diagram](https://user-images.githubusercontent.com/1809177/221905263-ed62dbde-7983-46f8-ad0d-fb490dc168eb.png)


## [v1.0] - 13-03-2022 (dd-mm-yyyy)

### Ansible Roles for:
  - VM Management:
    - vmdeploy
    - gocustom
    - vmdelete
  - VM Snapshot Management:
    - vmsnapshot
    - vmsnapshotrevert
    - vmsnapshotremove
  - Kubernetes Cluster Management:
    - mastersetup
    - nodesetup
    - nodelabel

### Mediawiki Code:
  - K8s deployment files:
    - networkpolicy.yaml
    - configmap.yaml
    - secrets.yaml
    - mariadb-deployment.yaml
    - mediawiki-deployment.yaml
  - Service type:
    - NodePort
  - NodePort number:
    - 30100

### Platform Software support
  - alpine: 3.17
  - ansible: 7.1.0
  - ansible-core: 2.14.1
  - pyvmomi: 7.0.3
  - vSphere-Automation-SDK: 1.71.0

### Kubernetes Packages:
  - cri-o:   1.24.4
  - kubelet: 1.26.1
  - kubeadm: 1.26.1
  - kubectl: 1.26.1

### Mediawiki & MariaDB docker images
  - Mediawiki: 1.39.2
  - MariaDB: 10.11.2

### Jenkins file name
  - Jenkinsfile

### Dockerfile for Infra deployment
  - alpinedevops.dockerfile

## Docker image build process
- To build the docker image, use the below command:

  > $ docker build --no-cache=true -f <file_name>.dockerfile -t <docker_registry>/alpinedevops:latest

- To login to the hub.docker.com, use the below command:

  > $ docker login

- To push the docker image, use the below command:

  > $ docker push <docker_registry>/alpinedevops:latest

## Deployment Guide:

### VM Management
- To deploy the linux server, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "deploy"

- To do the guest os customization, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "oscustom"

- To delete the linux server use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "delete"

### VM Snapshot Management
- To take the vm snapshots, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "vmsnapshot"

- To revert the vm snapshot, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "vmsnapshotrevert"

- To remove the vm snapshot, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "vmsnapshotremove"

### Kubernetes Cluster Management
- To deploy & configure the kubernetes master, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "mastersetup"

- To deploy & configure the kubernetes worker nodes, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "nodesetup"

- To label the kubernetes worker nodes, use the below command:

  > ansible-playbook -i inventory containerlab.yaml --tags "nodelabel"

### Mediawiki deployment on kubernetes cluster
- Deployment flow & their respectrive files:
  - Step1: namespace(namespace-mediawiki.yaml)
  - Step2: configmap(configmap.yaml)
  - Step3: secret(secrets.yaml)
  - Step4: networkpolicy(networkpolicy.yaml)
  - Step5: mariadb & meriadb-service(mariadb-deployment.yaml)
  - Step6: mediawiki & mediawiki-service(mediawiki-deployment.yaml)

- Applictaion Access:
  - Once the deployment is done, mediawiki service can be accessed on [http://<kubernetes_master_ip>:30100](http://<kubernetes_master_ip>:30100) with in the same network.
  - If not interested to use the kubernetes master IP, a proxy can be configured to point to a proper DNS name and port to mask the above link with in the corporate network.
  - In public cloud , it can be done via a LoadBalancer. Just need to change the Service type to LoadBalancer and have the correct DNS mapping of the public IP in the DNS domain.

- Credentials for the deployment:
  - Credentials are managed in the secrets.yaml file but encoded with base64. Following syntax can be used to encode and decode:
  - To encode the credentials:
    > echo -n '<plain_text_content>' | base64
  - To decode the credentials:
    > echo -n '<encoded_content>' | base64 --decode

- Application need some additional configurtaion post deployment to make the application usable. Hence following information will be required for the configuration:
  - dbserver: mariadb-internal-service:3306
  - dbuser: root
  - dbpassword: secret
  - dbname: wikimediadb

- This deployment will create a hostPath mapping from the kubernetes worker node to the container via '/opt/mediawiki-data'. Once the post deployment setup is done, it will generate a 'LocalSettings.php' file which is required to access the applictaion. Copy it to '/opt/mediawiki-data' location on the node where the container is running and make a softlink to the deployment location by getting into the container. Following steps will help to achieve it:

  - Run the below command to get the node where the mediawiki container is running:
    > kubectl get pods -o wide -n mediawiki

  - SSH to the node and get the mediawiki container ID by using the below command:
    - > crictl ps -a
    - > crictl exec -it <container_id> /bin/bash
    - > cd /var/www/html
    - > ln -s /opt/mediawiki-data/LocalSettings.php LocalSettings.php
    - > exit

### TODO
  - A persistent volume to maintain the LocalSettings.php file for containers
  - Linking of 'LocalSettings.php' file in the running container
  - REST API based post deployment configuration for Mediawiki. Its supported but need some additional configuration to handle the deployment via kubernetes.
