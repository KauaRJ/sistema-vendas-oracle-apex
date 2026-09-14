-- ============================================================
-- ATIVIDADE 3 - SQL AVANÇADO E ANÁLISE COMERCIAL
-- SISTEMA DE VENDAS E ANÁLISE COMERCIAL
-- ============================================================


-- ============================================================
-- PARTE 1 - JOIN E GROUP BY
-- ============================================================


-- ============================================================
-- 1. DESEMPENHO DE VENDAS POR VENDEDOR
-- Retorna o nome do vendedor e o valor total vendido.
-- Considera somente vendas com status FECHADA.
-- ============================================================

SELECT
    ven.nome AS vendedor,
    SUM(v.valor_liquido) AS total_vendido
FROM tb_vendedor ven
JOIN tb_venda v
    ON ven.id_vendedor = v.id_vendedor
WHERE v.status = 'FECHADA'
GROUP BY ven.nome
ORDER BY total_vendido DESC;


-- ============================================================
-- 2. HISTÓRICO DE COMPRAS DO CLIENTE
-- Lista clientes, data, valor líquido e status das vendas.
-- Vendas canceladas também aparecem no resultado.
-- ============================================================

SELECT
    c.nome AS cliente,
    v.dt_venda,
    v.valor_liquido,
    v.status
FROM tb_cliente c
JOIN tb_venda v
    ON c.id_cliente = v.id_cliente
ORDER BY c.nome, v.dt_venda;


-- ============================================================
-- 3. O MELHOR CLIENTE
-- Identifica o cliente com maior faturamento acumulado
-- considerando somente vendas FECHADAS.
-- ============================================================

SELECT
    c.nome AS cliente,
    SUM(v.valor_liquido) AS faturamento_total
FROM tb_cliente c
JOIN tb_venda v
    ON c.id_cliente = v.id_cliente
WHERE v.status = 'FECHADA'
GROUP BY c.nome
ORDER BY faturamento_total DESC
FETCH FIRST 1 ROWS ONLY;


-- ============================================================
-- PARTE 2 - SUBQUERIES, EXISTS, IN E CASE WHEN
-- ============================================================


-- ============================================================
-- 4. VENDAS ACIMA DA MÉDIA
-- Lista vendas fechadas cujo valor é maior que a média
-- geral das vendas fechadas.
-- ============================================================

SELECT
    id_venda,
    dt_venda,
    valor_liquido
FROM tb_venda
WHERE status = 'FECHADA'
AND valor_liquido > (
    SELECT AVG(valor_liquido)
    FROM tb_venda
    WHERE status = 'FECHADA'
);


-- ============================================================
-- 5. ESTOQUE ENCALHADO
-- Lista produtos ativos que nunca apareceram em uma venda.
-- Utiliza NOT EXISTS.
-- ============================================================

SELECT
    p.nome
FROM tb_produto p
WHERE p.ativo = 'S'
AND NOT EXISTS (
    SELECT 1
    FROM tb_venda_item i
    WHERE i.id_produto = p.id_produto
);


-- ============================================================
-- 6. CLASSIFICAÇÃO COMERCIAL DE CLIENTES
--
-- Ouro   -> faturamento acima de R$ 10.000
-- Prata  -> faturamento entre R$ 2.000 e R$ 10.000
-- Bronze -> faturamento abaixo de R$ 2.000
-- ============================================================

SELECT
    c.nome,
    SUM(v.valor_liquido) AS faturamento,
    CASE
        WHEN SUM(v.valor_liquido) > 10000 THEN 'Ouro'
        WHEN SUM(v.valor_liquido) >= 2000 THEN 'Prata'
        ELSE 'Bronze'
    END AS categoria_cliente
FROM tb_cliente c
JOIN tb_venda v
    ON c.id_cliente = v.id_cliente
WHERE v.status = 'FECHADA'
GROUP BY c.nome;


-- ============================================================
-- PARTE 3 - CTE / WITH
-- ============================================================


-- ============================================================
-- 7. RECEITA MENSAL DA EMPRESA
-- Cria uma CTE chamada receita_mensal.
-- Calcula o faturamento das vendas fechadas por mês.
-- ============================================================

