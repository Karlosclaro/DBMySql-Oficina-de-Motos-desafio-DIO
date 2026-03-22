CREATE DATABASE oficina_motos;
USE oficina_motos;

-- =====================================================
-- TABELAS PRINCIPAIS
-- =====================================================

-- 1. CLIENTES (PF/PJ - Proprietários individuais ou frotas)
CREATE TABLE clients (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    Fname VARCHAR(20),
    Minit VARCHAR(10) NULL,
    Lname VARCHAR(30),
    CPF CHAR(14),
    CNPJ CHAR(18),
    Address VARCHAR(100),
    Phone VARCHAR(15),
    clientType ENUM('PF', 'PJ') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_client_type CHECK (
        (clientType = 'PF' AND CPF IS NOT NULL AND CNPJ IS NULL) OR
        (clientType = 'PJ' AND CNPJ IS NOT NULL AND CPF IS NULL)
    ),
    CONSTRAINT unique_cpf_client UNIQUE (CPF),
    CONSTRAINT unique_cnpj_client UNIQUE (CNPJ)
);

-- 2. MOTOS (dos clientes)
CREATE TABLE motorcycles (
    idMoto INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT NOT NULL,
    model VARCHAR(50) NOT NULL,
    brand VARCHAR(30) NOT NULL,
    year INT CHECK (year BETWEEN 1990 AND 2026),
    plate VARCHAR(8) NOT NULL, -- Placa do veículo
    mileage DECIMAL(10,2),     -- KM atual
    engine VARCHAR(20),        -- CC (125, 150, 160, etc)
    color VARCHAR(20),
    
    CONSTRAINT fk_moto_client FOREIGN KEY (idClient) REFERENCES clients(idClient),
    CONSTRAINT unique_plate UNIQUE (plate)
);

-- 3. PEÇAS (Estoque)
CREATE TABLE parts (
    idPart INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    category ENUM('Motor', 'Elétrica', 'Freios', 'Suspensão', 'Carburador', 'Pneus', 'Acessórios') NOT NULL,
    brand VARCHAR(30),
    code VARCHAR(20) UNIQUE,
    precoCompra DECIMAL(10,2) NOT NULL,
    precoVenda DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0 CHECK (stock >= 0),
    minStock INT DEFAULT 5
);

-- 5. MECÂNICOS (PF/PJ)
CREATE TABLE mechanics (
    idMechanic INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(100),
    CPF CHAR(14),
    CNPJ CHAR(18),
    specialty VARCHAR(50),
    contact VARCHAR(15) NOT NULL,
    mechanicType ENUM('PF', 'PJ') NOT NULL,
    
    CONSTRAINT chk_mechanic_type CHECK (
        (mechanicType = 'PF' AND CPF IS NOT NULL AND CNPJ IS NULL) OR
        (mechanicType = 'PJ' AND CNPJ IS NOT NULL AND CPF IS NULL)
    )
);

-- 4. ORDEM DE SERVIÇO (OS)
CREATE TABLE service_order (
    idOS INT AUTO_INCREMENT PRIMARY KEY,
    idMoto INT NOT NULL,
    idMechanic INT,
    osStatus ENUM('Aberta', 'Em_andamento', 'Concluida', 'Cancelada') DEFAULT 'Aberta',
    description TEXT,
    entryDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    exitDate DATETIME NULL,
    totalParts DECIMAL(10,2) DEFAULT 0,
    totalLabor DECIMAL(10,2) DEFAULT 0,
    totalOrder DECIMAL(10,2) GENERATED ALWAYS AS (totalParts + totalLabor) STORED,
    
    CONSTRAINT fk_os_moto FOREIGN KEY (idMoto) REFERENCES motorcycles(idMoto),
    CONSTRAINT fk_os_mechanic FOREIGN KEY (idMechanic) REFERENCES mechanics(idMechanic)
);

-- 6. FORNECEDORES (100 registros)
CREATE TABLE supplier (
    idSupplier INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(100) NOT NULL,
    CNPJ CHAR(18) NOT NULL,
    contact VARCHAR(15) NOT NULL,
    CONSTRAINT unique_supplier_cnpj UNIQUE (CNPJ)
);

-- 7. ESTOQUE (Múltiplos armazéns)
CREATE TABLE storage (
    idStorage INT AUTO_INCREMENT PRIMARY KEY,
    storageLocation VARCHAR(100) NOT NULL,
    totalCapacity INT
);

-- =====================================================
-- RELACIONAMENTOS N:N
-- =====================================================

CREATE TABLE parts_service (
    idPart INT,
    idOS INT,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    unitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (idPart, idOS),
    CONSTRAINT fk_parts_service_part FOREIGN KEY (idPart) REFERENCES parts(idPart),
    CONSTRAINT fk_parts_service_os FOREIGN KEY (idOS) REFERENCES service_order(idOS)
);

CREATE TABLE parts_supplier (
    idSupplier INT,
    idPart INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (idSupplier, idPart),
    CONSTRAINT fk_parts_supplier_supplier FOREIGN KEY (idSupplier) REFERENCES supplier(idSupplier),
    CONSTRAINT fk_parts_supplier_part FOREIGN KEY (idPart) REFERENCES parts(idPart)
);

CREATE TABLE parts_storage (
    idPart INT,
    idStorage INT,
    quantity INT DEFAULT 0,
    PRIMARY KEY (idPart, idStorage),
    CONSTRAINT fk_parts_storage_part FOREIGN KEY (idPart) REFERENCES parts(idPart),
    CONSTRAINT fk_parts_storage_storage FOREIGN KEY (idStorage) REFERENCES storage(idStorage)
);

-- =====================================================
-- PAGAMENTOS
-- =====================================================
CREATE TABLE payments (
    idPayment INT AUTO_INCREMENT PRIMARY KEY,
    idOS INT NOT NULL,
    paymentMethod ENUM('Pix', 'Cartao', 'Boleto', 'Dinheiro') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    parcels INT DEFAULT 1,
    paid BOOLEAN DEFAULT FALSE,
    paymentDate DATETIME,
    
    CONSTRAINT fk_payment_os FOREIGN KEY (idOS) REFERENCES service_order(idOS)
);