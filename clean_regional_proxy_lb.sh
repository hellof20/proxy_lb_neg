#!/bin/bash

region=europe-west3
project_id=speedy-victory-336109
delete_proxy_subnet=true
proxysubnet_name=proxy-only-subnet
delete_nat=true
cloud_router_name=lb-nat-router
cloud_nat_name=lb-nat


echo "Deleting LB ... "
tail -n +2 mapping.csv | while IFS="," read -r name ip port1 port2; do
    name=$name
    gcloud compute forwarding-rules delete $name --region=$region --project=$project_id --quiet
    gcloud compute target-tcp-proxies delete $name --region=$region --project=$project_id --quiet
    gcloud compute backend-services delete $name --region=$region --project=$project_id --quiet
    gcloud compute network-endpoint-groups delete $name --region=$region --project=$project_id --quiet
    gcloud compute addresses delete $name-ip --region=$region --project=$project_id --quiet
done


if [ $delete_nat = "true" ];then
    echo "Deleting cloud router ... "
    gcloud compute routers nats delete $cloud_nat_name \
        --region=$region \
        --project=$project_id \
        --router $cloud_router_name \
        --quiet

    echo "Deleting cloud nat ... "
    gcloud compute routers delete $cloud_router_name \
        --region $region \
        --project=$project_id \
        --quiet
fi


if [ $delete_proxy_subnet = "true" ];then
    echo "Deleting proxy subnet ... "
    gcloud compute networks subnets delete $proxysubnet_name --project=$project_id --region $region --quiet
fi