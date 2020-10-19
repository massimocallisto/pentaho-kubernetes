# GlusterFS Persistent Volume Example for Kubernetes

## Volume preparation
On the existing GlusterFS installation use the client to create a volume:

```
sudo mkdir -p /mnt/lun/ba-database
sudo chmod -R 777 /mnt/lun/ba-database
sudo gluster volume create ba-database transport tcp worker1:/mnt/lun/ba-database force
sudo gluster volume start ba-database
sudo gluster volume info ba-database
sudo gluster volume status ba-database
```

## Kubernetes deployment
You now nee to tell Kubernetes where to find the GlusterFS volumes. This require to define the endpoints and a fake service otherwise the endpoint will be deleted if the Kubernetes cluster is restarted.

    kubectl apply -f .

Use the commands below to check if endpoints are present:

    kubectl get enpoints
