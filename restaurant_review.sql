-- =====================================
-- File: restaurant_reviews_full.sql
-- Deskripsi: SQL script lengkap untuk tugas "Managing SQL Data"
-- Bisa dijalankan di Codespace / psql / pgAdmin
-- =====================================

-- =====================================
-- A. DATABASE SETUP
-- =====================================

-- 1. Membuat database (jalankan hanya sekali)
-- Jika sudah ada, bisa di-skip
CREATE DATABASE restaurant_reviews;

-- 2. Connect ke database (jalankan di psql atau Codespace terminal)
-- \c restaurant_reviews;

-- 3. Membuat tabel restaurant
CREATE TABLE IF NOT EXISTS restaurant (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    street_address VARCHAR(200),
    description TEXT
);

-- 4. Membuat tabel review
CREATE TABLE IF NOT EXISTS review (
    id SERIAL PRIMARY KEY,
    restaurant_id INT REFERENCES restaurant(id) ON DELETE CASCADE,
    user_name VARCHAR(100),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date DATE
);

-- =====================================
-- B. INSERTING DATA
-- =====================================

-- 1. Insert minimal 3 restoran
INSERT INTO restaurant (name, street_address, description)
VALUES
('Cafe Aroma', 'Jl. Melati 12', 'Cafe cozy dengan kopi spesial'),
('Warung Makan Sedap', 'Jl. Kenanga 5', 'Makanan tradisional enak'),
('Pizza Palace', 'Jl. Mawar 8', 'Pizza Italia asli');

-- 2. Insert minimal 5 review
INSERT INTO review (restaurant_id, user_name, rating, review_text, review_date)
VALUES
(1, 'Alice', 5, 'Kopi terbaik!', '2025-12-01'),
(1, 'Bob', 4, 'Tempat nyaman', '2025-12-02'),
(2, 'Charlie', 3, 'Makanan biasa saja', '2025-12-03'),
(2, 'Diana', 5, 'Enak banget!', '2025-12-04'),
(3, 'Evan', 4, 'Pizza lezat', '2025-12-05');

-- =====================================
-- C. CRUD OPERATIONS
-- =====================================

-- 1. CREATE (Insert)
-- Tambah restoran baru
INSERT INTO restaurant (name, street_address, description)
VALUES ('Sushi House', 'Jl. Anggrek 10', 'Sushi segar setiap hari');

-- Tambah review baru
INSERT INTO review (restaurant_id, user_name, rating, review_text, review_date)
VALUES (4, 'Fiona', 5, 'Sushi luar biasa!', '2025-12-27');

-- 2. READ (Select)
-- Semua review untuk restoran tertentu
SELECT * FROM review WHERE restaurant_id = 1;

-- Review dengan rating >= 4
SELECT * FROM review WHERE rating >= 4;

-- Join restoran dengan review
SELECT r.name AS restaurant_name, rv.user_name, rv.rating, rv.review_text
FROM restaurant r
JOIN review rv ON r.id = rv.restaurant_id;

-- 3. UPDATE
-- Update deskripsi restoran
UPDATE restaurant
SET description = 'Cafe nyaman dan kopi spesial'
WHERE id = 1;

-- Update rating review tertentu
UPDATE review
SET rating = 5
WHERE id = 3;

-- 4. DELETE
-- Hapus satu review
DELETE FROM review WHERE id = 5;

-- Hapus restoran beserta review (cascade)
DELETE FROM restaurant WHERE id = 2;

-- =====================================
-- D. ADDITIONAL QUERIES
-- =====================================

-- 1. Restoran dengan rating rata-rata tertinggi
SELECT r.name, AVG(rv.rating) AS avg_rating
FROM restaurant r
JOIN review rv ON r.id = rv.restaurant_id
GROUP BY r.name
ORDER BY avg_rating DESC
LIMIT 1;

-- 2. Jumlah review per restoran
SELECT r.name, COUNT(rv.id) AS total_reviews
FROM restaurant r
LEFT JOIN review rv ON r.id = rv.restaurant_id
GROUP BY r.name;

-- 3. Review terbaru per restoran
SELECT r.name, rv.user_name, rv.review_date, rv.review_text
FROM restaurant r
JOIN review rv ON r.id = rv.restaurant_id
WHERE rv.review_date = (
    SELECT MAX(review_date)
    FROM review
    WHERE restaurant_id = r.id
);

-- =====================================
-- EXTRA CREDIT: MENU TABLE
-- =====================================

-- 1. Buat tabel menu
CREATE TABLE IF NOT EXISTS menu (
    id SERIAL PRIMARY KEY,
    restaurant_id INT REFERENCES restaurant(id) ON DELETE CASCADE,
    item_name VARCHAR(100),
    price NUMERIC(10,2)
);

-- 2. Insert 3 menu item per restoran
INSERT INTO menu (restaurant_id, item_name, price)
VALUES
(1, 'Espresso', 20000),
(1, 'Cappuccino', 25000),
(1, 'Latte', 27000),
(3, 'Margherita Pizza', 80000),
(3, 'Pepperoni Pizza', 90000),
(3, 'Four Cheese Pizza', 95000),
(4, 'Salmon Sushi', 50000),
(4, 'Tuna Sushi', 48000),
(4, 'Avocado Roll', 40000);

-- 3. Query: Tampilkan restoran dengan menu dan rata-rata rating
SELECT r.name AS restaurant_name, m.item_name, AVG(rv.rating) AS avg_rating
FROM restaurant r
JOIN menu m ON r.id = m.restaurant_id
LEFT JOIN review rv ON r.id = rv.restaurant_id
GROUP BY r.name, m.item_name
ORDER BY r.name, m.item_name;
