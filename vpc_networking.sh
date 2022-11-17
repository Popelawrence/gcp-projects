#!/bin/bash

#lawrenceakinro@gmail.com

#Task1: Explore the default network.

gcloud projects list

gcloud compute networks list

#View the subnets:
gcloud compute networks subnets list --sort-by=NETWORK

#View the routes:
gcloud compute routes list

#View the firewall rules:
gcloud compute firewall-rules list

#Delete network firewall rules

gcloud compute firewall-rules delete default-allow-icmp

gcloud compute firewall-rules delete default-allow-internal

gcloud compute firewall-rules delete default-allow-rdp

gcloud compute firewall-rules delete default-allow-ssh

#Delete the default VPC network
gcloud compute networks delete default

#attempt to create a VM failed because there is no VPC network.


#Task2: Create an auto mode network

gcloud compute networks create mynetwork --project=qwiklabs-gcp-02-e65ac4f37e6a --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional

gcloud compute firewall-rules create mynetwork-allow-custom --project=qwiklabs-gcp-02-e65ac4f37e6a --network=projects/qwiklabs-gcp-02-e65ac4f37e6a/global/networks/mynetwork --description=Allows\ connection\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ custom\ protocols. --direction=INGRESS --priority=65534 --source-ranges=10.128.0.0/9 --action=ALLOW --rules=all

gcloud compute firewall-rules create mynetwork-allow-icmp --project=qwiklabs-gcp-02-e65ac4f37e6a --network=projects/qwiklabs-gcp-02-e65ac4f37e6a/global/networks/mynetwork --description=Allows\ ICMP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network. --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=icmp

gcloud compute firewall-rules create mynetwork-allow-rdp --project=qwiklabs-gcp-02-e65ac4f37e6a --network=projects/qwiklabs-gcp-02-e65ac4f37e6a/global/networks/mynetwork --description=Allows\ RDP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ port\ 3389. --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=tcp:3389

gcloud compute firewall-rules create mynetwork-allow-ssh --project=qwiklabs-gcp-02-e65ac4f37e6a --network=projects/qwiklabs-gcp-02-e65ac4f37e6a/global/networks/mynetwork --description=Allows\ TCP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ port\ 22. --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=tcp:22



#gcloud compute instances create mynet-us-vm --zone=us-central1-c --machine-type=n1-standard1

#create mynet-us-vm instance in us-central1-c:
gcloud compute instances create mynet-us-vm --project=qwiklabs-gcp-02-e65ac4f37e6a --zone=us-central1-c --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=mynetwork --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=714012279690-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=mynet-us-vm,image=projects/debian-cloud/global/images/debian-10-buster-v20221102,mode=rw,size=10,type=projects/qwiklabs-gcp-02-e65ac4f37e6a/zones/us-central1-c/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

#create mynet-eu-vm instance in europe-west1-c:
gcloud compute instances create mynet-eu-vm --project=qwiklabs-gcp-02-e65ac4f37e6a --zone=europe-west1-c --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=mynetwork --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=714012279690-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=mynet-eu-vm,image=projects/debian-cloud/global/images/debian-10-buster-v20221102,mode=rw,size=10,type=projects/qwiklabs-gcp-02-e65ac4f37e6a/zones/europe-west1-c/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

#gcloud beta compute ssh --zone "us-central1-a" "mynet-us-vm"  --project "project-name"
#ping -c 3 10.132.0.2
#ping -c 3 146.148.11.118

#edit mynetwork to select Custom for the Subnet creation mode

#Create the managementnet network
gcloud compute networks create managementnet --project=qwiklabs-gcp-02-e65ac4f37e6a --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

gcloud compute networks subnets create managementsubnet-us --project=qwiklabs-gcp-02-e65ac4f37e6a --range=10.130.0.0/20 --stack-type=IPV4_ONLY --network=managementnet --region=us-central1

#Create the privatenet network

gcloud compute networks create privatenet --subnet-mode=custom

gcloud compute networks subnets create privatesubnet-us --network=privatenet --region=us-central1 --range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-eu --network=privatenet --region=europe-west1 --range=172.20.0.0/20

gcloud compute networks list

gcloud compute networks subnets list --sort-by=NETWORK

#Create the firewall rules for managementnet
gcloud compute --project=qwiklabs-gcp-02-e65ac4f37e6a firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=managementnet --action=ALLOW --rules=tcp:22,tcp:3389,icmp --source-ranges=0.0.0.0/0

#Create the firewall rules for privatenet
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

gcloud compute firewall-rules list --sort-by=NETWORK

#Create the managementnet-us-vm instance
gcloud compute instances create managementnet-us-vm --project=qwiklabs-gcp-02-e65ac4f37e6a --zone=us-central1-c --machine-type=f1-micro --network-interface=network-tier=PREMIUM,subnet=managementsubnet-us --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=714012279690-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=managementnet-us-vm,image=projects/debian-cloud/global/images/debian-10-buster-v20221102,mode=rw,size=10,type=projects/qwiklabs-gcp-02-e65ac4f37e6a/zones/us-central1-c/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud compute instances create privatenet-us-vm --zone=us-central1-c --machine-type=f1-micro --subnet=privatesubnet-us --image-family=debian-10 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=privatenet-us-vm

gcloud compute instances list --sort-by=ZONE

#Task4: Explore the connectivity across networks

ssh mynet-us-vm.10.132.0.0.qwiklabs-gcp-02-e65ac4f37e6a
ping -c 3 10.132.0.2

ping -c 3 146.148.11.118




