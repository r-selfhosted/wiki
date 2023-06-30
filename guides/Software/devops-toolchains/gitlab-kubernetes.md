---
authors:
    - name: kmorton1988
      link: https://github.com/kmorton1988
      avatar: ":dragon_face:"
label: GitLab in Kubernetes
icon: dot
order: alpha
---

Difficulty: [!badge variant="warning" text="Hard / Advanced"]

## Introduction

In this article, I will describe all the steps required to setup GitLab CI/CD in Kubernetes using Kustomize.
We will go through how to run GitLab on Kubernetes when you already have related resources `Postgres`, `Redis`, `MinIO`, `TLS Certificates`, etc...already available in your setup.

This is a very common scenario in companies and also for self-hosting that you are already using these services in your environment and prefer to use the same for gitlab.

!!!
The all in one production installation may be easily performed with Helm. You can refer to the official documentation from GitLab if that is your requirement.
!!!


## Requirements

You will need the following in order to run GitLab.

1. Database: Postgres
2. Cache: Redis
3. Storage: MinIO is used as object storage for the container registry, GitLab backups, the Terraform storage backend, GitLab artifacts and more
4. Ingress Controller: Nginx ingress
5. Persistent Volume: Gitaly will store repository data data on disk. Your Kubernetes cluster must have a way of provisioning storage. You can install the [local path provisioner](https://github.com/rancher/local-path-provisioner) in your cluster for dynamically provisioning volumes.

### Necessary Repositories
  1. [Gitlab Manifests](https://github.com/kha7iq/gitlab-k8s)
  2. [SubVars App](https://github.com/kha7iq/subvars)

!!! Info
You can swap MinIO with any other object storage i.e S3 by changing the connection info secret.
!!!

## Lets Get Started!

When installing GitLab with Helm it generates the ConfigMaps after rendering the templates with parameters. We can manually change these values in ConfigMaps but its a hassle and not convenient. To make this process easy we will use a tool called [subvars](https://github.com/kha7iq/subvars) which will let us render these values from the command line. Install it by following the instructions on the [GitHub page](https://github.com/kha7iq/subvars), we will use it later.

1. Download the release with manifests from [GitHub](https://github.com/kha7iq/gitlab-k8s). Alternatively you can clone the repo. If you are cloning the repo remove the `.git` folder afterwards as it creates issues some times when rendering multiple version of the same file with `subvars`.
    ```bash
    export RELEASE_VER=1.0
    wget -q https://github.com/kha7iq/gitlab-k8s/archive/refs/tags/v${RELEASE_VER}.tar.gz
    tar -xf v${RELEASE_VER}.tar.gz
    cd gitlab-k8s-${RELEASE_VER}
    ```
2. Next set the URL for our GitLab instance in our [Kustomization file](https://github.com/kha7iq/gitlab-k8s/blob/master/ingress-nginx/kustomization.yaml). This is located within the `ingress-nginx` folder. You will find two blocks, one for `web-ui` and the second for the `registry` along with a `tls-secret-name` for HTTPS.
    ```yaml
    patch: |-
      - op: replace
        path: /spec/rules/0/host
        value: your-gitlab-url.example.com
      - op: replace
        path: /spec/tls/0/hosts/0
        value: your-gitlab-url.example.com
      - op: replace
        path: /spec/tls/0/secretName
        value: example-com-wildcard-secret
    ```
3. Next create `minio-conn-secret` containing the configuration for MinIO. It will be used for all of the enabled S3 buckets except for the GitLab backup, we will create that separately. Create a Kubernetes secret to store this information. The following is an example
    ```bash minio.config
    cat << EOF > minio.config
    provider: AWS
    region: us-east-1
    aws_access_key_id: 4wsd6c468c0974006d
    aws_secret_access_key: 5d5e6c468c0974006cdb41bc4ac2ba0d
    aws_signature_version: 4
    host: minio.example.com
    endpoint: "https://minio.example.com"
    path_style: true
    EOF
    ```
 
    ```bash
    kubectl create secret generic minio-conn-secret \
    --from-file=connection=minio.config --dry-run=client -o yaml >minio-connection-secret.yml
    ```
4. Now create a secret with the MinIO configuration which will be used for the GitLab backup storage. Replace the MinIO endpoint, bucket name, access key & secret key.
    ```bash
    cat << EOF > storage.config
    [default]
    access_key = be59435b326e8b0eaa
    secret_key = 6e0a10bd2253910e1657a21fd1690088
    bucket_location = us-east-1
    host_base = https://minio.example.com
    host_bucket = https://minio.example.com/gitlab-backups
    use_https = True
    default_mime_type = binary/octet-stream
    enable_multipart = True
    multipart_max_chunks = 10000
    multipart_chunk_size_mb = 128
    recursive = True
    recv_chunk = 65536
    send_chunk = 65536
    server_side_encryption = False
    signature_v2 = True
    socket_timeout = 300
    use_mime_magic = False
    verbosity = WARNING
    website_endpoint = https://minio.example.com
    EOF
    ```

    ```bash
    kubectl create secret generic storage-config --from-file=config=storage.config \
    --dry-run=client -o yaml > secrets/storage-config.yml
    ```

    !!!
    All other secrets can be used as is from the repository or you can change all of them. You may read more about this [here](https://docs.gitlab.com/charts/installation/secrets.html)
    !!!
5. One of the most important secrets is the `gitlab-rails-secret` secret. In case of a disaster where you have to restore GitLab from a backup you must apply the same secret to your cluster as these keys will be used to decrypt the database from backup. Make sure you keep this consistent after first install and **do not change it**.
6. It's alot of work to change database details and other parameters one by one in ConfigMaps. I have implemented some templating for this which can provide all the values of environment variables and render the manifests with `subvars`. It will output these to a destination folder and replace all the parameters defined as Go templates. The values should be self explanatory, for example, the `GITLAB_GITALY_STORAGE_SIZE` variable is used to specify how much storage is needed for Gitaly and `GITLAB_STORAGE_CLASS` is the name of storage class in your Kubernetes cluster. The following command is an example of how to use this:
    ```bash
    GITLAB_URL=gitlab.example.com \
    GITLAB_REGISTRY_URL=registry.example.com \
    GITLAB_PAGES_URL=pages.example.com \
    GITLAB_POSTGRES_HOST=192.168.1.90 \
    GITLAB_POSTGRES_PORT=5432 \
    GITLAB_POSTGRES_USER=gitlab \
    GITLAB_POSTGRES_DB_NAME=gitlabhq_production \
    GITLAB_REDIS_HOST=192.168.1.91:6379 \
    GITLAB_GITALY_STORAGE_SIZE=15Gi \
    GITLAB_STORAGE_CLASS=local-path \
    subvars dir --input gitlab-k8s-1.0 --out dirName
    ```
    Change into `dirName/gitlab-k8s-1.0` so you may review things to confirm everything is in order before applying the changes to the cluster.
7. The final step is to create the namespace `gitlab` and build with Kustomize or `kubectl`. I prefer Kustomize but you can also use `kubectl` with `-k` flag.
    ```bash Create the Namespace
    kubectl create namespace gitlab
    ```
    ```bash Apply the Final Manifest
    kustomize build gitlab-k8s-1.0/ | kubectl apply -f -
    # or following if you have already changed into directory
    kustomize build . | kubectl apply -f -
    # With kubectl
    kubectl apply -k  gitlab-k8s-1.0/
    # or following if you have already changed into directory
    kubectl apply -k  .
    ```
8. Head over to the endpoint you have configured for your GitLab instance, `https://gitlab.example.com` for example, and login.
   

## Notes

* Default passwords  
    GitLab 'root' user password configured as secret
    ```bash
    LAwGTzCebner4Kvd23UMGEOFoGAgEHYDszrsSPfAp6lCW15S4fbvrVrubWsua9PI
    ```
    Postgres password configured as secret
    ```bash
    ZDVhZDgxNWY2NmMzODAwMTliYjdkYjQxNWEwY2UwZGMK
    ```
