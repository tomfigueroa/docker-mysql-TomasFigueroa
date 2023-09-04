# Ejercicio: Crear imagen de contenedor con su Base Datos

Tome los scripts de creación de base de datos del proyecto que está realizando y cree una imagen de contenedor.

0. Cree un nuevo repositorio GitHub basado en esta plantilla.

1. Revise, en el archivo [`README.md`](./README.md), los pasos usados para crear una imagen de contenedor y subir la imagen a [Docker Hub](https://hub.docker.com).

2. Copie los scripts de creación de bases de datos en la carpeta `sql-scripts `. Elimine los archivos que no sean necesarios.

3. Revise el archivo [Dockerfile](./Dockerfile) con la definición de la imagen de contenedor. Haga los ajustes que considere convenientes. Por ejemplo, puede modificar el nombre de la base de datos

4. Cree la imagen y realice pruebas en la base de datos para verificar que se hizo correctamente.

    ```
    # Crear imagen
    docker build -t mysql-trabajo .

    # Ejecutar contenedor
    docker run -d \
        --name mysql-trabajo \
        -e MYSQL_ROOT_PASSWORD=secret \
        mysql-trabajo

    # Ejecute instrucciones SQL en el contenedor
    docker exec -it \
        mysql-trabajo \
        mysql -p
    ```

5. Si el contenedor se creo correctamente, suba la imagen a Docker Hub.

    ```
    # Inicia sesión en Docker Hub (si no lo ha hecho)
    docker login

    # Asigne una etiqueta a la imagen
    docker tag mysql-trabajo <usuario>/mysql-trabajo:latest

    # Sube la imagen
    docker push <usuario>/mysql-trabajo:latest
    ```

6. Revise en [Docker Hub](https://hub.docker.com) que la imagen subió apropiadamente.

7. Suba el proyecto a Github

    ```
    # Agrega los archivos al cambio
    git add .

    # Guarda el cambio
    git commit -m "Agrega SQL de creación de BD"

    # Envia el cambio al servidor Github
    git push -u origin main
    ```

8. En Docker Hub [cree un token de acceso](https://docs.docker.com/docker-hub/access-tokens/) para poder integrar Github con Docker Hub.
    - Inicie sesión en Docker Hub
    - Haga clic en el nombre de usuario y seleccione `Account Settings.`
    - En el perfil del usuario, seleccione, en el menú `Security`, la opción `New Access Token.`
    - Coloque un nombre al token.
    - Copie el valor del token. Note que este valor solo será visible en esta pantalla y luego no se puede obtener nuevamente

9. En Github, [cree un secreto en el repositorio](https://docs.github.com/en/actions/security-guides/encrypted-secrets) con el nombre `DOCKER_HUB_ACCESS_TOKEN` con el token que acaba de crear
    - En Github, en su repositorio, haga clic en `Settings`
    - En el menú `Security` seleccione `Secrets` y luego `Actions`
    - Haga clic en el botón `New repository secret`
    - Escribe el nombre `DOCKER_HUB_ACCESS_TOKEN`
    - En el campo `Value` pegue el token que copió en el paso anterior.
    - Haga clic en `Add secret`

10. Cree un secreto en el repositorio en Github con el nombre `DOCKER_HUB_USERNAME` con el nombre de su usuario en Docker Hub.

7. Cree un pipeline en Github Actions, en la carpeta `./github/workflows`, para compilar y subir la imagen de forma automática. Puede usarse cualquier nombre. Por ejemplo, puede crear un archivo  `sube-docker.yml`. 

    ```
    name: Publicar imagen en DockerHub

    on:
      push:
        branches: [ "main" ]
    workflow_dispatch: 

    jobs:

    build:
        runs-on: ubuntu-latest
        steps:
        
            - name: Descarga el proyecto
            uses: actions/checkout@v3
            
            - name: Login en Docker Hub
            uses: docker/login-action@v1
            with:
                username: ${{ secrets.DOCKER_HUB_USERNAME }}
                password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}
                
            - name: Configuro Docker Buildx
            id: buildx
            uses: docker/setup-buildx-action@v1

            - name: Genera y sube la imagen
            id: docker_build
            uses: docker/build-push-action@v2
            with:
                context: ./
                file: ./Dockerfile
                push: true
                tags: ${{ secrets.DOCKER_HUB_USERNAME }}/mysql-trabajo:latest, ${{ secrets.DOCKER_HUB_USERNAME }}/mysql-trabajo:1
        
            - name: Notificación
            run: echo ${{ steps.docker_build.outputs.digest }}
    ```