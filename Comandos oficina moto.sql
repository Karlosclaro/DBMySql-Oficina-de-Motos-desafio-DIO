-- Resumo completo
SELECT 'CLIENTES' as Tabela, COUNT(*) as Registros FROM clients UNION ALL
SELECT 'MOTOS', COUNT(*) FROM motorcycles UNION ALL
SELECT 'PEÇAS', COUNT(*) FROM parts UNION ALL
SELECT 'OS', COUNT(*) FROM service_order UNION ALL
SELECT 'MECÂNICOS', COUNT(*) FROM mechanics;

-- Motos por cliente
SELECT 
    c.Fname,
    COUNT(m.idMoto) as total_motos
FROM clients c 
LEFT JOIN motorcycles m ON c.idClient = m.idClient
GROUP BY c.idClient, c.Fname;

-- 1. OS por cliente
SELECT 
    CONCAT(c.Fname, ' ', c.Lname) cliente,
    COUNT(s.idOS) total_os,
    AVG(s.totalOrder) ticket_medio
FROM clients c JOIN motorcycles m ON c.idClient = m.idClient
JOIN service_order s ON m.idMoto = s.idMoto
GROUP BY c.idClient ORDER BY total_os DESC;

-- 2. Peças mais usadas
SELECT p.Pname, SUM(ps.quantity) qtd_total, SUM(ps.unitPrice * ps.quantity) faturamento
FROM parts p JOIN parts_service ps ON p.idPart = ps.idPart
GROUP BY p.idPart ORDER BY faturamento DESC;

-- 3. Estoque crítico (abaixo do mínimo)
SELECT p.Pname, p.stock, p.minStock,
CASE WHEN p.stock < p.minStock THEN '🚨 URGENTE' ELSE 'OK' END status
FROM parts p WHERE p.stock > p.minStock;

-- Validar constraints
SELECT 
    idClient,
    CASE 
        WHEN clientType = 'PF' AND CPF IS NOT NULL AND CNPJ IS NULL THEN '✅ PF OK'
        WHEN clientType = 'PJ' AND CNPJ IS NOT NULL AND CPF IS NULL THEN '✅ PJ OK'
        ELSE '❌ ERRO'
    END as validacao,
    Fname, Lname, CPF, CNPJ, clientType
FROM clients 
ORDER BY clientType, idClient;

-- Contagem por tipo
SELECT clientType, COUNT(*) as total FROM clients GROUP BY clientType;

-- 1. Clientes OK?
SELECT COUNT(*) as clientes FROM clients;

-- 2. Motos OK? (deve ter 5)
SELECT COUNT(*) as motos FROM motorcycles;
SELECT idMoto FROM motorcycles;

-- 3. OS OK? (deve ter 3)
SELECT COUNT(*) as ordens_servico FROM service_order;
SELECT idOS, idMoto FROM service_order;

-- 4. Tudo conectado?
SELECT 
    s.idOS,
    m.plate as Placa,
    c.Fname as Nome,
    s.osStatus as Situação,
    s.totalOrder as Valor_total
FROM service_order s
JOIN motorcycles m ON s.idMoto = m.idMoto
JOIN clients c ON m.idClient = c.idClient;

-- FATURAMENTO por PERÍODO / MECÂNICO / STATUS
SELECT 
    mec.SocialName as mecanico,
    s.osStatus,
    COUNT(*) as total_os,
    AVG(s.totalOrder) as ticket_medio,
    SUM(s.totalOrder) as faturamento,
    DATE_FORMAT(s.entryDate, '%Y-%m') as mes_ano
FROM service_order s
JOIN mechanics mec ON s.idMechanic = mec.idMechanic
WHERE s.entryDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY mec.idMechanic, s.osStatus, DATE_FORMAT(s.entryDate, '%Y-%m')
HAVING total_os > 0
ORDER BY faturamento DESC;

-- PEÇAS EM ESTOQUE BAIXO (Prioridade Máxima)
SELECT 
    p.Pname AS Peça,
    p.category AS Categoria,
    p.brand AS Marca,
    p.stock AS Qtd,
    p.minStock AS Qtd_min,
    (p.minStock - p.stock) as qtd_repor,
    ROUND((p.precoVenda - p.precoCompra), 2) as margem_unitaria,
    p.stock * p.precoVenda as valor_estoque
FROM parts p
WHERE p.stock >= p.minStock * 1.2  -- 20% acima do mínimo já é alerta
ORDER BY qtd_repor DESC, valor_estoque DESC;

-- TOP CLIENTES por FATURAMENTO / FREQUÊNCIA
SELECT 
    c.idClient,
    CASE 
        WHEN c.clientType = 'PF' THEN CONCAT(c.Fname, ' ', c.Lname)
        ELSE c.Lname
    END as cliente,
    c.clientType,
    COUNT(DISTINCT m.idMoto) as total_motos,
    COUNT(s.idOS) as total_os,
    SUM(s.totalOrder) as faturamento_total,
    AVG(s.totalOrder) as ticket_medio,
    DATE_FORMAT(MAX(s.entryDate), '%Y-%m-%d') as ultima_visita
