#!/bin/bash

region=us-east4
project_id=speedy-victory-336109

while IFS="," read -r name ip port1 port2; do
    name=$name
    gcloud compute forwarding-rules delete $name --region=$region --project=$project_id --quiet
    gcloud compute target-tcp-proxies delete $name --region=$region --project=$project_id --quiet
    gcloud compute backend-services delete $name --region=$region --project=$project_id --quiet
    gcloud compute network-endpoint-groups delete $name --region=$region --project=$project_id --quiet
done < mapping.csv   

gcloud compute routers nats delete lb-nat --region=$region --project=$project_id --router lb-nat-router --quiet
gcloud compute routers delete lb-nat-router --region $region --project=$project_id --quiet
gcloud compute networks subnets delete proxy-only-subnet --project=$project_id --region $region --quiet
gcloud compute addresses delete lb-ip --region=$region --project=$project_id --quiet    