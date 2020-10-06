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
# Comandos RUBOCOP

```

  Todos se ejecutan dentro del contenedor web, para entrar:
  sudo docker exec -it notifications_web_1 sh
  
  EJECUTAR ANALISIS DE TODOS LOS ARCHIVOS:
  rubocop 
  
  ANALIZAR SOLO APP.RB:
  rubocop app.rb
  
  ANALIZAR SOLO APP.RB Y  GUARDAR RESULTADOS EN UN TXT:
  rubocop app.rb -o <nombre_archivo>
  
  ANALIZAR Y APLICAR CORRECIONES AUTOMATICAS:
  rubocop app.rb -a
  
  COMPARAR EL ARCHIVO CORREGIDO  CON EL ORIGINAL (EN GITHUB):
  git diff app.rb
```

# Authors

## Core

  * Emiliano Baez
  * Leonardo Gaitan
  * Juan Yachino

# Licence
![Licence](https://github.com/juanyachino/notifications/blob/master/LICENSE.txt)  

