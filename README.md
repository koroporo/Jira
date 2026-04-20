## 🚀 Setup Instructions

### 1. Prerequisites
* Install **Docker** and **Docker Desktop** (for Windows).
* Install **Git**.

### 2. Launch Database
Open your terminal/PowerShell in the project root and run:
```bash
docker-compose up -d

### 3. SQL Script Structure (Part 1 & 2)
[cite_start]Scripts must be executed in the following order to handle foreign key dependencies and satisfy assignment requirements[cite: 8, 35]:

* [cite_start]**database/01_schema.sql**: Implementation of all database tables including Primary Keys, Foreign Keys, and constraints (CHECK or TRIGGER)[cite: 8, 9, 10, 11].
* **database/02_data.sql**: Creation of meaningful sample data with at least 5 rows per table[cite: 14, 15].
* **database/03_procedures.sql**: Stored procedures for Insert, Update, and Delete operations with built-in data validation[cite: 16, 18, 19].
* **database/04_triggers.sql**: Implementation of triggers for business constraints and derived attribute calculations[cite: 24, 25, 29].
* **database/05_functions.sql**: Functions containing IF/LOOP statements and Cursors for complex computations[cite: 44, 46, 47].

---

## 📝 Critical Development Rules

### 🔴 Database Connectivity (Section 3.3)
* The application **MUST ACTUALLY CONNECT** to the database created in Part 1[cite: 51, 67].
* Use a `.env` file for credentials; do not hardcode passwords to ensure security and portability.

### 🔴 Procedure Calls (Section 3.1 & 3.2)
* **DO NOT** write raw `SELECT`, `INSERT`, `UPDATE`, or `DELETE` queries directly in the application code[cite: 64, 66].
* [cite_start]The application **MUST** perform all data manipulations and retrievals by calling the Stored Procedures defined in Part 2[cite: 64, 66].

### 🔴 Error Handling
* [cite_start]Stored procedures must validate data and return **meaningful error messages** that clearly indicate the specific error (e.g., valid email formats or salary logic)[cite: 19, 20, 21].
* Generic error messages are not allowed[cite: 20].

---

## 📅 Deadlines & Deliverables
* [cite_start]**Session 5**: Preliminary Report submission[cite: 3].
* [cite_start]**Session 7**: Final Report submission and Presentation[cite: 4].
* **Final Deadline**: May 11th, 2026 (LMS submission)[cite: 5].

---

## ⚠️ Git Guidelines
* **Ignore Environment Files**: Add `.env`, `.idea/`, and `.vscode/` to your `.gitignore` to avoid environment conflicts between IntelliJ and VS Code.
* **Sync Database Changes**: Always commit changes in the `database/` folder so teammates on different OS (Ubuntu/Windows) can update their local Docker containers.
* [cite_start]**Individual Contribution**: Every member must write at least one SQL statement (trigger, function, or procedure) to receive a score[cite: 59, 60].
