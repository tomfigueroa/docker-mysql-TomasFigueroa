# Creación de una imagen personalizada de MySQL

Los desarrolladores crean sus propias imágenes de contenedor con los programas que ellos desarrollan. Normalmente, estas imágenes se basan en otras imágenes existentes, agregando solo el código y las librerías que se han desarrollando.

En Docker es posible crear las imágenes a partir de otras existentes en [Docker Hub](https://hub.docker.com/) o en cualquier otro registro de imágenes de contenedor. Por ejemplo, es posible crear imágenes a partir de la imagen oficial de Docker.

## Creando unos scripts para la base de datos

Supongamos que el software que estamos desarrollando es una aplicación con bases de datos. Para crear la imagen es necesario establecer un conjunto de scripts con la definición de la base de datos. Estos scripts serán usados para crear la imagen.

> NOTA: Los entornos de desarrollo y herramientas de bases de datos normalmente incluyen opciones para generar estos scripts a partir de bases de datos existentes.

En este ejemplo tenemos dos archivos con los scripts de creación de base de datos.

1. `sql-scripts/crear-tablas.sql` es un script que crea las tablas de la base de datos

    ```
    CREATE TABLE empleados (
        primer_nombre   varchar(25),
        segundo_nombre  varchar(25),
        departamento    varchar(15),
        email           varchar(50)
    );
    ```

2. `sql-scripts/insertar-datos.sql` es un script que inserta datos en la base de datos

    ```
    INSERT INTO empleados (primer_nombre, segundo_nombre, departamento, email)
        VALUES ('Bill', 'Gates', 'IT', 'billg@ejemplo.com');

    INSERT INTO empleados (primer_nombre, segundo_nombre, departamento, email)
        VALUES ('Steve', 'Jobs', 'Ventas', 'steve.jobs@ejemplo.com');
    ```

## Creando una imagen

Para crear una imagen de contenedor en  Docker es necesario crear un archivo `Dockerfile`. Este archivo contendrá las isntrucciones necesarias para crear la imagen del contenedor.

1. Cree el archivo `Dockerfile` con instrucciones para copiar los scripts de creación de tablas en la nueva imagen.

    ```
    # A partir de la imagen oficial de MySQL
    FROM mysql:5.7.39

    # Agrega una base de datos
    ENV MYSQL_DATABASE empresa

    # Agrega el contenido de la carpeta sql-scripts/
    # Todos los scripts en docker-entrypoint-initdb.d/ se ejecutan automáticamente
    COPY ./sql-scripts/ /docker-entrypoint-initdb.d/
    ```

2. Ejecute `docker build` para crear una imagen de contenedor. Use el parámetro `-t` para definir el nombre de la imagen.

    ```
    docker build -t bd-empresa .
    ```

3. Ejecute `docker run` para correr un contenedor con la imagen recien creada. Note que se puede usar el parámetro `--name` para definir el nombre del contenedor y el parámetro `-e` para definir la contraseña del usuario `root`.

    ```
    docker run -d \
        --name mysql-empresa \
        -p 3306:3306  \ 
        -e MYSQL_ROOT_PASSWORD=secret \ 
        bd-empresa
    ```

4. Use `docker exec` para ejecutar comandos de MySQL y revisar que la base de datos se creó apropiadamente. Use el nombre del contenedor y la contraseña definida anteriormente.

    ```
    docker exec -it mysql-empresa mysql -p
    ```

    Debe usar la contraseña definida anteriormente. Si se usó el comando anterior sin cambios, la contraseña es `secret`.

    Puede ejecutar `show databases` para ver las bases de datos creadas.

    ```
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | empresa            |
    | mysql              |
    | performance_schema |
    | sys                |
    +--------------------+
    5 rows in set (0.01 sec)

    mysql>
    ```

    Puede ejecutar `USE empresa` para seleccionar la base de datos y `SHOW tables` para ver las tablas en su interior.

    ```
    mysql> use empresa;
    Database changed
    mysql> show tables;
    +-------------------+
    | Tables_in_empresa |
    +-------------------+
    | empleados         |
    +-------------------+
    1 row in set (0.01 sec)

    mysql>     
    ```

    Use `show columns from` para ver la definición de la tabla `empleados`.

    ```
    mysql> show columns from empleados;
    +----------------+-------------+------+-----+---------+-------+
    | Field          | Type        | Null | Key | Default | Extra |
    +----------------+-------------+------+-----+---------+-------+
    | primer_nombre  | varchar(25) | YES  |     | NULL    |       |
    | segundo_nombre | varchar(25) | YES  |     | NULL    |       |
    | departamento   | varchar(15) | YES  |     | NULL    |       |
    | email          | varchar(50) | YES  |     | NULL    |       |
    +----------------+-------------+------+-----+---------+-------+
    4 rows in set (0.00 sec)    
    ```

    Use `select ... from` para ver el contenido de la tabla

    ```
    mysql> select * from empleados;
    +---------------+----------------+--------------+------------------------+
    | primer_nombre | segundo_nombre | departamento | email                  |
    +---------------+----------------+--------------+------------------------+
    | Bill          | Gates          | IT           | billg@ejemplo.com      |
    | Steve         | Jobs           | Ventas       | steve.jobs@ejemplo.com |
    +---------------+----------------+--------------+------------------------+
    2 rows in set (0.00 sec)    
    ```

    Use `\q` o `exit` para salir de los comandos de MySQL.

    ```
    mysql> exit
    Bye
    ```

5. (Opcionalmente) Use `docker rm -f` para detener y eliminar el contenedor.

    ```
    docker rm -f mysql-empresa
    ```

## Publicando la imagen en Docker Hub

1. Use `docker login` para iniciar sesión (desde línea de comandos) en Docker Hub. Si está usando Docker Desktop y ya ha iniciado sesión, el comando no le debe solicitar datos nuevamente.

    ```
    docker login
    ```

    ```
    Authenticating with existing credentials...
    Login Succeeded

    Logging in with your password grants your terminal complete access to your account.
    For better security, log in with a limited-privilege personal access token. Learn more at https://docs.docker.com/go/access-tokens/
    ```

2. Use `docker tag` para asignar un nombre a la imagen que acaba de crear. Hasta el momento la imagen tiene como nombre `mysql-empresa`. Debe crear una etiqueta para la imagen de forma que tenga un nombre consistente con su usuario en Docker Hub.


    En Docker Hub las imágenes incluyen el nombre del usuario en su  nombre: `<nombre-usuario>/<nombre-imagen>:etiqueta`

    Suponga que su usuario es `jchavarr`. Puede crear una etiqueta con el nombre `jchavarr/mysql-empresa:latest`

    ```
    docker tag mysql-empresa jchavarr/mysql-empresa:latest
    ```

3. Use `docker push` para subir la imagen a Docker Hub.

    ```
    docker push jchavarr/mysql-empresa:latest
    ```