WITH receita_mensal AS (
    SELECT
        TRUNC(dt_venda, 'MM') AS mes_ref,
        SUM(valor_liquido) AS receita
    FROM tb_venda
    WHERE status = 'FECHADA'
    GROUP BY TRUNC(dt_venda, 'MM')
)
SELECT
    mes_ref,
    receita
FROM receita_mensal
ORDER BY mes_ref;


-- ============================================================
-- 8. TOP 5 PRODUTOS MAIS VENDIDOS
-- Soma a quantidade vendida de cada produto
-- e apresenta somente os cinco primeiros.
-- ============================================================

WITH qtd_produto AS (
    SELECT
        p.nome AS produto,
        SUM(i.quantidade) AS total_vendido
    FROM tb_produto p
    JOIN tb_venda_item i
        ON p.id_produto = i.id_produto
    GROUP BY p.nome
)
SELECT
    produto,
    total_vendido
FROM qtd_produto
ORDER BY total_vendido DESC
FETCH FIRST 5 ROWS ONLY;



-- ============================================================
-- ============================================================
-- EXERCÍCIOS PRÁTICOS
-- NÍVEL SIMPLES
-- ============================================================
-- ============================================================


-- ============================================================
-- 1. LISTAGEM DE CLIENTES ATIVOS
-- ============================================================

SELECT
    nome,
    email,
    telefone
FROM tb_cliente
WHERE ativo = 'S'
ORDER BY nome;


-- ============================================================
-- 2. FILTRO DE VENDAS POR CANAL
-- Canal APP e status FECHADA.
-- ============================================================

SELECT
    id_venda,
    dt_venda,
    valor_liquido
FROM tb_venda
WHERE canal = 'APP'
AND status = 'FECHADA';


-- ============================================================
-- 3. CATÁLOGO DE PRODUTOS E CATEGORIAS
-- ============================================================

SELECT
    p.nome AS produto,
    p.sku,
    c.nome AS categoria
FROM tb_produto p
JOIN tb_categoria c
    ON p.id_categoria = c.id_categoria
ORDER BY p.nome;


-- ============================================================
-- 4. CONTAGEM DE VENDEDORES
-- ============================================================

SELECT
    COUNT(*) AS total_vendedores
FROM tb_vendedor;


-- ============================================================
-- 5. PRODUTOS MAIS CAROS
-- Somente produtos ativos.
-- ============================================================

SELECT
    nome,
    preco_unit
FROM tb_produto
WHERE ativo = 'S'
ORDER BY preco_unit DESC;



-- ============================================================
-- ============================================================
-- NÍVEL INTERMEDIÁRIO
-- ============================================================
-- ============================================================


-- ============================================================
-- 6. FATURAMENTO POR CANAL DE VENDA
-- Somente vendas FECHADAS.
-- ============================================================

SELECT
    canal,
    SUM(valor_liquido) AS faturamento_total
FROM tb_venda
WHERE status = 'FECHADA'
GROUP BY canal
ORDER BY faturamento_total DESC;


-- ============================================================
-- 7. TICKET MÉDIO POR VENDEDOR
-- Somente vendas FECHADAS.
-- ============================================================

SELECT
    ven.nome AS vendedor,
    ROUND(AVG(v.valor_liquido), 2) AS ticket_medio
FROM tb_vendedor ven
JOIN tb_venda v
    ON ven.id_vendedor = v.id_vendedor
WHERE v.status = 'FECHADA'
GROUP BY ven.nome
ORDER BY ticket_medio DESC;


-- ============================================================
-- 8. CLIENTES INATIVOS COMERCIALMENTE
-- Clientes que nunca realizaram nenhuma compra.
-- Utiliza NOT EXISTS.
-- ============================================================

SELECT
    c.nome,
    c.email
FROM tb_cliente c
WHERE NOT EXISTS (
    SELECT 1
    FROM tb_venda v
    WHERE v.id_cliente = c.id_cliente
);


-- ============================================================
-- 9. VENDAS ACIMA DA MÉDIA
-- Mostra também o nome do cliente.
-- ============================================================

SELECT
    v.id_venda,
    c.nome AS cliente,
    v.valor_liquido
FROM tb_venda v
JOIN tb_cliente c
    ON c.id_cliente = v.id_cliente
WHERE v.status = 'FECHADA'
AND v.valor_liquido > (
    SELECT AVG(valor_liquido)
    FROM tb_venda
    WHERE status = 'FECHADA'
);


