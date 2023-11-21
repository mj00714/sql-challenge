-- data modeling
  -- see the ERD file in the github repo

-- data engineering

-- create departments table with primary key 'dept_no'
CREATE TABLE "departments" (
    "dept_no" VARCHAR(50)   NOT NULL,
    "dept_name" VARCHAR(50)   NOT NULL,
    CONSTRAINT "pk_departments" PRIMARY KEY (
        "dept_no"
     )
);

-- create dept_emp table with primary keys 'emp_no' and 'dept_no' since there are multiple values for dept_no
CREATE TABLE "dept_emp" (
    "emp_no" INT   NOT NULL,
    "dept_no" VARCHAR(50)   NOT NULL,
    CONSTRAINT "pk_dept_emp" PRIMARY KEY (
        "emp_no","dept_no"
     )
);

-- create dept_manager table with primary keys 'dept_no' and 'emp_no' since there are multiple values for dept_no
CREATE TABLE "dept_manager" (
    "dept_no" VARCHAR(50)   NOT NULL,
    "emp_no" INT   NOT NULL,
    CONSTRAINT "pk_dept_manager" PRIMARY KEY (
        "dept_no","emp_no"
     )
);


-- create employees table with primary key emp_no
CREATE TABLE "employees" (
    "emp_no" INT   NOT NULL,
    "emp_title_id" VARCHAR(50)   NOT NULL,
    "birthdate" DATE   NOT NULL,
    "first_name" VARCHAR(50)   NOT NULL,
    "last_name" VARCHAR(50)   NOT NULL,
    "sex" VARCHAR(50)   NOT NULL,
    "hire_date" DATE   NOT NULL,
    CONSTRAINT "pk_employees" PRIMARY KEY (
        "emp_no"
     )
);

-- create salaries table with primary key 'emp_no'
CREATE TABLE "salaries" (
    "emp_no" INT   NOT NULL,
    "salary" INT   NOT NULL,
    CONSTRAINT "pk_salaries" PRIMARY KEY (
        "emp_no"
     )
);

-- create titles table with primary key 'title_id'
CREATE TABLE "titles" (
    "title_id" VARCHAR(50)   NOT NULL,
    "title" VARCHAR(50)   NOT NULL,
    CONSTRAINT "pk_titles" PRIMARY KEY (
        "title_id"
     )
);

-- link the foreign keys, based on the ERD diagram

ALTER TABLE "dept_emp" ADD CONSTRAINT "fk_dept_emp_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");

ALTER TABLE "dept_emp" ADD CONSTRAINT "fk_dept_emp_dept_no" FOREIGN KEY("dept_no")
REFERENCES "departments" ("dept_no");

ALTER TABLE "dept_manager" ADD CONSTRAINT "fk_dept_manager_dept_no" FOREIGN KEY("dept_no")
REFERENCES "departments" ("dept_no");

ALTER TABLE "employees" ADD CONSTRAINT "fk_employees_emp_no" FOREIGN KEY("emp_no")
REFERENCES "salaries" ("emp_no");

ALTER TABLE "employees" ADD CONSTRAINT "fk_employees_emp_title_id" FOREIGN KEY("emp_title_id")
REFERENCES "titles" ("title_id");

-- import the CSV files into PostgreSQL DB in this order: titles, salaries, employees, departments (see code to remove quotes from the departments table import), dept_emp, dep_manager

UPDATE departments
SET dept_name = REPLACE(dept_name, '"', '');

UPDATE departments
SET dept_no = REPLACE(dept_no, '"', '')


-- data analysis

-- 1. list the employee number, last name, first name, sex and salary for each employee (order by emp_no, asc)
CREATE VIEW AllEmployeesSalary AS
SELECT
  employees.emp_no,
  employees.last_name,
  employees.first_name,
  employees.sex,
  salaries.salary
FROM
  employees
JOIN
  salaries ON employees.emp_no = salaries.emp_no;

SELECT * FROM AllEmployeesSalary ORDER BY emp_no ASC

-- 2. List the first name, last name and hire date for the employees who were hired in 1986

SELECT first_name, last_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 1986
ORDER BY hire_date ASC;

-- 3. List the manager of each department along with their department number, department name, employee number, last name, and first name. 

CREATE VIEW ManagerDepartment AS
SELECT
  dept_manager.dept_no,
  departments.dept_name,
  dept_manager.emp_no,
  employees.last_name,
  employees.first_name
FROM
  dept_manager
JOIN
  departments ON dept_manager.dept_no = departments.dept_no
JOIN
  employees ON dept_manager.emp_no = employees.emp_no;

SELECT * FROM ManagerDepartment;

-- 4. List the department number for each employee along with that employee’s employee number, last name, first name, and department name.

CREATE VIEW EmployeeDept AS
SELECT
  employees.emp_no,
  employees.last_name,
  employees.first_name,
  departments.dept_name
FROM
  employees
JOIN
  dept_emp ON employees.emp_no = dept_emp.emp_no
JOIN
  departments ON dept_emp.dept_no = departments.dept_no;

SELECT * FROM EmployeeDept;
  
-- 5. List first name, last name, and sex of each employee whose first name is Hercules and whose last name begins with the letter B.

SELECT first_name, last_name, sex
FROM employees
WHERE first_name = 'Hercules' AND last_name LIKE 'B%'
ORDER BY last_name ASC


-- 6. List each employee in the Sales department (d007), including their employee number, last name, and first name.

SELECT
  emp_no,
  last_name,
  first_name
  FROM employees
  WHERE emp_no
  IN (
    SELECT emp_no
    FROM dept_emp
    WHERE dept_no
    IN (
      SELECT dept_no
      FROM departments
      WHERE dept_name = 'Sales'
    )
  )
  ORDER BY emp_no ASC;

-- 7. List each employee in the Sales and Development departments, including their employee number, last name, first name, and department name.

CREATE VIEW SalesDevelopmentDept AS
SELECT
  employees.emp_no,
  employees.last_name,
  employees.first_name,
  departments.dept_name
FROM 
  employees
JOIN
  dept_emp ON employees.emp_no = dept_emp.emp_no
JOIN
  departments ON dept_emp.dept_no = departments.dept_no;

SELECT * FROM SalesDevelopmentDept
WHERE dept_name IN ('Sales', 'Development');


-- 8. List the frequency counts, in descending order, of all the employee last names (that is, how many employees share each last name).

SELECT last_name, COUNT(*) AS frequency
FROM employees
GROUP BY last_name
ORDER BY frequency DESC;