#!/bin/bash

#lawrenceakinro@gmail.com

#list the active account name:
gcloud auth list

#list the project ID:
gcloud config list project

#set the default region and zone for all resources:
gcloud config set compute/zone us-central1-a
gcloud config set compute/region us-central1

#create multiple web server instances (using the Nginx server):

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF


#create instance template:
gcloud compute instance-templates create nginx-template \
         --metadata-from-file startup-script=startup.sh

#create a target pool (this allows a single access point to all the instances in a group and is necessary for load balancing:
gcloud compute target-pools create nginx-pool

#create managed instance group using the instance template:
gcloud compute instance-groups managed create nginx-group \
         --base-instance-name nginx \
         --size 2 \
         --template nginx-template \
         --target-pool nginx-pool

#List the instance created:
gcloud compute instances list

#configure the firewall rule so that you can connect to the machines on port 80 via external IP address:
gcloud compute firewall-rules create www-firewall --allow tcp:80

#create an L4 network load balancer targeting your instance group:
gcloud compute forwarding-rules create nginx-lb \
         --region us-central1 \
         --ports=80 \
         --target-pool nginx-pool

#List all the Compute Engine forwarding rules in your project:
gcloud compute forwarding-rules list

#to create a HTTP(s) Load Balancer, first create a health check to verify that the instance is responding to HTTP or HTTPS traffic:
gcloud compute http-health-checks create http-basic-check

#define the HTTP service and map a port name to the relevant port for the instance group.
gcloud compute instance-groups managed \
       set-named-ports nginx-group \
       --named-ports http:80
       
#create a backend service:
gcloud compute backend-services create nginx-backend \
      --protocol HTTP --http-health-checks http-basic-check --global

#add the instane group to the backend service:
gcloud compute backend-services add-backend nginx-backend \
    --instance-group nginx-group \
    --instance-group-zone us-central1-a \
    --global
    
#create a default URL map that directs all incoming requests to all your instances:
gcloud compute url-maps create web-map \
    --default-service nginx-backend

#create a target HTTP proxy to route requests to your URL map:
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map
    

#create a global forwarding rule to handle and route incoming requests:
gcloud compute forwarding-rules create http-content-rule \
        --global \
        --target-http-proxy http-lb-proxy \
        --ports 80
        
#confirm the forwarding rule:
gcloud compute forwarding-rules list


#Network Load Balancing is a regional, non-proxied load balancer.
