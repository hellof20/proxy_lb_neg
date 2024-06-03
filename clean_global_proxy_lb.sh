#!/bin/bash

region=us-east4
project_id=speedy-victory-336109
lb_ip_name=myglobalip001

tail -n +2 mapping.csv | while IFS="," read -r name ip port1 port2; do
    name=$name
    gcloud compute forwarding-rules delete $name --global --project=$project_id --quiet
    gcloud compute target-tcp-proxies delete $name --global --project=$project_id --quiet
    gcloud compute backend-services delete $name --global --project=$project_id --quiet
    gcloud compute health-checks delete hc-$name --global --project=$project_id --quiet
    gcloud compute network-endpoint-groups delete $name --zone=$region-a --project=$project_id --quiet
done

gcloud compute addresses delete $lb_ip_name --global --project=$project_id --quiet