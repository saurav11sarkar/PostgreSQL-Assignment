-- Active: 1750004681527@@127.0.0.1@5432@bookstore_db@public
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    price NUMERIC(8, 2) check (price >= 0),
    stock INTEGER check (stock >= 0),
    published_year INT check (
        published_year > 1000
        and published_year <= EXTRACT(
            YEAR
            FROM CURRENT_DATE
        )
    )
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers (id),
    book_id INTEGER REFERENCES books (id),
    quantity INTEGER check (quantity > 0),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO
    books (
        title,
        author,
        price,
        stock,
        published_year
    )
VALUES (
        'The Pragmatic Programmer',
        'Andrew Hunt',
        40.00,
        10,
        1999
    ),
    (
        'Clean Code',
        'Robert C. Martin',
        35.00,
        5,
        2008
    ),
    (
        'You Don''t Know JS',
        'Kyle Simpson',
        30.00,
        8,
        2014
    ),
    (
        'Refactoring',
        'Martin Fowler',
        50.00,
        3,
        1999
    ),
    (
        'Database Design Principles',
        'Jane Smith',
        20.00,
        0,
        2018
    );

INSERT INTO
    customers (name, email, joined_date)
VALUES (
        'Alice',
        'alice@email.com',
        '2023-01-10'
    ),
    (
        'Bob',
        'bob@email.com',
        '2022-05-15'
    ),
    (
        'Charlie',
        'charlie@email.com',
        '2023-06-20'
    );

INSERT INTO
    orders (
        customer_id,
        book_id,
        quantity,
        order_date
    )
VALUES (1, 2, 1, '2024-03-10'),
    (2, 1, 1, '2024-02-20'),
    (1, 3, 2, '2024-03-05');



SELECT * FROM books;

SELECT * FROM customers;

SELECT * FROM orders;

-- PostgreSQL Problems & Sample Outputs;



-- 1️⃣ Find books that are out of stock. (stock = 0)

SELECT title FROM books WHERE stock = 0;



-- 2️⃣ Retrieve the most expensive book in the store.

-- Sample Output:

-- | id  | title       | author        | price | stock | published_year |
-- | --- | ----------- | ------------- | ----- | ----- | -------------- |
-- | 4   | Refactoring | Martin Fowler | 50.00 | 3     | 1999           |

SELECT * FROM books ORDER BY price DESC LIMIT 1;



-- 3️⃣ Find the total number of orders placed by each customer.

-- Sample Output:

-- | name    | total_orders |
-- | ------- | ------------ |
-- | Alice   | 2            |
-- | Bob     | 1            |

SELECT c.name, count(o.id) as total_orders
FROM customers AS c
    JOIN orders AS o ON c.id = o.customer_id
GROUP BY
    c.name;




-- 4️⃣ Calculate the total revenue generated from book sales.

-- Sample Output:

-- total_revenue
-- -----------------
-- 135.00

SELECT sum(b.price * o.quantity) as total_revenue
FROM books AS b
    JOIN orders AS o ON b.id = o.book_id;




-- 5️⃣ List all customers who have placed more than one order.

-- Sample Output:

-- | name    | orders_count |
-- | ------- | ------------ |
-- | Alice   | 2            |

SELECT c.name, COUNT(o.id) AS orders_count
FROM customers AS c
    JOIN orders AS o ON c.id = o.customer_id
GROUP BY
    c.name
HAVING
    COUNT(o.id) > 1;




-- 6️⃣ Find the average price of books in the store.

-- Sample Output:

-- avg_book_price
-- ----------------------------
-- 35.00

SELECT round(avg(price), 2) AS avg_book_price FROM books;




-- 7️⃣ Increase the price of all books published before 2000 by 10%.

-- Sample Output: (No table output, but affected rows will be updated accordingly.)

-- | id  | title                        | author             | price  | stock | published_year |
-- |-----|------------------------------|--------------------|--------|-------|----------------|
-- | 1   | The Pragmatic Programmer     | Andrew Hunt        | 44.00  | 10    | 1999           |
-- | 2   | Clean Code                   | Robert C. Martin   | 35.00  | 5     | 2008           |
-- | 3   | You Don't Know JS            | Kyle Simpson       | 30.00  | 8     | 2014           |
-- | 4   | Refactoring                  | Martin Fowler      | 55.00  | 3     | 1999           |
-- | 5   | Database Design Principles   | Jane Smith         | 20.00  | 0     | 2018           |

UPDATE books
SET
    price = ROUND(price * 1.10, 2)
WHERE
    published_year < 2000;


    

-- 8️⃣ Delete customers who haven't placed any orders.

-- Sample Output: (No table output, but affected rows will be removed accordingly.)

-- | id  | name    | email              | joined_date  |
-- | --- | ------- | ------------------ | ------------ |
-- | 1   | Alice   | alice@email.com    | 2023-01-10   |
-- | 2   | Bob     | bob@email.com      | 2022-05-15   |

DELETE FROM customers
WHERE
    id NOT IN (
        SELECT customer_id
        FROM orders
    );


