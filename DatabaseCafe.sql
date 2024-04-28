CREATE TABLE Owners (
    owner_id INT PRIMARY KEY,
    username TEXT UNIQUE,
    password_hash TEXT,
    name TEXT,
    email TEXT,
    phone_number TEXT
);

CREATE TABLE MenuItems (
    item_id INT PRIMARY KEY,
    name TEXT,
    description TEXT,
    price DECIMAL(10, 2),
    category TEXT
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT,
    subtotal DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id)
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name TEXT,
    email TEXT,
    phone_number TEXT,
    loyalty_points INT
);

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name TEXT,
    role TEXT,
    email TEXT,
    phone_number TEXT
);

CREATE TABLE Tables (
    table_id INT PRIMARY KEY,
    capacity INT
);

CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY,
    customer_id INT,
    table_id INT,
    reservation_date DATETIME,
    status TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (table_id) REFERENCES Tables(table_id)
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    order_id INT,
    transaction_date DATETIME,
    payment_method TEXT,
    amount DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

CREATE TABLE Ingredients (
    ingredient_id INT PRIMARY KEY,
    name TEXT,
    quantity_in_stock INT
);

CREATE TABLE EmployeeSchedule (
    schedule_id INT PRIMARY KEY,
    employee_id INT,
    date DATE,
    start_time TIME,
    end_time TIME,
    status TEXT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
