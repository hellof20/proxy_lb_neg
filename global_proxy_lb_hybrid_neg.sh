#!/bin/bash

region=us-east4
project_id=speedy-victory-336109
network=myvpc
lb_ip_name=myglobalip001

# create global lb IP
gcloud compute addresses create $lb_ip_name \
    --global \
    --project=$project_id \
    --network-tier=PREMIUM

tail -n +2 mapping.csv | while IFS="," read -r name ip port1 port2; do
    name=$name
    backend_ip=$ip
    backend_port=$port1
    frontend_port=$port2

    gcloud compute network-endpoint-groups create $name \
        --project=$project_id \
        --zone=$region-a \
        --network=$network \
        --network-endpoint-type=NON_GCP_PRIVATE_IP_PORT \
        --default-port=$backend_port        

    gcloud compute network-endpoint-groups update $name \
        --project=$project_id \
        --zone=$region-a \
        --add-endpoint="ip=$backend_ip,port=$backend_port"

    gcloud compute health-checks create tcp hc-$name \
        --project=$project_id \
        --global \
        --port=$backend_port

    gcloud compute backend-services create $name \
        --project=$project_id \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=TCP \
        --global \
        --health-checks=hc-$name \
        --enable-logging

    gcloud compute backend-services add-backend $name \
        --global \
        --network-endpoint-group=$name \
        --network-endpoint-group-zone=$region-a \
        --project=$project_id \
        --balancing-mode=CONNECTION \
        --max-connections=100
        
    gcloud compute target-tcp-proxies create $name \
        --backend-service=$name \
        --global-backend-service \
        --project=$project_id

    gcloud compute forwarding-rules create $name \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --target-tcp-proxy=$name \
        --global \
        --address=$lb_ip_name \
        --ports=$frontend_port \
        --project=$project_id         

    echo '---------------------------------------------------'
done

echo 'done!' 
