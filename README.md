# Terrorist Attacks Database Project

## Project Overview

This project is part of the **Database Fundamentals** course and focuses on designing and implementing a relational database for storing and analyzing data related to terrorist attacks. The database was developed to manage information on terrorist incidents, including attackers, targets, weapons, locations, and victims. The system supports detailed queries to analyze the impact and trends of terrorist activities.

## Group Information

- **Course**: Database Fundamentals (2021/2022), Group I-Z
- **Project Topic**: Terrorist Attacks (Project 5)
- **Group 66 Members**:
  - Antonio Vitale (Responsible) - a.vitale112@studenti.unisa.it
  - Beniamino Squitieri - b.squitieri@studenti.unisa.it
  - Nicola Lanzara - n.lanzara2@studenti.unisa.it
  - Fabrizio Sarno - f.sarno14@studenti.unisa.it

## Objectives

The main objective of this project is to design a relational database that captures detailed information related to terrorist attacks. The database is built to support a wide range of queries and analyses, enabling users to:
- Track the details of terrorist attacks, including the date, location, and method.
- Identify the attackers and terrorist groups involved.
- Analyze the weapons used and the impact on the victims.
- Investigate the relationships between different entities (e.g., terrorists, targets, and weapons).

## Key Features

### Conceptual Design
The conceptual design was modeled using an **Entity-Relationship (E-R) diagram** that represents the main entities involved in terrorist attacks. These entities include:
- **Terrorist**: Information about the attackers, including whether they acted as individuals or as part of a group.
- **Attack**: Comprehensive data on each attack, such as location, time, and method.
- **Weapon**: Details of the weapons used in the attacks, such as type and characteristics.
- **Victim**: Information about those impacted by the attacks, including the number of people injured or killed.

### Design Patterns
The database leverages two specific design patterns:
- **Ternary Relationship**: This pattern helps manage the complex relationships between multiple entities, such as how a single terrorist can use different weapons in different attacks.
- **Historicization**: This pattern is used to track changes over time, especially regarding how external organizations might influence terrorist activities.

### Normalization
The database was normalized up to **BCNF (Boyce-Codd Normal Form)** to eliminate redundancy and ensure efficient data management. Normalization steps were applied to avoid data anomalies and ensure that each piece of information is stored in only one place.

### Logical Schema
The logical schema reorganized the E-R diagram into a set of tables that reflect the normalized structure. The main tables in the schema include:
- **Terrorist**: Stores data about individuals or groups involved in attacks.
- **Attack**: Captures detailed information about each attack.
- **Weapon**: Contains details about the types of weapons used.
- **Location**: Provides information about where the attacks took place.
- **Victim**: Contains data on the individuals affected by the attacks.

### SQL Implementation
The database was implemented using SQL. Queries were written to perform various tasks such as retrieving terrorist information, analyzing weapon usage, and listing victims affected by specific attacks. These queries allow for a detailed analysis of the data stored in the database.

## Entity-Relationship Diagram (ERD)

The ERD designed for this project captures the relationships between the key entities:
- **Attack**: Each attack is linked to one or more terrorists, weapons, and locations.
- **Terrorist**: Represents both individual attackers and terrorist groups.
- **Weapon**: Links each attack to the specific weapons used.
- **Location**: Defines the geographical aspect of the attack.
- **Victim**: Tracks the impact of the attacks on people.

This diagram allows for a comprehensive view of how the different entities interact in the context of terrorist activities.

## Query and Analysis

The database supports a wide range of queries that can answer important questions such as:
- Which terrorists are responsible for the most attacks?
- What are the most frequently used weapons?
- In which locations do attacks occur most frequently?
- What is the impact on victims in terms of casualties and injuries?

These queries provide insights into patterns and trends in terrorist activities, helping to understand the scope and impact of the data stored.

## Results and Future Improvements

### Results
The database effectively stores and manages detailed information about terrorist attacks. It supports complex queries that can retrieve and analyze data on attackers, weapons, and victims. The normalization process ensures efficient data handling, and the use of design patterns adds flexibility to the database.

## Contact Information


- **Beniamino Squitieri** - bennibeniamino@gmail.com

