-- QUESTAO 1: VIOLACAO DE CHAVE ESTRANGEIRA (FK)
-- Tentativa de registrar uma venda com cliente inexistente.
-- Resultado esperado: ORA-02291.
-- A FK impede vendas sem um cliente previamente cadastrado.

INSERT INTO tb_venda
    (id_cliente, id_vendedor, dt_venda, status, canal)
VALUES
    (9999, 1, SYSDATE, 'ABERTA', 'LOJA');


-- QUESTAO 2: VIOLACAO DE DOMINIO (CHECK)
-- Tentativa de alterar o status para um valor nao permitido.
-- Resultado esperado: ORA-02290.
-- A constraint permite somente ABERTA, FECHADA ou CANCELADA.

UPDATE tb_venda
SET status = 'PENDENTE'
WHERE id_venda = 1;


-- QUESTAO 3: IMPEDINDO PRECOS NEGATIVOS
-- Tentativa de cadastrar produto com preco negativo.
-- Resultado esperado: ORA-02290.
-- A constraint exige que preco_unit seja maior que zero.

INSERT INTO tb_produto
    (id_categoria, sku, nome, preco_unit)
VALUES
    (1, 'SKU-TEMP-01', 'Produto Teste Negativo', -15.00);



-- ---------------------------------------------------------------------
-- PARTE 2: EVOLUINDO A MODELAGEM FISICA (DDL)
-- ---------------------------------------------------------------------


-- QUESTAO 4: LIMITE DE DESCONTO DE ITENS
-- Cria uma constraint CHECK para limitar o desconto a 50% do preco.

ALTER TABLE tb_venda_item
ADD CONSTRAINT ck_tb_item_desconto_max
CHECK (desconto_item <= (preco_unit * 0.50));


-- QUESTAO 5: GARANTIA DE UNICIDADE DE TELEFONE
-- Impede que dois clientes tenham o mesmo telefone cadastrado.
-- Valores NULL continuam permitidos.

ALTER TABLE tb_cliente
ADD CONSTRAINT uq_tb_cliente_telefone
UNIQUE (telefone);



-- ---------------------------------------------------------------------
-- PARTE 3: COMPORTAMENTO DE EXCLUSAO
-- ---------------------------------------------------------------------


-- QUESTAO 6: EXCLUSAO EM CASCATA (ON DELETE CASCADE)
-- A exclusao da venda pai remove automaticamente seus itens filhos.
-- ATENCAO: comando destrutivo. Executar somente em ambiente de testes.

DELETE FROM tb_venda
WHERE id_venda = 1;


-- Consulta para verificar se os itens associados foram removidos.
SELECT *
FROM tb_venda_item
WHERE id_venda = 1;


-- QUESTAO 7: EXCLUSAO LOGICA (SOFT DELETE)
-- Desativa o vendedor sem apagar seu cadastro ou historico de vendas.

UPDATE tb_vendedor
SET ativo = 'N'
WHERE id_vendedor = 1;


-- Consulta para verificar a desativacao do vendedor.
SELECT
    id_vendedor,
    nome,
    ativo
FROM tb_vendedor
WHERE id_vendedor = 1;
