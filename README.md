Uses the same SqlServer Linux from https://hub.docker.com/r/microsoft/mssql-server-linux/

The same variables are valid:
- SA_PASSWORD

Additional variable created:
- DATABASE (It will create a database with this variable value as name)

It has Flyway (https://flywaydb.org/) installed and it is migrated at RUN.
So, copy the migration files (ex: `./sql/V1__Initial.sql` - https://flywaydb.org/documentation/migrations#naming) to the `/flyway/sql` directory to auto-migrate at run.

## Usage
### Dockerfile

```docker
FROM tjmt/mssql-server-linux-flyway:2017-latest
COPY ./sql /flyway/sql
```


### docker-compose.yml

```yml
version: '3'
services:
  sistema-database:
    build:
      context: .
    ports:
      - 1433:1433
    environment:
      ACCEPT_EULA: 'Y'
      SA_PASSWORD: P@ssw0rd
      DATABASE: Banco
    volumes:
      - sistema-database:/var/opt/mssql
    labels:
      kompose.volume.size: 1Gi
      kompose.service.type: nodeport
    deploy:
      replicas: 1
      placement:
        constraints:
        - node.labels.server == database
volumes:
  sistema-database:
```

#### Obs: 
Use `docker-compose down -v` to remove the volume and re-test the script from start/empty.