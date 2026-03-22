USE oficina_motos;

-- =====================================================
-- 1. CLIENTES (IDs: 1,2,3,4,5)
-- =====================================================
INSERT INTO clients (Fname, Minit, Lname, CPF, CNPJ, Address, Phone, clientType) VALUES
('João', 'P', 'Silva', '123.456.789-01', NULL, 'Rua Motas, 123', '(62)99999-1111', 'PF'),
('Maria', 'A', 'Santos', '987.654.321-00', NULL, 'Av. Velocidade, 456', '(62)99999-2222', 'PF'),
('Pedro', NULL, 'Oliveira', '111.222.333-44', NULL, 'Rua das Motos, 789', '(62)99999-3333', 'PF'),
('Ana', 'C', 'Costa', '555.666.777-88', NULL, 'Av. Turbo, 101', '(62)99999-4444', 'PF'),
(NULL, 'MOTO', 'Taxi Frota Ltda', NULL, '12.345.678/0001-99', 'Rua Entrega, 202', '(62)99999-5555', 'PJ');

-- VERIFICAR: SELECT idClient FROM clients; (1,2,3,4,5)

-- =====================================================
-- 2. MOTOS (IDs: 1,2,3,4,5 | idClient: 1,1,2,3,5)
-- =====================================================
INSERT INTO motorcycles (idClient, model, brand, year, plate, mileage, engine, color) VALUES
(1, 'Fan 160', 'Honda', 2023, 'ABC1D23', 15000.00, '160cc', 'Vermelha'),     -- ID 1
(1, 'Twister 250', 'Honda', 2019, 'ABC2E34', 35000.00, '250cc', 'Preta'),    -- ID 2
(2, 'CG 150', 'Honda', 2021, 'DEF3F45', 8000.00, '150cc', 'Azul'),          -- ID 3
(3, 'Pop 110i', 'Honda', 2022, 'GHI4G56', 12000.00, '110cc', 'Branca'),     -- ID 4
(5, 'NXR 160 Bros', 'Honda', 2024, 'JKL5H67', 5000.00, '160cc', 'Prata');    -- ID 5

-- VERIFICAR: SELECT idMoto FROM motorcycles; (1,2,3,4,5)

-- =====================================================
-- 3. PEÇAS (IDs: 1,2,3,4,5)
-- =====================================================
INSERT INTO parts (Pname, category, brand, code, precoCompra, precoVenda, stock, minStock) VALUES
('Filtro de Ar CG', 'Motor', 'Honda', 'FA-CG001', 25.00, 45.00, 50, 10),     -- ID 1
('Correia Dentada Fan', 'Motor', 'Honda', 'CD-FAN001', 80.00, 150.00, 20, 5), -- ID 2
('Pastilhas Freio', 'Freios', 'Honda', 'PF-CG001', 60.00, 120.00, 30, 8),    -- ID 3
('Bateria 12V', 'Elétrica', 'Moura', 'BAT-12V', 250.00, 450.00, 15, 3),      -- ID 4
('Pneu 17x2.15', 'Pneus', 'Pirelli', 'PN-1715', 300.00, 550.00, 12, 4);      -- ID 5

-- 2. MAIS PEÇAS (Total: 15)
-- =====================================================
INSERT INTO parts (Pname, category, brand, code, precoCompra, precoVenda, stock, minStock) VALUES
('Embreagem CG', 'Motor', 'Honda', 'EM-CG001', 180.00, 350.00, 8, 3),
('Amortecedor Traseiro', 'Suspensão', 'Honda', 'AM-TRAS', 220.00, 420.00, 12, 5),
('Pastilhas Traseiras', 'Freios', 'Honda', 'PF-TRAS', 50.00, 95.00, 25, 8),
('Pneu 18x2.50', 'Pneus', 'Metzeler', 'PN-1825', 380.00, 680.00, 6, 3),
('Velas NGK', 'Elétrica', 'NGK', 'VEL-NGK', 35.00, 70.00, 40, 10);

-- VERIFICAR: SELECT idPart FROM parts; (1,2,3,4,5)

-- =====================================================
-- 4. MECÂNICOS (IDs: 1,2)
-- =====================================================
INSERT INTO mechanics (SocialName, CPF, specialty, contact, mechanicType) VALUES
('Carlos Motor', '111.222.333-44', 'Motor/Câmbio', '(62)98888-1111', 'PF'),     -- ID 1
('Ana Elétrica', '555.666.777-88', 'Elétrica/Injeção', '(62)98888-2222', 'PF'); -- ID 2

