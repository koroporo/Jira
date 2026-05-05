# Assignment 2

## Database Systems

```
Requirement: Use a DBMS such as Microsoft SQL Server or MySQL.
```
**Preliminary Report** Submit in the **5th practical session**. Refer to the
sample report: _Preliminary Report – Assignment 2_.

**Final Report** Submit in the **7th practical session**. Refer to the
sample report: _Final Report – Assignment 2_.

**LMS Deadline May 11, 2026**.


## Overview

```
This assignment requires students to implement the database designed in Assignment 1,
write SQL logic such as procedures, triggers, and functions, and build an application that
connects directly to the database.
```
```
Part Content Points
1 Create database tables and sample data 3
2 Write triggers, stored procedures, and functions 4
3 Implement an application connected to the database 3
Total 10
```
## 1. Create Tables and Sample Data [3 points]

### 1.1 Database Table Implementation [2 points]

Write SQL code to implement **all database tables** designed in Assignment 1.
Your implementation must include:

- Primary key constraints.
- Foreign key constraints.
- Data constraints.
- Semantic constraints usingCHECKorTRIGGER.

```
Important: Constraints that can be checked directly in table creation statements
must not be implemented using triggers.
```
### 1.2 Sample Data [1 points]

```
Create meaningful sample data for every table.
```
- Each table must contain at least **5 rows**.
- Data may be inserted manually or by usingINSERTstatements.
- Sample data must be realistic and suitable for presentation and testing.

## 2. Triggers, Stored Procedures, and Functions [

## points]

### 2.1 Insert, Update, and Delete Procedures [1 points]

Write stored procedures to **insert** , **update** , and **delete** data from **one selected table**.
The procedures must perform validation to ensure that table constraints are satisfied.


**Validation Requirements**

The system must display clear and meaningful error messages. Avoid generic messages such
as:

```
“Data entry error!”
```
```
Instead, error messages should clearly describe the problem.
Examples:
```
- Employee age must be greater than 18.
- Phone number format must be valid.
- Email format must be valid.
- Employee salary must be lower than the manager’s salary.

**Delete Procedure Requirement**

For theDELETEprocedure, clearly explain:

- When deletion is allowed.
- When deletion is not allowed.
- Why the restriction is necessary.
- What business purpose the restriction serves.

### 2.2 Triggers [1 points]

**2.2.1 Business Constraint Trigger**

Identify one business constraint that requires a trigger to enforce.
Your work must include:

- A clear description of the business constraint.
- Identification of the DML operations that may violate the constraint.
- Trigger code to check and enforce the constraint.

```
Reminder: Constraints that can be checked using table creation statements should
not be validated using triggers.
```
**2.2.2 Derived Attribute Trigger**

Choose one derived attribute and write trigger code to automatically calculate its value.
Your work must include:

- Identification of the derived attribute.
- Identification of the DML operations that may change its value.
- Trigger code to compute or update the attribute.

```
If a trigger calculates attributeAusing derived attributeB, thenBmust be calculated
first. Do not assume thatBis already correct.
```

```
Presentation Requirement
Prepare SQL statements and sample data to demonstrate trigger testing during the presen-
tation.
```
### 2.3 Query Stored Procedures [1 points]

Write two stored procedures that only contain queries for displaying data.
Each procedure must take input parameters corresponding to conditions in theWHERE
and/orHAVINGclauses.

```
Procedure 1
The first query must:
```
- Retrieve data from two or more tables.
- Use aWHEREclause.
- Use anORDER BYclause.

```
Procedure 2
The second query must:
```
- Join two or more tables.
- Use an aggregate function.
- UseGROUP BY.
- UseHAVING.
- UseWHERE.
- UseORDER BY.

```
Additional Requirements
```
- At least one stored procedure must retrieve data from the table used in Section 2.1.
- Prepare SQL statements and sample data to demonstrate the execution of these proce-
    dures during the presentation.

### 2.4 Functions [1 points]

Write two functions that satisfy all of the following requirements:

- ContainIFand/orLOOPstatements for calculations on stored data.
- Use cursors.
- Include a query to retrieve data for computation.
- Have input parameters.
- Validate input parameters.

## 3. Application Implementation [3 points]

```
Develop a web , mobile , or desktop application to demonstrate database connectivity.
```

### 3.1 Insert, Update, and Delete Screen [1 points]

Implement a screen that supports:

- Insert.
- Update.
- Delete.
    This screen must work with the table selected in Section 2.1.

```
The insert, update, and delete operations must be performed by calling the stored
procedures written in Section 2.1.
```
### 3.2 Data List Interface [1 points]

Create one interface that displays a data list retrieved from a stored procedure in Section
2.3.
This interface must be related to the table used in Section 2.1 and must allow users to
update and delete data from the list.
The interface should include:

- Search functionality.
- Sorting functionality.
- Input data validation.
- Logical error handling when updating or deleting data.
- Clear and specific error messages.
- Proper use of controls.
- A clear and user-friendly design.

```
Example: An interface that displays a product list with search, filter, and sorting
features. The user can create a new product, select a product row, update product
information, or delete a product.
```
### 3.3 Additional Procedure or Function Interface [1 points]

Create an interface that demonstrates at least one other procedure from Section 2.3 or one
function from Section 2.4.

```
This interface may reuse the same screen from Section 3.2 if it works with the same
table.
```
## 4. General Requirements

### Group Contribution

Every student in the group must write at least one SQL statement in Part 2.
This may be:


- A trigger.
- A function.
- A stored procedure.

```
Any student who does not contribute to Part 2 will receive no score for Assignment 2.
```
### SQL Evaluation Criteria

Triggers, functions, and procedures will be evaluated based on:

- Complexity.
- Completeness.
- Relevance to the application’s business logic.

### Application Requirements

The application must actually connect to the database created in Part 1.

```
If the application does not connect to the database, the application part will receive
no points.
```
The data list function must retrieve data by calling a stored procedure with input
parameters entered by the user.
These parameters should be used inWHEREorHAVINGclauses.
Examples of input controls include:

- Text boxes.
- Combo boxes.
- Calendar pickers.

## 5. Possible Point Deductions

Points may be deducted for the following issues:

- Functions, procedures, or triggers that are too similar or repetitive.
- Insufficient or meaningless sample data prepared for the presentation.
- A group member does not understand the purpose or content of each function, procedure,
    or trigger.
- A group member cannot perform required operations as instructed by the instructor.
- A group member does not participate in the project.

```
Example of repetition: Procedure 1 displays employees by name, while Procedure
2 displays employees by employee ID. These are too similar and may lead to point
deductions.
```

If a member does not participate, the other group members are responsible for notifying
the instructor to avoid group-wide deductions.



