#!/bin/bash

# Parameters
region=europe-west3
project_id=speedy-victory-336109
network=myvpc
create_proxy_subnet=true
proxysubnet_name=proxy-only-subnet
proxysubnet_range="192.168.129.0/24"
create_nat=true
cloud_router_name=lb-nat-router
cloud_nat_name=lb-nat


if [ $create_proxy_subnet = "true" ];then
echo "Creating proxy only subnet in $region ... "
gcloud compute networks subnets create $proxysubnet_name \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE \
    --region=$region \
    --network=$network \
    --range=$proxysubnet_range \
    --project=$project_id
fi

if [ $create_nat = "true" ];then
echo "Creating cloud router and nat ... "
gcloud compute routers create $cloud_router_name --network $network --region $region --project=$project_id
gcloud compute routers nats create $cloud_nat_name \
    --router-region $region \
    --router $cloud_router_name \
    --endpoint-types=ENDPOINT_TYPE_MANAGED_PROXY_LB \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips \
    --project=$project_id
fi

tail -n +2 mapping.csv | while IFS="," read -r name ip port1 port2; do
    name=$name
    backend_ip=$ip
    backend_port=$port1
    frontend_port=$port2

    gcloud compute addresses create $name-ip \
        --region=$region \
        --project=$project_id \
        --network-tier=PREMIUM

    gcloud compute network-endpoint-groups create $name \
        --region=$region \
        --network-endpoint-type=internet-ip-port  \
        --network=$network \
        --project=$project_id

    gcloud compute network-endpoint-groups update $name \
        --project=$project_id \
        --region=$region \
        --add-endpoint="ip=$backend_ip,port=$backend_port"

    gcloud compute backend-services create $name \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --region=$region \
        --project=$project_id \
        --health-checks-region=$region

    gcloud compute backend-services add-backend $name \
        --region=$region \
        --network-endpoint-group=$name \
        --network-endpoint-group-region=$region \
        --project=$project_id
        
    gcloud compute target-tcp-proxies create $name \
        --backend-service=$name \
        --region=$region \
        --project=$project_id

    gcloud compute forwarding-rules create $name \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --network=$network \
        --target-tcp-proxy=$name \
        --target-tcp-proxy-region=$region \
        --region=$region \
        --address=$name-ip \
        --ports=$frontend_port \
        --project=$project_id

    echo '---------------------------------------------------'
done

echo 'done!' 


#https://cloud.google.com/load-balancing/docs/tcp/set-up-ext-reg-tcp-proxy-migs?hl=zh-cn
#https://cloud.google.com/load-balancing/docs/negs/internet-neg-concepts?hl=zh-cn#nat-support