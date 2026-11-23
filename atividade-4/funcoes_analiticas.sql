-- =========================================
-- ATIVIDADE 04 - FUNCOES ANALITICAS
-- =========================================

-- EXERCICIO 1: JORNADA DE COMPRAS DO CLIENTE
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
WHERE v.status = 'FECHADA'
ORDER BY c.nome, v.dt_venda;

-- EXERCICIO 2: RANKING MENSAL DE VENDEDORES
WITH faturamento_mensal AS (
    SELECT
        TRUNC(v.dt_venda, 'MM') AS mes,
        ven.id_vendedor,
        ven.nome AS vendedor,
        SUM(v.valor_liquido) AS total_vendido
    FROM tb_venda v
    JOIN tb_vendedor ven
        ON v.id_vendedor = ven.id_vendedor
    WHERE v.status = 'FECHADA'
    GROUP BY
        TRUNC(v.dt_venda, 'MM'),
        ven.id_vendedor,
        ven.nome
)
SELECT
    mes,
    vendedor,
    total_vendido,
    DENSE_RANK() OVER (
        PARTITION BY mes
        ORDER BY total_vendido DESC
    ) AS posicao_ranking
FROM faturamento_mensal
ORDER BY mes, posicao_ranking;

-- EXERCICIO 3: TOP 2 PRODUTOS POR CATEGORIA
WITH vendas_produtos AS (
    SELECT
        c.id_categoria,
        c.nome AS categoria,
        p.id_produto,
        p.nome AS produto,
        SUM(i.quantidade) AS quantidade_vendida
    FROM tb_categoria c
    JOIN tb_produto p
        ON c.id_categoria = p.id_categoria
    JOIN tb_venda_item i
        ON p.id_produto = i.id_produto
    GROUP BY
        c.id_categoria,
        c.nome,
        p.id_produto,
        p.nome
),
ranking_produtos AS (
    SELECT
        categoria,
        produto,
        quantidade_vendida,
        DENSE_RANK() OVER (
            PARTITION BY id_categoria
            ORDER BY quantidade_vendida DESC
        ) AS posicao_ranking
    FROM vendas_produtos
)
SELECT
    categoria,
    produto,
    quantidade_vendida,
    posicao_ranking
FROM ranking_produtos
WHERE posicao_ranking <= 2
ORDER BY categoria, posicao_ranking;

-- EXERCICIO 4: PARTICIPACAO NO FATURAMENTO
WITH faturamento_vendedor AS (
    SELECT
        ven.id_vendedor,
        ven.nome AS vendedor,
        SUM(v.valor_liquido) AS receita
    FROM tb_vendedor ven
    JOIN tb_venda v
        ON ven.id_vendedor = v.id_vendedor
    WHERE v.status = 'FECHADA'
    GROUP BY
        ven.id_vendedor,
        ven.nome
)
SELECT
    vendedor,
    receita,
    ROUND(
        receita * 100 /
        SUM(receita) OVER (),
        2
    ) AS percentual_faturamento
FROM faturamento_vendedor
ORDER BY receita DESC;

-- EXERCICIO 5: TERMOMETRO DE VENDAS
SELECT
    id_venda,
    valor_liquido,
    ROUND(
        AVG(valor_liquido) OVER (),
        2
    ) AS media_geral,
    ROUND(
        valor_liquido - AVG(valor_liquido) OVER (),
        2
    ) AS diferenca_media
FROM tb_venda
ORDER BY id_venda;
