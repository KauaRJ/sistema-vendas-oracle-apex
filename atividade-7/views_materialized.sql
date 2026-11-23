CREATE MATERIALIZED VIEW mv_vendas_categoria
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    p.categoria,
    COUNT(*) AS quantidade_vendas,
    SUM(v.valor_total) AS faturamento_total
FROM tb_vendas v
JOIN tb_produtos p
    ON v.id_produto = p.id_produto
GROUP BY p.categoria;

SELECT *
FROM mv_vendas_categoria
ORDER BY faturamento_total DESC;

ALTER MATERIALIZED VIEW mv_vendas_por_produto
REFRESH FAST ON COMMIT;

INSERT INTO tb_vendas (
    id_produto,
    quantidade,
    data_venda,
    valor_total
)
VALUES (
    2,
    2,
    SYSDATE,
    2400.00
);

COMMIT;

SELECT *
FROM mv_vendas_por_produto
WHERE id_produto = 2;

-- Metadados das Materialized Views

SELECT
    owner,
    mview_name,
    refresh_mode,
    refresh_method,
    last_refresh_date
FROM user_mviews;

-- Logs das Materialized Views

SELECT
    master,
    log_table,
    log_trigger
FROM user_mview_logs;
