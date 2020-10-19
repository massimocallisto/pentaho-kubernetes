# Pentaho Kubernetes deployment

## Storage requirements

The deployment require a persitent volume for the database. You can also connect an existing database and skip this part.

### GlusterFs example

See `extra-ba-database-disk-glusterfs` folder to see how to expose a volume named `ba-database` with GlusterFS. Finally you can create the persistent volume and persistent volume as follow:


    kubectl apply -f extra-ba-database-disk

## Database deployment
In order to tun the Pentaho you have to provide an external database, PostgreSQL in this case. The following instruction will deploy the po in which the persistence volume will be mapped on the previous volume `ba-database`.

First initialize the config map that will be used by the database deployment. The config map will be populated with the admin access credentials required scripts to initialize Pentaho:

```
kubectl create -f ba-database-config.yaml
kubectl create configmap ba-postgresql-init-db --from-file=scripts/postgresql/
```

Finally we can deploy the Pod along with the service:

```
kubectl apply -f ba-database-deployment.yaml
kubectl apply -f ba-database-service.yaml
```

## Pentaho
Resources:
* https://github.com/kespinosa05/pentaho-server
* https://diethardsteiner.github.io/pentaho-server/2018/04/01/Kubernates-and-Pentaho-Server.html

You can create your own image with this repository or use a public available image published on Docker Hub.

### Creating the docker image
The deployment script of Pentaho uses a custom Docker image obtained from the project. 
To submit to the cluster the custom image you can publish it on a docker registry or manually install the exported container image on the cluster. This must be done on all the cluster nodes (master and workers) with the following command (we assume you used the export command `docker save myrepo/image:tag >  ba-pentaho.tar`)

    docker load --input ba-pentaho.tar

### Deploy ok Kubernetes
In order to deploy Pentaho we have to provide the correct environmental variable to point to the BA database service hostname and related port. Users credential for Pentaho components (Hibernete, Repository, etc.) are the ones deploy with the initialization scripts and do not need to be changed.

```
kubectl apply -f ba-pentaho-deployment.yaml
kubectl apply -f ba-pentaho-service.yaml
```
### Test
You can use port-forwarding from Kubernetes.

    kubectl port-forward --address='0.0.0.0' service/ba-pentaho-service 8080:8080

### Ingress
You can expose the ingress rule. Remember that if you use the same hostname to expose Pentaho also with other applications, this resource file must be integrated and deployed as once.

```
kubectl apply -f ba-pentaho-ingress.yaml
```

You can connect from the local browser to the link below (we assume you provided in the host file the mapping of `platform.kube.lab` to the proxy IP and the proxy handle the host name with a valid redirect):

http://platform.kube.lab/pentaho/Login