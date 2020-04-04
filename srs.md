# Notificaciones

### 1) Introduction

#### 1.1) Prupose
```
The purpose of this document is to build a users system to manage notifications for the personnel of the computing department. It sends a notification every time a person is mentioned in a resolution or act.
```

#### 1.2) Terminology and conventions

- DB = Database
- Admin = Administrator


### 2)Global description

#### 2.1) Product perspective
```
This product will be designed and developed for the computing department in the National University of Rio Cuarto (U.N.R.C). It will be destinated to manage notifications to the persons who have been named or referenced in a resolution or act.
```

#### 2.2) Product functions
- Generation of notifications and automatic e-mails for the persons who have been named or referenced in a resolution or act.
- Upload and delete documents in the platform.
- Create and delete accounts.
- Read or download any document in the platform.
- Mark documents as favourite.
- See my favourite documents.
- Subscribe to tags.
- Desubscribe to tags.
- Delete mentions.

#### 2.3) Users caracteristics
```
Is destinated to proffesors in the computing department. All the proffesors in tis department have a excellent knowledge about computing.
```
#### 2.4) Restrictions
- Will be necesary internet access.
- Will be necesary to have an user account for access the platform.

### 3) Specific requirements

#### 3.1) Functional requirements
##### 3.1.1) Admin Functional requirements
```
This type of account can access all the functionalities of an user account, and, also some extra features like:
```
- Login As Admin: Identify yourself in the system (replaces user login)
- Logout: Close session (replaces user logout).
- Upload Document: Allows to the Admin to upload new documents.
- Add Tag: Allows to the admin to tag users, other admins or add any other tag to a document.
- Delete User Account: Allows to the admin to delete a user's account
- Change Password.
- Change Name.

##### 3.1.2) User Functional Requirements
- Sign Up As User: Account creation.
- Login As User: Identify yourself in the system (as user).
- Logout: Close session.
- Delete Account.
- Consult new mentions: Verify if the user has been mentioned in a new resolution or act.
- Mark mention as seen: distinguish mentions that has been seen from those that hasen't.
- Mark Document as favourite: save this mentions in a special folder.
- Subscribe To Tag: The user can subscribe to tags in wich is interested to recieve notifications about.
- Recieve Notification: Allows to the user to recieve notifications from new documents in wich is tagged or from the tags in wich is subscribed. At the same time, a e-mail will be sent to de asociated e-mail account.
- Read Document: Allows to the user to read a document.
- Search Name or Tag: Allows to the user to search Documents with a specific mention or tag.
- Recent Activity: Allows the user to see all the documents sorted by upload date.
- Delete mention.
- Change Password.
- Change Name.

#### 3.2) No Functional requirements
- Disponibility: Access to the data in every moment.
- Well Optimized: Accesible even from old hardware and slow internet connection.
- Security: Grant each account data security. 
- Manual of use: For consulting and questions.
- Intuitive design: Make it as easy as possible to use.
- Extensible and maintainable: generate a well modularized quality code as easy as possible to maintain and extend.


![](https://github.com/Nahuel95/notifications/tree/master/images/diagrama.png?raw=true)

































