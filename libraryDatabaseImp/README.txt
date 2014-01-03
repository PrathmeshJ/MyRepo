**************************************
* Title:                             *
*  MBPS Library Database             *
**************************************
* Authors:                           *
*  Sathya Ragavan                    *
*  Prathmesh Jakkanwar               *
*  Ben Arneberg                      *
*  Matthew Lemanski                  *
**************************************
* Course:                            *
*  CS5200-01                         *
*  Intro to Database Management      *
*  Kenneth Baclawski                 *
**************************************

To Run:
> cd library/dist
> java -jar CS5200_Library_Database.jar


Table of Contents:
./build
./class diagram
./data
./dist
./lib
./src
./usecase
./build.xml
./README.txt


Contents:
./build
  - class files generated from "src" by build.xml

./class diagram
  - database class diagrams submitted for the Project Design assignment

./data
  - files used to create or configure the project
  /books.csv
    - source CSV file with book data used to seed the database
  /JDBCConnection.properties
    - default JDBC connection properties (overridden in dist directory)
  /library.sql
    - SQL file used to create and seed the database
  /library.xsd
    - CSDL file for an OData endpoint

./dist
  - jar and javadocs generated from "build" and "src" by build.xml
  /data
    - JDBC connection properties and SQL create/seed file local to this distribution
  /javadoc
    - generated javadocs (open index.html to browse)
  /lib
    - extra libraries required to run this disribution
  /CS5200_Library_Database.jar
    - the executable JAR containing the MBPS Library Database
    - to run:
        > java -jar CS5200_Library_Database.jar

./lib
  - extra libraries required to run the program
  /mysql-connector-java.jar
    - a driver for MySQL

./src
  - project source files
  /neu
    /ccs
      /cs5200
        /mbps
          /ldb
            /LDBApplication.java
              - the entry point for the application
            /jdbc
              - files used to connect to and interact with the database
            /model
              - beans used to transport information between the views and the JDBC connector
            /nav
              - files used to navigate between frames and panels in the application
            /util
              - miscellaneous and shared files
            /view
              - files used to create the GUI
              /LaunchPage.java
                - the login page
              /admin
                - files specific to the Administrator role (extends Member features)
              /librarian
                - files specific to the Librarian role (extends Member features)
              /member
                - files specific to the Member role
              /user
                - files specific to the User role
              /util
                - miscellaneous and shared files

./usecase
  - database use cases submitted for the Project Requirements assignment

./build.xml
  - the Ant build file that produces the "dist" directory
  - to run:
      > ant

./README.txt
