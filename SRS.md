# Software Requirements Specification
## For <project name>

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

## 1. Introduction

### 1.1 Document Purpose
 This Project's purpose is to build a system capable of reporting whenever a member of the UNRC's (Universidad Nacional de Rio Cuarto) Computer Department is named or referenced in either a resolution or record.


### 1.2 Product Scope
The notification system called "Notifications" is an application that will allow the loading of documents and the notification to the mentioned persons, a person is mentioned with the use of the DNI

### 1.3 Definitions, Acronyms and Abbreviations
| Termino     | Descripción                                                        |
| ------------|--------------------------------------------------------------------|
|User         |person who can view documents and receive notifications if included |
|             |in said document, Identifies with your personal data                |
|Admin        |is a user who in turn has the power to upload documents and tag     |
|Document     |pdf file with scanned document                                      |
|Notification |is an alert indicating that the user has been named in a document   |
|Category     |Topic to which the document refers.                                 |


### 1.4 References
[1] Arsaute, A., Brusatti, F., Solivellas, D., Uva, M. "srs". Unpublished


## 2. Product Overview

### 2.1 Product Perspective
The notification system will allow people to know if an uploaded document makes reference to them, also an user subscribed in any of the document's categories will receive a notification as well.

### 2.2 Product Functions
Any type of user is able to see documents, subscribe to any category,and save documents for later revisiting. But only admins are able to upload documents


### 2.4 User Characteristics
An User is whom will be mentioned in an act or document and who will recieve the app's notification. Some users will be admins and these will be able to upload acts and documents.

## 3. Requirements

### 3.2 Functional
![Diagrama](/Diagrama_clases.png)

## 3.3 Quality of Service

## 3.4 Compliance

## 3.5 Design and Implementation
<!-- TODO: give more guidance, similar to section 3 -->
<!-- ieee 15288:2015 -->


