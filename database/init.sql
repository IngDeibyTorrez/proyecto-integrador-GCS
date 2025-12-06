-- =============================================
-- SCRIPT SQL ACTIVIDAD FINAL
-- BASE DE DATOS: deliverydb_bo
-- Sistema de Delivery Universitario
-- =============================================

-- 1. CONFIGURACIÓN INICIAL Y CONEXIÓN
-- ADVERTENCIA: Este comando eliminará la base de datos si existe.
--DROP DATABASE IF EXISTS deliverydb_bo;
--CREATE DATABASE deliverydb_bo;

-- Comentar esta línea si usas PgAdmin Query Tool, pero es necesaria en psql.
-- \c deliverydb_bo

-- =============================================
-- CREACIÓN DE 20 TABLAS
-- =============================================

-- 1. Ciudades y zonas de cobertura
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    active BOOLEAN DEFAULT true
);

CREATE TABLE zones (
    id SERIAL PRIMARY KEY,
    city_id INT REFERENCES cities(id),
    name VARCHAR(100) NOT NULL,
    delivery_fee DECIMAL(8,2) DEFAULT 8.00 -- Costo de envío en Bs.
);

-- 2. Usuarios y roles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL  -- ADMIN, CUSTOMER, RESTAURANT_OWNER, DRIVER
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT REFERENCES roles(id),
    full_name VARCHAR(200),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- 3. Clientes
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(id),
    default_address TEXT,
    zone_id INT REFERENCES zones(id)
);

-- 4. Restaurantes y horarios
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY,
    owner_user_id INT REFERENCES users(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    address TEXT,
    zone_id INT REFERENCES zones(id),
    phone VARCHAR(20),
    logo_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0,
    is_open BOOLEAN DEFAULT true,
    min_order_amount DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE restaurant_schedules (
    id SERIAL PRIMARY KEY,
    restaurant_id INT REFERENCES restaurants(id),
    day_of_week INT CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Domingo
    open_time TIME,
    close_time TIME
);

-- 5. Categorías y menús
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    restaurant_id INT REFERENCES restaurants(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    position INT DEFAULT 0
);

CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    calories INT
);

-- 6. Carrito de compras (sesión temporal)
CREATE TABLE cart (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    restaurant_id INT REFERENCES restaurants(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INT REFERENCES cart(id) ON DELETE CASCADE,
    menu_item_id INT REFERENCES menu_items(id),
    quantity INT NOT NULL DEFAULT 1,
    special_instructions TEXT
);

-- 7. Pedidos y estados
CREATE TABLE order_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL  -- PENDING, CONFIRMED, PREPARING, OUT_FOR_DELIVERY, DELIVERED, CANCELLED
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    restaurant_id INT REFERENCES restaurants(id),
    driver_id INT REFERENCES users(id),  -- repartidor (referencia a users, no a drivers)
    status_id INT REFERENCES order_status(id) DEFAULT 1,
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(8,2) DEFAULT 8.00, -- Bs.
    platform_fee DECIMAL(8,2) DEFAULT 2.00, -- Bs.
    discount_amount DECIMAL(8,2) DEFAULT 0,
    final_amount DECIMAL(10,2) NOT NULL,
    delivery_address TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_name VARCHAR(200) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- 8. Repartidores y disponibilidad
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(id),
    vehicle_type VARCHAR(50),  -- moto, bici, carro
    license_plate VARCHAR(20),
    is_available BOOLEAN DEFAULT true,
    current_zone_id INT REFERENCES zones(id)
);

-- 9. Pagos
CREATE TABLE payment_methods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL  -- EFECTIVO, TARJETA, Tigo Money, Transferencia Bancaria (QR)
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE REFERENCES orders(id),
    method_id INT REFERENCES payment_methods(id),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',  -- PENDING, COMPLETED, FAILED, REFUNDED
    transaction_id VARCHAR(100),
    paid_at TIMESTAMP
);

-- 10. Envíos y tracking
CREATE TABLE shipments (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE REFERENCES orders(id),
    driver_id INT REFERENCES drivers(id), -- Referencia correcta a la ID serial de la tabla drivers
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    estimated_delivery_time TIMESTAMP
);

-- 11. Calificaciones y reseñas
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE REFERENCES orders(id),
    customer_id INT REFERENCES customers(id),
    restaurant_rating INT CHECK (restaurant_rating BETWEEN 1 AND 5),
    driver_rating INT CHECK (driver_rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 12. Cupones y promociones
CREATE TABLE coupons (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) DEFAULT 'PERCENT',  -- PERCENT o FIXED
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) DEFAULT 0,
    max_uses INT DEFAULT 1,
    used_count INT DEFAULT 0,
    valid_from DATE,
    valid_until DATE,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE coupon_uses (
    id SERIAL PRIMARY KEY,
    coupon_id INT REFERENCES coupons(id),
    order_id INT REFERENCES orders(id),
    used_at TIMESTAMP DEFAULT NOW()
);

-- 13. Notificaciones
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50),  -- ORDER, PROMO, SYSTEM
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 14. Auditoría
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- INSERCIÓN DE DATOS DE PRUEBA (CORREGIDOS y BOLIVIA)
-- Usamos IDs altos en users para evitar conflictos con IDs seriales
-- =============================================

