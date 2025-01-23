-- Criar o banco de dados
CREATE DATABASE Demonstracoes
    WITH 
    ENCODING 'UTF8'
    LC_COLLATE='pt_BR.UTF-8'
    LC_CTYPE='pt_BR.UTF-8'
    TEMPLATE=template0;

	-- Criar a tabela operadoras
CREATE TABLE operadoras (
    registro_ans SERIAL PRIMARY KEY,
    cnpj VARCHAR(20),
    razao_social VARCHAR(250),
    nome_fantasia VARCHAR(250),
    modalidade VARCHAR(100),
    logradouro VARCHAR(250),
    numero VARCHAR(20),
    complemento VARCHAR(155),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf CHAR(2),
    cep VARCHAR(20),
    ddd VARCHAR(5),
    telefone VARCHAR(20),
    fax VARCHAR(20), 
    email VARCHAR(100),
    representante VARCHAR(255),
    cargo_representante VARCHAR(100),
    regiao_de_comercializacao VARCHAR(20),
    data_registro DATE
);


-- Criar tabela temporária Temp_demonstracoes_contabeis
CREATE TEMP TABLE temp_demonstracoes_contabeis (
    data_ DATE,
    reg_ans int,
    cd_conta_contabil VARCHAR(50),
    descricao VARCHAR(250),
    vl_saldo_inicial VARCHAR(20),
    vl_saldo_final VARCHAR(20)
);

-- Criar tabela demonstracoes_contabeis
CREATE TABLE demonstracoes_contabeis (
    id SERIAL PRIMARY KEY,
    data_ DATE,
    reg_ans INT,
    cd_conta_contabil VARCHAR(50),
    descricao VARCHAR(250),
    vl_saldo_inicial NUMERIC,
    vl_saldo_final NUMERIC
);

-- Comando para importar dados do arquivo CSV
COPY operadoras FROM 'C:\Program Files\PostgreSQL\17\DC\Relatorio_cadop.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final) FROM 'C:\Program Files\PostgreSQL\17\DC\1T2023\1T2023.csv'
DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final)
FROM 'C:\Program Files\PostgreSQL\17\DC\1T2024\1T2024.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final)
FROM 'C:\Program Files\PostgreSQL\17\DC\2T2023\2T2023.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final)
FROM 'C:\Program Files\PostgreSQL\17\DC\2T2024\2T2024.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final)
FROM 'C:\Program Files\PostgreSQL\17\DC\3T2023\3T2023.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final)
FROM 'C:\Program Files\PostgreSQL\17\DC\3T2024\3T2024.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final)
FROM 'C:\Program Files\PostgreSQL\17\DC\1T2023\1T2023.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY temp_demonstracoes_contabeis (data_, reg_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final)
FROM 'C:\Program Files\PostgreSQL\17\DC\4T2023\4T2023.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

UPDATE temp_demonstracoes_contabeis
SET VL_SALDO_INICIAL = REPLACE(VL_SALDO_INICIAL::TEXT, ',', '.')::NUMERIC,
    VL_SALDO_FINAL = REPLACE(VL_SALDO_FINAL::TEXT, ',', '.')::NUMERIC;

insert into demonstracoes_contabeis (Data_, REG_ANS, CD_CONTA_CONTABIL, Descricao, VL_SALDO_INICIAL, VL_SALDO_FINAL)
select 
	Data_,
    REG_ANS,
    CD_CONTA_CONTABIL,
    Descricao, 
    cast(VL_SALDO_INICIAL AS NUMERIC), 
    cast(VL_SALDO_FINAL AS NUMERIC)
from Temp_demonstracoes_contabeis;

Alter table demonstracoes_contabeis add column despesas_totais numeric;

update demonstracoes_contabeis set despesas_totais = VL_SALDO_FINAL - VL_SALDO_INICIAL;

-- Selecionar as 10 operadoras com maiores despesas no último trimestre
SELECT op.razao_social, SUM (dc.despesas_totais) 
FROM operadoras op 
INNER JOIN demonstracoes_contabeis dc ON op.registro_ans = dc.reg_ans
WHERE dc.descricao LIKE 'EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSIST%' 
    AND dc.data_ BETWEEN '01-10-2024' AND '30-12-2024' -- Último trimestre
GROUP BY op.razao_social 
ORDER BY SUM (dc.despesas_totais) DESC 
LIMIT 10;

-- Selecionar as 10 operadoras com maiores despesas nessa categoria no último ano
SELECT op.razao_social, SUM (dc.despesas_totais) 
FROM operadoras op 
INNER JOIN demonstracoes_contabeis dc ON op.registro_ans = dc.reg_ans
WHERE dc.descricao LIKE 'EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSIST%' 
    AND dc.data_ BETWEEN '01-01-2024' AND '30-12-2024' -- Último trimestre
GROUP BY op.razao_social
ORDER BY SUM (dc.despesas_totais) DESC
LIMIT 10;




