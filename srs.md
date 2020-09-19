# Software Requirements Specification
## For Notifications System

Version 1.1  
Prepared by Juan Pablo Bortol, Ayrton Emilio Lopez, Ezequiel Nicolas Rafti Soto,
UNRC, 
Marzo-2020  

Table of Contents
=================
* [Revision History](#revision-history)
* 1 [Introduction](#1-introduction)
  * 1.1 [Document Purpose](#11-document-purpose)
  * 1.2 [Product Scope](#12-product-scope)
  * 1.3 [Definitions, Acronyms and Abbreviations](#13-definitions-acronyms-and-abbreviations)
  * 1.4 [References](#14-references)
  * 1.5 [Overview] (#15-overview)
* 2 [Product Overview](#2-product-overview)
  * 2.1 [Product Perspective](#21-product-perspective)
  * 2.2 [Product Functions](#22-product-functions)
  * 2.3 [User Characteristics](#23-user-characteristics)
  * 2.4 [Product Constraints](#24-product-constraints)
  * 2.5 [Assumptions and Dependencies](#25-Assumptions-and-dependencies)
* 3 [Requirements](#3-requirements)
  * 3.1 [External Interface Requirements](#31-external-interface-requirements)
  * 3.2 [Functional Requirements](#32-functional-requirements)
  * 3.3 [Performance Requirements](#33-performance-requirements)
  * 3.4 [Design Constraints](#34-design-constraints)

## Revision History
| Name             | Date     | Reason For Changes  | Version   |
|------------------|----------|---------------------|-----------|
| Modificaciones   |09/19/2020|  Mejoras Generales  |   1.1     |

## 1. Introduccion

### 1.1 Proposito del Documento
 Este  documento representa los distintos requerimientos a la lógica que compete el Sistema de Notificaciones de la UNRC. Su propósito es describir las Funcionalidades y Componentes que rodean el desarrollo e implementación del mismo.

### 1.2 Product Scope
El Sistema de notificaciones "Notifications" consiste en administrar la subida de distintos documentos varios que La Universidad Nacional de Rio Cuarto considere de carácter formal, tal como actas,reformas, etc.
Así mismo también se encarga de notificar tanto a toda persona que sea mencionado en dichos documentos o todo aquel que quiera saber sobre documentos de esa índole.

### 1.3 Definitions, Acronyms and Abbreviations
| Termino     | Descripción                                                        |
| ------------|--------------------------------------------------------------------|
|Usuario      |persona que puede ver documentos y recibir notificaciones si está incluido en dicho documento, Se registra con sus datos personales   |
|Admin        |Es un usuario que tiene permitido cargar documentos y etiquetar     |
|Documento    |Documento escaneado a pdf.                                          |
|Notificacion |Alerta indicando que el usuario ha sido nombrado en un documento    |
|Categoria    |Tema al cual el documento refiere                                   |


### 1.4 References
[1] Arsaute, A., Brusatti, F., Solivellas, D., Uva, M. "srs". Unpublished

### 1.5  Overview
La estructura y formato de este documento fue elegida acorde al estándar std 15288-2015 del IEEE.

El resto de este documento está organizado como sigue.La sección 2 define las funciones generales del sistema, las restricciones destinadas a ser respetadas y las asunciones hechas para definir requerimientos. en resumen, profundiza en las especificaciones del sistema, sus funciones y otra información general.

La Sección 3 lista los requerimientos funcionales y no funcionales en detalle.


## 2. Product Overview

### 2.1 Perspectiva del Producto.
El producto a ser desarrollado,que este documento describe, es un sistema de notificaciones que forma parte de la Universidad Nacional de Rio Cuarto, el cual se considerara una extensión de la comunicación entre la entidad y los usuarios.

### 2.2 Funcionalidades del Producto.
Esta sección presenta una vista general de todas las funcionalidades que serán provistas. Una explicación más detallada de las funcionalidades serán encontradas en la sección 3.

En general las funciones principales son:
  -La creación,eliminación y modificación de usuarios en el sistema.
  -La creación,eliminación y modificación de administradores en el sistema.
  -La creación,eliminación y modificación de documentos en el sistema.
  -La creación,eliminación y modificación de categorías de los documentos en el sistema.
  -La notificación directa a los usuarios de la subida de documentos.


### 2.3 Características de Usuario
Se considerara usuario  a todo aquel que pertenezca y tenga una relación formal con la Universidad Nacional de Rio Cuarto, ya que los documentos que se cargaran en el sistema si bien son de carácter publico pertenecen a la misma. El usuario común tendrá acceso a todos los documentos cargados en el sistema, la información de los mi a si mismo tendrá acceso a todas las categorías de los cuales pertenecen los mismos. El usuario administrador tendrá todas las capacidades que tiene el usuario común pero también se le agregara la capacidad de agregar documentos, categorías, otros usuarios, otros administradores y así también modificar y eliminar los mismos.

### 2.4 Restricciones del Producto
La restricciones son:
        -Solo se podrá ingresar al sistema con una computadora que tenga conexión a Internet.
        -Un usuario solo podrá tener una cuenta en el sistema.

### 2.5 Suposiciones y dependencias
Las suposiciones que se toman en cuenta con respecto al uso del sistema son:
    -La conexión a Internet de la computadora con la que se ingresa es estable.
    -El usuario posee un e-mail con el cual se registrara en el sistema y el mismo será usado para ingresar en el Sistema.

## 3. Requirements

### 3.1 Requerimientos de interfaz externa
La aplicación se correrá mediante Docker un contenedor de software capaz de automatizar la virtualización de aplicaciones en múltiples sistemas operativos, así  mismo se correrá la base de datos Postgres también a travez de Docker.

### 3.2 Requerimientos funcionales
| Funcionalidad                    | Descripción                                                                |
| ---------------------------------|----------------------------------------------------------------------------|
|Alta de Usuario                   |Alta de un usuario en el sistema, con sus respectivos datos personales      |                                                                        
|Alta de Administrador             |Alta de un administrador en el sistema, con sus respectivos datos personales|                                                                   
|Alta de Documento                 |Alta de un documento, el cual incluirá nombre, categoría, fecha y hora      |                                                                   
|Alta de Categoría                 |Alta de una categoría, el cual incluirá nombre y descripción                |                                                 
|Baja de Usuario                   |Eliminación de un usuario del sistema                                       |                            
|Baja de Administrador             |Eliminación de un administrador del sistema                                 |
|Baja de Documento                 |Eliminación de un documento del sistema                                     |
|Baja de Categoría                 |Eliminación de una categoría del sistema,la cual tendrá que pasar por un proceso de migración de documentos a otras categorías|
|Modificación de Administrador     |La modificación de los datos personales de un administrador en el sistema   |                                                         
|Modificación de Usuario           |La modificación de los datos personales de un usuario en el sistema         |                                                                         
|Modificación de Documento         |La modificación del nombre y/o categoría de un documento en el sistema      |                                                                         
|Modificación de Categoría         |La modificación del nombre y/o descripción de una categoría en el sistema   |                                                             
|Notificación de Usuario(Documento)|Tras el alta de un documento en el sistema aquellos usuarios ya sean administradores o comunes que sean etiquetados por nombre o DNI(Documento Nacional de Identidad) se les enviara una notificación del documento|                                                                                                                   
|Notificación de Usuario(Categoría)|Tras el alta de un documento en el sistema aquellos usuarios suscritos a una categoría correspondiente al documento serán notificados de la subida del mismo|
|Eliminación  de Notificaciones    |Si un usuario considera que ya ha sido notificado por la subida de un documento entonces podrá eliminar la notificación correspondiente|                                                                   

Nota: A excepción de la Modificación de usuario y la Eliminación de Notificaciones, el resto de funcionalidades unicamente las puede realizar un usuario Administrador.


### 3.3 Requerimientos de desempeño
El sistema será interactivo y los retrasos serán los mínimos posibles tales que en cada acto-respuesta del sistema no haya retrasos inmediatos. En caso de algún tipo de error se redireccionará  a la pagina principal de la aplicación.

### 3.4 Restricciones de diseño
-El sistema sera implementado en el lenguaje Ruby, utilizando de Frameworks: Sinatra,Sinatra/Web-Socket,Sequel y Minitest.

-Las vistas de la aplicación y  front-end sera implementado en Html y Css con el Framework Bootstrap 4 y la biblioteca de JavaScript jQuery. Así mismo se utilizara JavaScript para la implementación de funcionalidades respectivas a las vistas.

-El sistema seguira el siguiente diagrama de clases:
![Diagrama](/images/Diagrama_clases2.png)


<!-- TODO: give more guidance, similar to section 3 -->
<!-- ieee 15288:2015 -->