-- Roles
INSERT INTO roles (name) VALUES ('ADMIN'),('CUSTOMER'),('RESTAURANT_OWNER'),('DRIVER');

-- Ciudades de Bolivia
INSERT INTO cities (name) VALUES ('Santa Cruz de la Sierra'),('La Paz'),('Cochabamba');

-- Zonas (Costo de envío en Bs.)
INSERT INTO zones (city_id, name, delivery_fee) VALUES 
(1, 'Zona UAGRM', 8.00), 
(1, 'Equipetrol', 10.00),
(2, 'Sopocachi/UMSA', 9.00), 
(2, 'Miraflores', 7.00),
(3, 'Zona UMSS', 8.50);

-- Estados de Pedido
INSERT INTO order_status (name) VALUES 
('PENDING'),('CONFIRMED'),('PREPARING'),('OUT_FOR_DELIVERY'),('DELIVERED'),('CANCELLED');

-- Métodos de Pago Adaptados a Bolivia
INSERT INTO payment_methods (name) VALUES ('EFECTIVO'),('TARJETA'),('Tigo Money'),('Transferencia Bancaria (QR)');

-- INSERCIÓN DE USUARIOS (Usando IDs manuales 101+)
INSERT INTO users (id, email, password_hash, role_id, full_name, phone) VALUES 
(101, 'admin@delivery.com', 'pbkdf2_sha256$600000$abc$123...', 1, 'Administrador', '700123456'),
(102, 'sushi@sushi.com', 'pbkdf2_sha256$600000$abc$123...', 3, 'Sushi Master Propietario', '601234567'),
(103, 'estudiante@umss.bo', 'pbkdf2_sha256$600000$def$456...', 2, 'Ana Mamani', '77700111'),
(104, 'driver@delivery.com', 'pbkdf2_sha256$600000$ghi$789...', 4, 'Carlos Choque', '700223344');

-- Restaurante de prueba (ID generado: 1)
INSERT INTO restaurants (owner_user_id, name, description, address, zone_id, phone) 
VALUES (102, 'Sushi Master', 'El mejor sushi de Santa Cruz, cerca de la UAGRM.', 'Calle 24 de Septiembre #100', 1, '33123456');

-- Cliente de prueba (ID generado: 1)
INSERT INTO customers (user_id, default_address, zone_id)
VALUES (103, 'Avenida Oquendo, Edificio Azul, Dpto 3A', 5);

-- Conductor de prueba (ID generado: 1)
INSERT INTO drivers (user_id, vehicle_type, license_plate, is_available, current_zone_id)
VALUES (104, 'moto', '4567-XYZ', true, 1); -- user_id = 104

-- Categorías y productos (IDs generados: 1, 2, 3...)
INSERT INTO categories (restaurant_id, name, position) VALUES 
(1, 'Entradas', 1),(1, 'Rollos Clásicos', 2),(1, 'Bebidas', 3);

INSERT INTO menu_items (category_id, name, price, is_available) VALUES
(1, 'Edamame', 15.00, true), -- ID 1
(2, 'California Roll', 35.00, true), -- ID 2
(2, 'Philadelphia Roll', 40.00, true), -- ID 3
(3, 'Gaseosa 400ml', 8.00, true), -- ID 4
(3, 'Agua 600ml', 6.00, true), -- ID 5
(2, 'Dragon Roll', 55.00, true); -- ID 6

-- Cupón de prueba (ID generado: 1)
INSERT INTO coupons (code, description, discount_value, min_order_amount, valid_until, is_active)
VALUES ('BIENVENIDA20', '20% off primera compra', 20, 50.00, '2026-12-31', true);

-- Una orden de prueba (ID generado: 1)
INSERT INTO orders (customer_id, restaurant_id, driver_id, status_id, total_amount, delivery_fee, platform_fee, discount_amount, final_amount, delivery_address, notes)
VALUES (
    1,              -- customer_id (ID 1 de la tabla customers)
    1,              -- restaurant_id (ID 1 de la tabla restaurants)
    104,            -- driver_id (ID 104 de la tabla users)
    3,              -- status_id: PREPARING
    75.00,          
    8.50,           
    2.00,           
    0.00,           
    85.50,          
    'Avenida Oquendo, Edificio Azul, Dpto 3A',
    'Por favor, sin wasabi.'
);

-- Items de la orden (order_id = 1)
INSERT INTO order_items (order_id, menu_item_name, quantity, unit_price, subtotal) VALUES
(1, 'California Roll', 1, 35.00, 35.00),
(1, 'Philadelphia Roll', 1, 40.00, 40.00);

-- Pago de la orden (order_id = 1)
INSERT INTO payments (order_id, method_id, amount, status, paid_at)
VALUES (1, 1, 85.50, 'COMPLETED', NOW());

-- Envío (order_id = 1)
INSERT INTO shipments (order_id, driver_id, estimated_delivery_time)
VALUES (1, 1, NOW() + INTERVAL '30 minutes'); -- <-- CORRECCIÓN: Usamos driver_id = 1 (ID serial de la tabla drivers)

-- Reiniciar secuencias después de usar IDs manuales para evitar errores
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
