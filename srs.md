# Software Requirements Specification
## For Notifications System

Version 0.1  
Prepared by <author>  
<organization>  
<date created>  

Table of Contents
=================
* [Revision History](#revision-history)
* 1 [Introduction](#1-introduction)
  * 1.1 [Document Purpose](#11-document-purpose)
  * 1.2 [Product Scope](#12-product-scope)
  * 1.3 [Definitions, Acronyms and Abbreviations](#13-definitions-acronyms-and-abbreviations)
  * 1.4 [References](#14-references)
* 2 [Product Overview](#2-product-overview)
  * 2.1 [Product Perspective](#21-product-perspective)
  * 2.2 [Product Functions](#22-product-functions)
  * 2.3 [Product Constraints](#23-product-constraints)
  * 2.4 [User Characteristics](#24-user-characteristics)
* 3 [Requirements](#3-requirements)
  * 3.2 [Functional](#32-functional)
  * 3.3 [Quality of Service](#33-Quality-of-Service)
  * 3.4 [Compliance](#34-Compliance)
  * 3.5 [Design and Implementation](#35-Design-and-Implementation)

## Revision History
| Name  | Date     | Reason For Changes  | Version   |
| ----  | -------- | ------------------- | --------- |
|       |          |                     |           |
|       |          |                     |           |

## 1. Introduccion

### 1.1 Proposito del Documento
 El proposito de este proyecto es crear un sistema capaz de notificar cuando un miembro del departamento de computacion de la U.N.R.C. (Universidad Nacional de Rio Cuarto) ha sido nombrado o se le ha hecho referencia en algun acta o resolucioon


### 1.2 Product Scope
El sistema de notificaciones llamado "Notifications" es una aplicacion que permitira la carga de documentos y notificar a personas mencionadas en el mismo (una persona es mencionada con el uso del DNI).

### 1.3 Definitions, Acronyms and Abbreviations
| Termino     | Descripción                                                        |
| ------------|--------------------------------------------------------------------|
|Usuario      |persona que puede ver documentos y recibir notificaciones si está   |
|             |incluido en dicho documento, Se registra con sus datos personales   |
|Admin        |Es un usuario que tiene permitido cargar documentos y etiquetar     |
|Document     |Documento escaneado a pdf.                                          |
|Notification |Alerta indicando que el usuario ha sido nombrado en un documento    |
|Category     |Tema al cual el documento refiere                                   |


### 1.4 References
[1] Arsaute, A., Brusatti, F., Solivellas, D., Uva, M. "srs". Unpublished


## 2. Product Overview

### 2.1 Perspectiva del Producto.
El sistema de notificaciones permitirá a las personas saber si un documento cargado hace referencia a ellos, cualquier usuario recibirá notificaciones si está suscrito a la categoría que corresponde al documento.

### 2.2 Funcionalidades del Producto.
Cualquier tipo de usuario tiene permitido ver documentos, suscribirse a cualquier categoria,y guardar documentos para ver luego.Unicamente los Admins tienen permitido cargar documentos.

### 2.4 Caracteristicas de Usuario
Un user es aquel que sera  nombrado en un acta o documento y quien recibira la notificacion de la aplicacion de ser el caso. Alguno usuarios seran admins y estos tendran permitido cargar actas y documentos.

## 3. Requirements

### 3.2 Funcional
![Diagrama](/images/Diagrama_clases.png)

## 3.3 Quality of Service

## 3.4 Compliance

## 3.5 Design and Implementation
![Plantilla](/images/admin.svg)
![Plantilla](/images/newadmin.svg)
![Plantilla](/images/Pagina1.svg)
![Plantilla](/images/Pagina2.svg)
![Plantilla](/images/Pagina3.svg)
![Plantilla](/images/subir_documentos.svg)
![Plantilla](/images/Subs.svg)
![Plantilla](/images/vista_previa_documentos.svg) 
<!-- TODO: give more guidance, similar to section 3 -->
<!-- ieee 15288:2015 -->
