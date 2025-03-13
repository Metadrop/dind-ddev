## Instructions

The solution provided works this way:

* Create a Docker-in-Docker image
* Run the image and download docker images from inside
* Create a new image from the running container
* Push the image to a registry

### 1. Build the base dind image

```
docker build . -t dind-ddev-base
```

### 2. Download ddev images on running container

Run the base image with `bash` entrypoint:

```
docker run \
  --privileged -it --rm \
  --name dind-ddev-base \
  --volume $(pwd)/imagelists:/imagelists \
  --entrypoint=bash \
  dind-ddev-base
```

Run a script that prepares the filesystem and download docker images.

```
ddev-download-images.sh
```

By the default the script downloads only the minimal images required by DDEV _core_.

You can pass additional images lists as arguments. Some lists are provided in [imagelists/](./imagelists) folder:

```
ddev-download-images.sh /imagelists/aljibe.list /imagelists/metadrop.list
```

Add you custom lists to `imagelists/`. As an example, you can obtain the list of all images used by a project with:
```
cd <path-to-ddev-project>
ddev debug compose-config |grep -i image: | grep -v built | awk '{print $2}' | sort | uniq -u > myproject.list
mv myproject.list <path-to-dind-ddev-project>/imagelists
```

### 3. Generate a new image fron running container

This generates `dind-ddev` image with all images inside.

Note we're adding a label to link the generated image to its original repo.
If you're generating an image on your own, adjust it to suit your needs.

```
docker commit \
  --change='ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]' \
  --change='LABEL org.opencontainers.image.source=https://github.com/metadrop/dind-ddev' \
  dind-ddev-base dind-ddev
```

Now you can stop the container from step 2.

### Verify

Run the image:
```
docker run --privileged --rm --name dind-ddev dind-ddev
```

Check images are there:
```
docker exec dind-ddev docker image ls
```

## Publish

```
docker login registry.metadrop.net
docker image tag dind-ddev-images registry.metadrop.net/metadrop-group/dind-with-ddev-images/dind-with-ddev-images:latest
docker image push registry.metadrop.net/metadrop-group/dind-with-ddev-images/dind-with-ddev-images:latest
```