FROM clients c
LEFT JOIN motorcycles m ON c.idClient = m.idClient
LEFT JOIN service_order s ON m.idMoto = s.idMoto
GROUP BY c.idClient, c.clientType, c.Fname, c.Lname
HAVING faturamento_total > 0
ORDER BY faturamento_total DESC;

-- MECÂNICO mais PRODUTIVO (OS/hora + Faturamento) Sem retorno de dados
SELECT 
    mec.SocialName,
    mec.specialty,
    COUNT(s.idOS) as total_os,
    SUM(s.totalLabor) as mao_obra_faturada,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, s.entryDate, s.exitDate)), 1) as horas_medias,
    ROUND(SUM(s.totalLabor)/COUNT(s.idOS), 2) as valor_hora_medio,
    CASE 
        WHEN COUNT(s.idOS) > 5 THEN '⭐⭐⭐⭐⭐'
        WHEN COUNT(s.idOS) > 3 THEN '⭐⭐⭐⭐'
        ELSE '⭐⭐⭐'
    END as desempenho
FROM mechanics mec
LEFT JOIN service_order s ON mec.idMechanic = s.idMechanic
WHERE s.exitDate IS NOT NULL
GROUP BY mec.idMechanic, mec.SocialName, mec.specialty
ORDER BY mao_obra_faturada DESC;

-- 1. Peças disponíveis
SELECT idPart, Pname AS Peças FROM parts ORDER BY idPart;

-- 2. Mecânicos disponíveis  
SELECT idMechanic AS Id_do_Mecanico, SocialName AS Razão_Social FROM mechanics ORDER BY idMechanic;

-- 3. Motos disponíveis
SELECT idMoto, plate AS Placa FROM motorcycles ORDER BY idMoto;


-- PEÇAS MAIS LUCRATIVAS por CATEGORIA (CORRIGIDA)
SELECT 
    p.category,
    COUNT(ps.idPart) as total_itens,
    SUM(ps.quantity) as qtd_total_vendida,
    SUM(ps.quantity * ps.unitPrice) as faturamento,
    SUM(ps.quantity * (ps.unitPrice - p.precoCompra)) as lucro_bruto,
    ROUND(((SUM(ps.quantity * (ps.unitPrice - p.precoCompra)) / NULLIF(SUM(ps.quantity * ps.unitPrice), 0)) * 100), 1) as margem_percent
FROM parts p
JOIN parts_service ps ON p.idPart = ps.idPart
GROUP BY p.category
ORDER BY lucro_bruto DESC;

-- FROTA por MODELO (O que o cliente tem?)
SELECT 
    m.brand,
    m.model,
    m.engine,
    COUNT(*) as total_unidades,
    AVG(m.mileage) as km_medio,
    GROUP_CONCAT(DISTINCT m.plate SEPARATOR ' | ') as placas
FROM motorcycles m
GROUP BY m.brand, m.model, m.engine
HAVING total_unidades >= 1
ORDER BY total_unidades DESC;

-- OS ATRASADAS (Prioridade Operacional)
SELECT 
    s.idOS,
    m.plate,
    CONCAT(c.Fname, ' ', c.Lname) cliente,
    s.description,
    DATEDIFF(CURDATE(), s.entryDate) as dias_atraso,
    s.totalOrder
FROM service_order s
JOIN motorcycles m ON s.idMoto = m.idMoto
JOIN clients c ON m.idClient = c.idClient
WHERE s.osStatus != 'Concluida' 
  AND (s.exitDate IS NULL OR s.exitDate > CURDATE())
  AND DATEDIFF(CURDATE(), s.entryDate) < 3
ORDER BY dias_atraso DESC;

-- FATURAMENTO MENSAL (Histórico 12 meses)
SELECT 
    DATE_FORMAT(s.entryDate, '%Y-%m') as periodo,
    COUNT(*) as total_os,
    SUM(s.totalParts) as vendas_pecas,
    SUM(s.totalLabor) as mao_obra,
    SUM(s.totalOrder) as faturamento_total,
    COUNT(p.idPayment) as pagamentos_recebidos
FROM service_order s
LEFT JOIN payments p ON s.idOS = p.idOS AND p.paid = TRUE
WHERE s.entryDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(s.entryDate, '%Y-%m')
ORDER BY periodo DESC;

-- 3 MAIS IMPORTANTES
SELECT COUNT(*) total_os FROM service_order WHERE osStatus = 'Concluida';
SELECT * FROM parts WHERE stock < minStock ORDER BY stock;