-- 1. MAIS MECÂNICOS (Total: 5)
-- =====================================================
INSERT INTO mechanics (SocialName, CPF, specialty, contact, mechanicType) VALUES
('Raphael Suspensão', '777.888.999-00', 'Suspensão/Freios', '(62)98888-3333', 'PF'),
('Diego Pneus', '999.111.222-33', 'Pneus/Alinhamento', '(62)98888-4444', 'PF'),
('Fernanda Injeção', '222.333.444-55', 'Injeção/Carburação', '(62)98888-5555', 'PF');

-- =====================================================
-- 5. ORDEM DE SERVIÇO (Moto IDs 1,2,3 | Mecânico IDs 1,2)
-- =====================================================
INSERT INTO service_order (idMoto, idMechanic, osStatus, description, totalParts, totalLabor) VALUES
(1, 1, 'Concluida', 'Troca correia dentada + regulagem válvulas', 150.00, 120.00),  -- Moto 1
(2, 2, 'Em_andamento', 'Revisão elétrica completa + bobina', 450.00, 200.00),       -- Moto 2
(3, 1, 'Aberta', 'Troca pastilhas freio dianteiro + alinhamento', 120.00, 80.00);   -- Moto 3

-- 3. 20 ORDEM DE SERVIÇO (Com exitDate para cálculo de horas)
-- =====================================================
INSERT INTO service_order (idMoto, idMechanic, osStatus, description, totalParts, totalLabor, entryDate, exitDate) VALUES
-- Moto 1 (João - Fan 160)
(1, 1, 'Concluida', 'Troca correia + óleo', 215.00, 150.00, '2026-03-01 09:00:00', '2026-03-01 12:00:00'),
(1, 3, 'Concluida', 'Regulagem carburador', 70.00, 100.00, '2026-03-10 14:00:00', '2026-03-10 16:30:00'),

-- Moto 2 (João - Twister)
(2, 2, 'Concluida', 'Revisão elétrica completa', 520.00, 250.00, '2026-03-05 08:30:00', '2026-03-05 17:00:00'),
(2, 4, 'Concluida', 'Troca pneus + alinhamento', 1360.00, 180.00, '2026-03-15 10:00:00', '2026-03-15 14:00:00'),

-- Moto 3 (Maria - CG 150)
(3, 1, 'Concluida', 'Troca pastilhas + fluido', 215.00, 120.00, '2026-03-08 09:30:00', '2026-03-08 13:00:00'),
(3, 5, 'Concluida', 'Limpeza injeção', 280.00, 140.00, '2026-03-20 15:00:00', '2026-03-20 17:30:00'),

-- Moto 4 (Pedro - Pop)
(4, 3, 'Concluida', 'Troca velas + regulagem', 140.00, 90.00, '2026-03-12 11:00:00', '2026-03-12 13:30:00'),

-- Moto 5 (Moto Taxi - Bros)
(5, 2, 'Concluida', 'Suspensão dianteira', 420.00, 220.00, '2026-03-18 08:00:00', '2026-03-18 16:00:00');

-- VERIFICAR: SELECT idOS FROM service_order; (1,2,3)

-- 6. PEÇAS x ORDEM DE SERVIÇO
-- =====================================================
INSERT INTO parts_service (idPart, idOS, quantity, unitPrice) VALUES
(2, 1, 1, 150.00),  -- Correia (ID2) na OS1
(4, 2, 1, 450.00);  -- Bateria (ID4) na OS2

INSERT INTO parts_service (idPart, idOS, quantity, unitPrice) VALUES
-- Usando peças que existem (1-9) e OS que serão criadas acima
(2, 1, 1, 150.00),  -- Correia OS1 (Moto Fan 160)
(4, 2, 1, 450.00),  -- Bateria OS2 (Twister)
(3, 3, 1, 120.00),  -- Pastilhas OS3 (CG 150)
(5, 4, 2, 680.00),  -- Pneus OS4 (Pop)
(9, 5, 1, 95.00),   -- Pastilhas traseiras OS5 (Fan 160)
(6, 6, 1, 350.00);  -- Embreagem OS6 (Twister)
