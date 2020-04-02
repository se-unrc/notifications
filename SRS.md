# Software Requirements Specification
## For Document Upload & Notification System

Version 0.1  
Prepared by Juan Ignacio Alanis Jeremias Parladorio 
Universidad Nacional de Rio Cuarto 
2nd April 2020

Table of Contents
=================
* [Revision History](#revision-history)
* 1 [Introduction](#1-introduction)
  * 1.1 [Document Purpose](#11-document-purpose)
  * 1.2 [Product Scope](#12-product-scope)
  * 1.3 [Definitions, Acronyms and Abbreviations](#13-definitions-acronyms-and-abbreviations)
  * 1.4 [References](#14-references)
  * 1.5 [Document Overview](#15-document-overview)
* 2 [Product Overview](#2-product-overview)
  * 2.1 [Product Perspective](#21-product-perspective)
  * 2.2 [Product Functions](#22-product-functions)
  * 2.3 [Product Constraints](#23-product-constraints)
  * 2.4 [User Characteristics](#24-user-characteristics)
  * 2.5 [Assumptions and Dependencies](#25-assumptions-and-dependencies)
* 3 [Requirements](#3-requirements)
  * 3.1 [External Interfaces](#31-external-interfaces)
    * 3.1.1 [User Interfaces](#311-user-interfaces)
    * 3.1.2 [Hardware Interfaces](#312-hardware-interfaces)
    * 3.1.3 [Software Interfaces](#313-software-interfaces)
  * 3.2 [Functional](#32-functional)
    * 3.2.1 [Class Diagram](#321-class-diagram)
    * 3.2.2 [User stories](#322-user-stories)
  * 3.3 [Design Requirements](#33-design-requirements)
  * 3.4 [Design Constraints](#34-design-constraints)

## Revision History

| Name | Date    | Reason For Changes    | Version   |
| ---- | ------- | ----------------------| --------- |
| DUNS     | 04/02/2020 | None. First version| 0.1        | 

## 1. Introduction
This document provides specifications of the characteristics and general requirements of the project's software.

### 1.1 Document Purpose
The purpose of this document is to provide a detailed description of the software "Document Upload & Notification System". This will illustrate the system's development and will also explain its functionality, its limitations, its interface and the interaction with its possible users. This document is mainly destined to be proposed to a professor for its approval and also to serve as a reference to develop the system.


### 1.2 Product Scope
The "Document Upload & Notification System" is a web-based software intended to be utilized to upload official Universidad Nacional de Rio Cuarto's documents. In this software users will be able to log in, either as administrators (those who permission to do so) or common users. 
Administrators are going to use this software to upload official univeristy documents, tagging those registered users appearing in said documents. They are also going to be able to edit these documents, meaning: chaging tags, deleting, and overseeing these changes in general. Furthermore, they are going to tag the category to which the document belongs to. The registered users are going to use this software to read the uploaded documents and will also be notified of the documents they are either tagged in or that belong to the user's interest category. Invited users on the other hand are only going to be able to use this software to read the documents that have been uploaded.

### 1.3 Definitions, Acronyms and Abbreviations

| Term          | Definition                                                       | 
| :------------:|:-----------------------------------------------------------------| 
| Admin(s)        | Registered users with an administration permit |
| Registered users/RU (acronym) | Users who are registered in the system and don't have    an administration permit |
| Invited users | Users who have not registered but can access the system | 
| Notification  | A email to the person who has been tagged in in a document or if that uploaded document belongs to their interest category.       |
| Document      | Universidad Nacional de Rio Cuarto's official record documents.  |
| Tagged user   | Registered user who has been tagged in a document.               |
| Category      | Topic to which the document refers.                           |
| Interest category | Specific(s) category(ies) that the user has chosen to        receive notifications from. |
| Software/System/Website/Site/DUNS (acronym) | Document Upload & Notification System  |
|Doc(s) | Documents. |
| UI | User interface. |
| DESC | Description.  |
| RAT | Rational.|
|DEP | Dependencies. |
| US | User story.|
| IC(s) | Interest category(ies). |

### 1.4 References

[1] Arsaute, A., Brusatti, F., Solivellas, D., Uva, M. "srs". Unpublished

[2] https://github.com/jam01/SRS-Template

[3] Geagea, S., Zhang, S., Sahlinn, N., Hasibi, F., Hammed, F., Rafiyan, E., Ekberg M. *Amazing Lunch Indicator SRS* (http://www.cse.chalmers.se/~feldt/courses/reqeng/examples/srs_example_2010_group2.pdf)
 
### 1.5 Document Overview
The remaining part of this document includes 2 other sections. The second section
provides a general overview of the software's functionality and the system's interaction with the different types of users. Furthermore, it also mentions the software constraints and its dependencies.

## 2. Product Overview
This section gives a general overview of the whole system. The system will be explained in its context in order to explain its own basic functionalities, assumptions and restrictions. It will also describe the parties interested in utilizing this software and the available functionalities for each of them.

### 2.1 Product Perspective
This software is a new, unprecedented product that arises from the need of having a 
digital, web-based document uploading, processing and notification-sending system.
The system will consist of a web application in which documents will be uploaded, notifying its users accordingly (see item 4 of subsection 2.2 for the meaning of 'accordingly').

### 2.2 Product Functions
This software must perform 6 major fuctions:
1. Allow its administrators to upload official university documents.
2. Allow its administrators to classify the uploaded documents into their respective categories.
3. Allow its administrators to tag every registered user appearing in any of the uploaded documents.
4. Allow its administrators to invite a registered user so that they can become an administrator as well.
5. Notify its registered users whenever:
    1. they have been tagged in a document,
    2. a document of their interest category has been uploaded,
    3. both of the above.
6. Publicly list all uploaded documents and allow searching based on any of the following criteria:
    1. Date
    2. User involved
    3. Category

### 2.3 Product Constraints 
This system is constrained by the platform utilized  to access the website: it will only be adjusted to comply with web browser requirements, specifically resolution and design-wise. Users trying to access from a mobile phone or a tablet may find difficulties in interacting properly with the system.

The internet connection is certainly a constraint for the website: a slow internet speed may harm the user experience, in the sense that it may be difficult to upload new documents, to see any document, or even for the website to load at all.

Another constraint will be the capacity of the database, given that at some point the storage may not be sufficient for all the documents, in which case it will have to be updated. 

### 2.4 User Characteristics
There are three types of users that interact with this software:
1. Invited users
2. Registered users
3. Administrators

Each of these user types has a different system usage. 

* **Invited users**: can only make use of DUNS to list and search for documents according to the available criteria (see item 5 in subsection 2.2), and open whichever document they want. Does NOT requiere a sign up.

* **Registered users**: shares all the characteristics of the invited users, plus:
    * Subscribe to an interest category
    * Be notified accordingly 

* **Administrators**: shares all the characteristics of the registered users, plus:
    * Upload documents
    * Classify documents
    * Edit documents
    * Invite another RU to become an admin

### 2.5 Assumptions and Dependencies
The requirements for running this software depend on the following assumptions:
1. that the user has an functioning internet connection,
2. that the user has a web browser capable of running the site.


## 3. Requirements
This section contains all of the system's functional and quality requirements, it gives describes the system as a whole, with its features.

### 3.1 External Interfaces
In this subsection we shall define the inputs and outputs of the system. 


#### 3.1.1 User interfaces

Here we will show what the interface structure of the system should be like from the viewpoint of all kind of users. For this purpose, we will show pictures of the different pages the system is required to have in order to ensure an intuitive, logical user interface.

##### Unregistered/unlogged page

A first time user, or a registered user who has not yet logged in, will have to interact with a home page akin to the one depicted below. Here, they can see the documents with all of their attributes, and perform search operations, however they can do no more than that.

![Imgur](https://i.imgur.com/Ox5cYOE.png)

###### **Log in/Sign up pages**

An unregistered or unlogged user has two choices if they wish to 'unlock' the registered user's features: to sign up, or to log in, respectively.

* **Sign up page**
  Here the user who wishes to sign up will have to provide some personal information, namely their full name, their ID number, their chosen username, their email account, and their chosen password. This will grant the as-of-now registered user all of this kind of user's features, as they have been previously listed and described. This should be done by interacting with an UI akin to the one pictured below:

  ![Imgur](https://i.imgur.com/dcBr3Pl.png)
  
* **Log in page**
  An user who already has an account, but who has not yet logged into the system, can do so by clicking the 'log in' option in the upper right portion of the screen as pictured in the **Unregistered/unlogged page** item. Here they will have to provide their email account and their password, in order to gain access. This should be done by interacting with an UI akin to the one pictured below:

  ![Imgur](https://i.imgur.com/LGdb77p.png)

##### Registed users' pages

An user who has already logged into the system, will interact with two different home pages, depending on whether he is a regular user or an administrator.

###### **Regular user's pages**

  * **Home page**
    A regular user's home page will have the same features as that of the unregistered user's, except they will have a menu in the upper right portion on the screen to access their profile, and to log out of the system. It should look similar to the picture below:

    ![Imgur](https://i.imgur.com/KfrYr1f.jpg)

  * **Profile page**
    A regular user profile page will allow them to select those categories they wish to subscribe to in order to receive notifications, and also to edit their personal information given at the sign up stage. It should look akin to what is pictured below:

    ![Imgur](https://i.imgur.com/y6B7pl7.jpg)

###### **Admins' pages**

  * **Administrator home page**
    An administrator will look at a home page similar to that of the regular user, except they will have two extra features availabe: they'll be able to edit and delete any of the uploaded documents shown in the home page. It should like the picture below:

    ![Imgur](https://i.imgur.com/Ke8Bo3o.jpg)

  * **Admin's profile page**

    An administrator will have the same features as the regular user in their profile page, plus the ability to upload a document, with all of its attributes. It will also have a feature allowing an administrator to invite another user to become an administrator. It will look akin to the image below:
    
    ![Imgur](https://i.imgur.com/WK0Eg7y.png)

#### 3.1.2 Hardware interfaces
Given that this software is a websute it has no designated hardware. The hardware connection to the database server is administrated by the operating system.

#### 3.1.3 Software interfaces
The communication between the database and the website consists in operations related to both reading (users and admins) and data modification (admins). 

### 3.2 Functional
This section includes all fundamental requierements that specify all the system's actions.

#### 3.2.1 Class Diagram

![Imgur](https://i.imgur.com/u6RcPzR.jpg)

#### 3.2.2 User Stories 

##### 3.2.2.1 All User Classes - The General User

###### User story 1.1

**ID:** US1
TITLE: See documents online
DESC: All users should be allowed to see the uploaded documents in the website. 
RAT: In order for a user to see documents online.
DEP: None.

###### User story 1.2

**ID:** US2
TITLE: Download uploaded documents
DESC: All users should be allowed to download the documents uploaded to the site by clicking on an icon next the document file.
RAT: In order for a user to see download documents.
DEP: None.

###### User story 1.3

**ID:** US3
TITLE: Search documents
DESC: All users should be allowed to search documents by the following criteria: users involved, date, and category. This includes searching them by only one of those filters, or by any combination of them.
RAT: In order for a user to search for documents.
DEP: None.


##### 3.2.2.2 User Class 2 - The Unregistered User

###### User story 2.1

**ID:** US4
TITLE: Sign up
DESC: Given that the user has now accesed the website, they should be a allowed to register into the site. They will have to provide their full name, ID number, username, email, and password.
RAT: In order for an unregistered user to sign up.
DEP: None.

##### 3.2.2.3 User Class 3 - The Registered User

###### User story 3.1

**ID:** US5
TITLE: Receive notifications when tagged
DESC: As a RU, I want to receive notifications when I am tagged in a document.
RAT: In order for a RU to receive notifications whenever tagged.
DEP: US4

###### User story 3.2

**ID:** US6
TITLE: Log in
DESC: As a RU, I want to log into my account. For this I need my email account and my password.
RAT: In order for a registered user to log in.
DEP: US4

###### User story 3.3.

**ID:** US7
TITLE: Forgot my password
DESC: As a RU, I forgot my password. To retrieve it I need to give the website my email account.
RAT: In order for a RU to retrieve their password.
DEP: US4

###### User story 3.4

**ID:** US8
TITLE: Edit my profile
DESC: As a RU, I wanto be able to edit my profile: change my full name, my username, my password, my email, and my ID number.
RAT: In order for a RU to edit their profile.
DEP: US6

###### User story 3.5

**ID:** US9
TITLE: Edit my interest categories
DESC: As a RU, I want to subscribe to new categories, or to unsuscribe to categories I had previously subbed to.
RAT: In order for a RU to edit their interest categories.
DEP: US6

###### User story 3.6

**ID:** US10
TITLE: Receive notifications from my interest categories
DESC: As a RU, I want to receive notifications whenever a new document is uploaded to one of my interest categories.
RAT: In order for a RU to receive notifications from their ICs.
DEP: US9

##### 3.2.2.4 User Class 4 - The Admin Class

###### User story 4.1 

**ID:** US11
TITLE: Upload new document
DESC: As an admin, I want to upload a new document as need be. For this I will need the PDF file, the title of the document, the tagged users, the date, and the document's category.
RAT: In order for an admin to upload a new document.
DEP: US4

###### User story 4.2

**ID:** US12
TITLE: Edit docs
DESC: As an admin, I want to edit any document that has already been uploaded. This means chaging its title, date, PDF file, users tagged to the doc, and the doc's category.
RAT: In order for an admin to edit uploaded documents.
DEP: US11

###### User story 4.3

**ID:** US13
TITLE: Delete documents
DESC: As an admin, I want to be able to delete documents that may have been wrongfully uploaded, or that for some reason are no longer relevant.
RAT: In order for an admin to delete documents, no questions asked.
DEP: US11

###### User story 4.4

**ID:** US14
TITLE: Invite admin
DESC: As an admin, I want to invite another RU in order for them to become an admin. For this I only need their username.
RAT: In order for an admin to invite some other RU to become an admin.
DEP: US4

### 3.3 Design Requirements 

**ID:** DR1
TITLE: Simple search feature
DESC: The search feature should be simple and easy for the user to use.
RAT: In order for the user to easily find the search feature and have no issues using it.
DEP: None.

**ID:** DR2
TITLE: Simple document visualization
DESC: All documents should be easily identifiable, and ready to be read by clicking on them.  
RAT: In order for the user to easily indetify and read the documents.
DEP: None.

**ID:** DR3
TITLE: Simple download feature
DESC: All documents should be easily downloaded by clicking on a download icon.
RAT: In order for the user to easily download any document.
DEP: None.

**ID:** DR4
TITLE: Ease of subscribing/unsuscribing to an IC
DESC: All ICs should be listed on the user's profile so that they can easily subscribe to any of them by checking a small box next to the ICs name, or unsubscribe by doing the exact opposite.
RAT: In order for the user to easily subscribe/unsubscribe to an IC.

**ID:** DR5
TITLE: Usage of 'Add new doc' feature
DESC: This feature should be intuitive and very easy to use for all administrators, who may not be technical people.
RAT: In order for admins to easily upload new docs.

### 3.4 Design Constraints

**ID:** DC1
TITLE: Having the docs in your computer
DESC: The admin must have the document's PDF file stored in his computer in order to be able to upload it, any other kinds of storage will not work (URLs, etc).

**ID:** DC2
TITLE: Having an email account
DESC: The system is designed so that all users must have an email account.

**ID:** DC3
TITLE: Having an ID number
DESC: Only people with ID numbers will be aeble to sign up for an account.


