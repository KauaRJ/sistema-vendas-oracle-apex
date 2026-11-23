-- QUESTAO 1: VIEW DE RESUMO DE VENDAS
-- Nome: V_VENDAS_RESUMO
-- Centraliza os dados de vendas, clientes e vendedores.
-- ============================================================

CREATE OR REPLACE VIEW V_VENDAS_RESUMO AS
SELECT
v.id_venda,
v.dt_venda,
v.status,
v.canal,
c.nome AS nome_cliente,
ven.nome AS nome_vendedor,
v.valor_liquido
FROM tb_venda v
JOIN tb_cliente c
ON v.id_cliente = c.id_cliente
JOIN tb_vendedor ven
ON v.id_vendedor = ven.id_vendedor;

-- Consulta para verificar a View:

SELECT *
FROM V_VENDAS_RESUMO
ORDER BY dt_venda;

-- ============================================================
-- QUESTAO 2: VIEW DE CLIENTE PUBLICO
-- Nome: V_CLIENTE_PUBLICO
-- Oculta dados pessoais e apresenta apenas clientes ativos.
-- ============================================================

CREATE OR REPLACE VIEW V_CLIENTE_PUBLICO AS
SELECT
id_cliente,
nome,
dt_cadastro,
ativo
FROM tb_cliente
WHERE ativo = 'S';

-- Consulta para verificar a View:

SELECT *
FROM V_CLIENTE_PUBLICO
ORDER BY nome;

-- ============================================================
-- QUESTAO 3: VIEW DE RECEITA POR CATEGORIA
-- Nome: V_VENDAS_POR_CATEGORIA
-- Agrupa o faturamento mensal por categoria de produto.
-- Considera somente vendas com status FECHADA.
-- ============================================================

CREATE OR REPLACE VIEW V_VENDAS_POR_CATEGORIA AS
SELECT
TRUNC(v.dt_venda, 'MM') AS mes,
c.nome AS categoria,
SUM(i.valor_total) AS faturamento
FROM tb_venda v
JOIN tb_venda_item i
ON v.id_venda = i.id_venda
JOIN tb_produto p
ON i.id_produto = p.id_produto
JOIN tb_categoria c
ON p.id_categoria = c.id_categoria
WHERE v.status = 'FECHADA'
GROUP BY
TRUNC(v.dt_venda, 'MM'),
c.nome;

-- Consulta para verificar a View:

SELECT *
FROM V_VENDAS_POR_CATEGORIA
ORDER BY mes, categoria;

-- ============================================================
-- QUESTAO 4: CONSUMINDO A VIEW ANALITICA
-- Exibe categorias com faturamento superior a R$ 5.000,00
-- no mes corrente.
-- ============================================================

SELECT
categoria,
mes,
faturamento
FROM V_VENDAS_POR_CATEGORIA
WHERE mes = TRUNC(SYSDATE, 'MM')
AND faturamento > 5000
ORDER BY faturamento DESC;

