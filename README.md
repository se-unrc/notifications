# ProyectoAyDS/Ingenieria de Software 2020 :
# 
# 
# TODO: 
 

# Description

This is a sample readme file 

# Usage

```
  docker-compose up --build
  Migraciones:
  sudo docker exec -it <ID DEL CONTENEDOR NOTIFICATIONS> sequel -m db/migrations postgres://unicorn:magic@db/notificator-development
  Entrar  a la base de datos:
  sudo docker exec -it <ID DEL CONTENEDOR POSTGRES> sh -c "psql --host=db --username=unicorn dbname=notificator-development"
  
  reventar todas las tablas de la base de datos:
  sudo  docker-compose down --volumes
```


# Authors

## Core

  * Emiliano Baez
  * Leonardo Gaitan
  * Juan Yachino

# Licence
![Licence](https://github.com/juanyachino/notifications/blob/master/LICENSE.txt)  

