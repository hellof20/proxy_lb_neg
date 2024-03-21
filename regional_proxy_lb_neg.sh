#!/bin/bash

#运行前确保还没有proxy subnet

region=us-east4
project_id=speedy-victory-336109
network=myvpc
# proxysubnet="192.168.129.0/24"

gcloud compute addresses create lb-ip \
    --region=$region \
    --project=$project_id \
    --network-tier=PREMIUM

# gcloud compute networks subnets create proxy-only-subnet \
#     --purpose=REGIONAL_MANAGED_PROXY \
#     --role=ACTIVE \
#     --region=$region \
#     --network=$network \
#     --range=$proxysubnet \
#     --project=$project_id

gcloud compute routers create lb-nat-router --network $network --region $region --project=$project_id
gcloud compute routers nats create lb-nat \
    --router-region $region \
    --router lb-nat-router \
    --endpoint-types=ENDPOINT_TYPE_MANAGED_PROXY_LB \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips \
    --project=$project_id

while IFS="," read -r name ip port1 port2; do
    name=$name
    backend_ip=$ip
    backend_port=$port1
    frontend_port=$port2

    gcloud compute network-endpoint-groups create $name \
        --region=$region \
        --network-endpoint-type=internet-ip-port  \
        --network=$network \
        --project=$project_id

    gcloud compute network-endpoint-groups update $name \
        --project=$project_id \
        --region=$region \
        --add-endpoint="ip=$backend_ip,port=$backend_port"

    # gcloud compute health-checks create tcp $name \
    #     --region=$region \
    #     --use-serving-port

    # gcloud compute backend-services create $name \
    #     --load-balancing-scheme=EXTERNAL_MANAGED \
    #     --region=$region \
    #     --project=$project_id \
    #     --health-checks=$name \
    #     --health-checks-region=$region

    gcloud compute backend-services create $name \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --region=$region \
        --project=$project_id

    gcloud compute backend-services add-backend $name \
        --region=$region \
        --network-endpoint-group=$name \
        --network-endpoint-group-region=$region \
        --project=$project_id
        
    gcloud compute target-tcp-proxies create $name \
        --backend-service=$name \
        --region=$region \
        --project=$project_id
        
    # gcloud compute forwarding-rules create $name \
    #     --load-balancing-scheme=EXTERNAL_MANAGED \
    #     --network-tier=PREMIUM \
    #     --network=$network \
    #     --target-tcp-proxy=$name \
    #     --target-tcp-proxy-region=$region \
    #     --region=$region \
    #     --ports=$frontend_port \
    #     --project=$project_id

    gcloud compute forwarding-rules create $name \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --network=$network \
        --target-tcp-proxy=$name \
        --target-tcp-proxy-region=$region \
        --region=$region \
        --address=lb-ip \
        --ports=$frontend_port \
        --project=$project_id   

    echo '-----------------'
done < mapping.csv

echo 'done!' 


#https://cloud.google.com/load-balancing/docs/tcp/set-up-ext-reg-tcp-proxy-migs?hl=zh-cn
#https://cloud.google.com/load-balancing/docs/negs/internet-neg-concepts?hl=zh-cn#nat-support


# name=regional-neg-1
# backend_ip=35.202.71.205
# backend_port=80
# frontend_port=8081