# Changelog
- Kubernetes Cluster deployment using Ansible, Docker & Jenkins on Vmware platform.
- This deployment will setup a Kubernetes Cluster of:
  - Master Node: 1
  - Worker Nodes: 3
- Mediawiki deployment along with MariaDB on kubernetes platform using nodeport based service method.

![k8d-deployment-diagram](https://user-images.githubusercontent.com/1809177/221905263-ed62dbde-7983-46f8-ad0d-fb490dc168eb.png)


## [v1.1] - 18-03-2022 (dd-mm-yyyy)

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

### Container OS
  - rockylinux: 8

### Mediawiki & MariaDB docker images
  - Mediawiki: 1.39.2
  - MariaDB: 10.11.2

### Jenkins file name
  - Jenkinsfile

### Docker files
  - Infra deployment:
    - alpinedevops.dockerfile
  - Mediawiki:
    - mediawiki.dockerfile

## Docker image build process
- To build the docker image, use the below command:

  > $ docker build --no-cache=true -f <file_name>.dockerfile -t docker_registry/reponame:tag

- To login to the hub.docker.com, use the below command:

  > $ docker login

- To push the docker image, use the below command:

  > $ docker push docker_registry/reponame:tag


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

- To deploy the above kubernets sequentially by following below command:
  > kubectl create -f <file_name>.yaml

- Mediawiki container's environmental variables:
  - Environmental variables with default values (Change them as required)
    - DB_NAME: wikimediadb
    - DB_SERVER: mariadb-internal-svc
    - DB_PORT: 3306
    - DB_INSTALL_USER: root
    - DB_INSTALL_PASSWORD: root_secret
    - DB_USER: wikiuser
    - DB_PASSWORD: wikipassword
    - MEDIAWIKI_SERVER_URL: wiki.example.com
    - NODE_PORT: 31000
    - MEDIAWIKI_SCRIPT_PATH: /wiki
    - MEDIAWIKI_SITE_LANG: en
    - MEDIAWIKI_ADMIN_PASSWORD: Hell0Wiki123
    - MEDIAWIKI_SITE_NAME: First_Site
    - MEDIAWIKI_ADMIN_USER: admin

- Mediawiki container entrypoint:
  - Once the mediawiki installation is done, its having a container entrypoint to configure.
  - The configuration has to be done from CLI under `/var/www/html` directory.
  - It will generate `LocalSettings.php` file which is required to access the Mediawiki UI. 
  - The CLI command should be something like the below one:
    > php maintenance/install.php --dbname=xxxxxxxx --dbserver=mariadb-internal-service:3306 --installdbuser=xxxxxx --installdbpass=xxxxxxxx --dbuser=xxxxxxxx --dbpass=xxxxxxxxxx --server="http://<kubernetes_master_ip>:<Node_Port>" --scriptpath=/wiki --lang=en --pass=xxxxxxxxxxx "First_Site" "admin"

- Applictaion Access:
  - Once the deployment is done, mediawiki service can be accessed on [http://<kubernetes_master_ip>:<Node_Port>](http://<kubernetes_master_ip>:<Node_Port>) with in the same network.
  - If not interested to use the kubernetes master IP, a proxy can be configured to point to a proper DNS name and port to mask the above link with in the corporate network.
  - In public cloud , it can be done via a LoadBalancer. Just need to change the Service type to LoadBalancer and have the correct DNS mapping of the public IP in the DNS domain.

- Credentials for the deployment:
  - Credentials should be managed in the `secrets.yaml` file & encoded with base64.
  - To encode the credentials:
    > echo -n '<plain_text_content>' | base64
  - To decode the credentials:
    > echo -n '<encoded_content>' | base64 --decode

- Configuration variables for kubernetes
  - All the configuration related variables should be managed in `configmap.yaml` file