-- ============================================================
-- 10. CLASSIFICAÇÃO DE PREÇO DOS PRODUTOS
--
-- BARATO -> menor que R$ 50
-- MÉDIO  -> entre R$ 50 e R$ 200
-- CARO   -> maior que R$ 200
-- ============================================================

SELECT
    nome,
    preco_unit,
    CASE
        WHEN preco_unit < 50 THEN 'BARATO'
        WHEN preco_unit <= 200 THEN 'MÉDIO'
        ELSE 'CARO'
    END AS faixa_preco
FROM tb_produto
ORDER BY preco_unit;



-- ============================================================
-- ============================================================
-- NÍVEL AVANÇADO
-- CTE / WITH E FUNÇÕES ANALÍTICAS
-- ============================================================
-- ============================================================


-- ============================================================
-- 11. NUMERAÇÃO CRONOLÓGICA DE COMPRAS
-- ROW_NUMBER enumera as compras de cada cliente.
-- ============================================================

SELECT
    c.nome AS cliente,
    v.dt_venda,
    v.valor_liquido,
    ROW_NUMBER() OVER (
        PARTITION BY c.id_cliente
        ORDER BY v.dt_venda
    ) AS numero_compra
FROM tb_cliente c
JOIN tb_venda v
    ON c.id_cliente = v.id_cliente
ORDER BY c.nome, numero_compra;


-- ============================================================
-- 12. PARTICIPAÇÃO PERCENTUAL NO FATURAMENTO
-- Calcula quanto cada vendedor representa
-- do faturamento total da empresa.
-- ============================================================

SELECT
    vendedor,
    faturamento,
    ROUND(
        faturamento /
        SUM(faturamento) OVER () * 100,
        2
    ) AS percentual_faturamento
FROM (
    SELECT
        ven.nome AS vendedor,
        SUM(v.valor_liquido) AS faturamento
    FROM tb_vendedor ven
    JOIN tb_venda v
        ON ven.id_vendedor = v.id_vendedor
    WHERE v.status = 'FECHADA'
    GROUP BY ven.nome
)
ORDER BY percentual_faturamento DESC;


-- ============================================================
-- 13. RANKING MENSAL DE VENDEDORES
-- DENSE_RANK reinicia o ranking a cada mês.
-- ============================================================

WITH vendas_mensais AS (
    SELECT
        TRUNC(v.dt_venda, 'MM') AS mes_ref,
        ven.nome AS vendedor,
        SUM(v.valor_liquido) AS receita
    FROM tb_venda v
    JOIN tb_vendedor ven
        ON ven.id_vendedor = v.id_vendedor
    WHERE v.status = 'FECHADA'
    GROUP BY
        TRUNC(v.dt_venda, 'MM'),
        ven.nome
)
SELECT
    mes_ref,
    vendedor,
    receita,
    DENSE_RANK() OVER (
        PARTITION BY mes_ref
        ORDER BY receita DESC
    ) AS ranking_mensal
FROM vendas_mensais
ORDER BY mes_ref, ranking_mensal;


-- ============================================================
-- 14. TERMÔMETRO DE VENDAS
-- Mostra a diferença entre cada venda e a média geral.
-- ============================================================

SELECT
    id_venda,
    valor_liquido,
    valor_liquido -
        AVG(valor_liquido) OVER () AS diferenca_para_media
FROM tb_venda
ORDER BY id_venda;


-- ============================================================
-- 15. OS 3 PRODUTOS MAIS VENDIDOS
-- Soma a quantidade e depois aplica ranking.
-- ============================================================

WITH qtd_produto AS (
    SELECT
        p.id_produto,
        p.nome AS produto,
        SUM(i.quantidade) AS total_vendido
    FROM tb_produto p
    JOIN tb_venda_item i
        ON p.id_produto = i.id_produto
    GROUP BY
        p.id_produto,
        p.nome
),
ranking_produtos AS (
    SELECT
        produto,
        total_vendido,
        DENSE_RANK() OVER (
            ORDER BY total_vendido DESC
        ) AS ranking
    FROM qtd_produto
)
SELECT
    produto,
    total_vendido,
    ranking
FROM ranking_produtos
WHERE ranking <= 3
ORDER BY ranking;
