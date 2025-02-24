## Creación de imagen

### Build de contenedor con paquete docker

```
docker build .  -t metadrop-dind-ddev-base
```

### Run con entrypoint `bash` para evitar que se lance el demonio dockerd y lanzar script que levanta dockerd, instala ddev, descarga imágenes

```
docker run --privileged -it --rm --name metadrop-dind-ddev-base --entrypoint=bash metadrop-dind-ddev-base
$ ddev-download-images.sh
```

### Mientras sigue en ejecución el run anterior, generar imagen con docker commit

```
docker commit --change='ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]' metadrop-dind-ddev-base metadrop-dind-ddev-images
```

## Verificación

### Ejecución de nuestro dind con imágenes ddev

```
docker run --privileged --rm --name metadrop-dind-ddev-images metadrop-dind-ddev-images
```

### Verificar que las imágenes están dentro

```
docker exec metadrop-dind-ddev-images docker image ls
```

## Publicación

```
docker login registry.metadrop.net
docker image tag metadrop-dind-ddev-images registry.metadrop.net/metadrop-group/dind-with-ddev-images/dind-with-ddev-images:latest
docker image push registry.metadrop.net/metadrop-group/dind-with-ddev-images/dind-with-ddev-images:latest
```
