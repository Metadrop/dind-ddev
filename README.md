## Creación de imagen

### Build de contenedor con paquete docker

```
docker build .  -t metadrop-dind-ddev-base
```

### Run con ntrypoint sh para evitar que lance el demonio dockerd y ejecución de script que lanza dockerd, instala ddev, descarga imágenes y para dockerd

```
docker run --privileged -it --rm --name metadrop-dind-ddev-base --entrypoint=sh metadrop-dind-ddev-base
```

### Mientras sigue en ejecución el run anterior, generar imagen con docker commit

```
docker commit --change='ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]' metadrop-dind-ddev-base metadrop-dind-ddev-images
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
