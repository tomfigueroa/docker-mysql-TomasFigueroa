# A partir de la imagen oficial de MySQL
FROM mysql:5.7.39

# Agrega una base de datos
ENV MYSQL_DATABASE empresa

# Agrega el contenido de la carpeta sql-scripts/
# Todos los scripts en docker-entrypoint-initdb.d/ se ejecutan automáticamente
COPY ./sql-scripts/ /docker-entrypoint-initdb.d/