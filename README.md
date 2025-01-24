# Script SQL para Criação de Banco de Dados e Análise de Despesas

Este script SQL é responsável pela criação de um banco de dados, tabelas para armazenar informações sobre operadoras de saúde e demonstrações contábeis, importação de dados de arquivos CSV e a execução de consultas analíticas sobre as despesas das operadoras.

## Descrição

O script realiza as seguintes operações:

1. Criação de um banco de dados chamado **Demonstracoes**.
2. Criação das tabelas:
   - **operadoras**: Armazena dados das operadoras de saúde.
   - **temp_demonstracoes_contabeis**: Tabela temporária para armazenar dados das demonstrações contábeis.
   - **demonstracoes_contabeis**: Tabela final que armazena as demonstrações contábeis processadas.
3. Importação dos dados das operadoras e das demonstrações contábeis a partir de arquivos CSV.
4. Conversão dos valores monetários das demonstrações contábeis para formato numérico.
5. Inserção dos dados processados na tabela **demonstracoes_contabeis**.
6. Cálculo das despesas totais para cada registro de demonstração contábil.
7. Consultas SQL para:
   - Encontrar as 10 operadoras com as maiores despesas no último trimestre.
   - Encontrar as 10 operadoras com as maiores despesas em uma categoria específica no último ano.

## Estrutura do Banco de Dados

### Banco de Dados: **Demonstracoes**

#### Tabela: **operadoras**
Armazena informações sobre as operadoras de saúde.

| Coluna                   | Tipo de Dado    | Descrição                        |
|--------------------------|-----------------|----------------------------------|
| registro_ans             | SERIAL          | Chave primária, registro da ANS  |
| cnpj                     | VARCHAR(20)     | CNPJ da operadora                |
| razao_social             | VARCHAR(250)    | Razão social da operadora        |
| nome_fantasia            | VARCHAR(250)    | Nome fantasia da operadora       |
| modalidade               | VARCHAR(100)    | Modalidade da operadora          |
| logradouro               | VARCHAR(250)    | Logradouro                       |
| numero                   | VARCHAR(20)     | Número do endereço               |
| complemento              | VARCHAR(155)    | Complemento do endereço          |
| bairro                   | VARCHAR(100)    | Bairro                           |
| cidade                   | VARCHAR(100)    | Cidade                           |
| uf                       | CHAR(2)         | Unidade federativa               |
| cep                      | VARCHAR(20)     | CEP                              |
| ddd                      | VARCHAR(5)      | DDD                              |
| telefone                 | VARCHAR(20)     | Telefone                         |
| fax                      | VARCHAR(20)     | Fax                              |
| email                    | VARCHAR(100)    | E-mail                           |
| representante            | VARCHAR(255)    | Nome do representante            |
| cargo_representante      | VARCHAR(100)    | Cargo do representante           |
| regiao_de_comercializacao| VARCHAR(20)     | Região de comercialização        |
| data_registro            | DATE            | Data de registro                 |

#### Tabela: **temp_demonstracoes_contabeis**
Tabela temporária para armazenar as demonstrações contábeis antes do processamento.

| Coluna                | Tipo de Dado    | Descrição                       |
|-----------------------|-----------------|---------------------------------|
| data_                 | DATE            | Data do lançamento              |
| reg_ans               | INT             | Registro da ANS da operadora    |
| cd_conta_contabil     | VARCHAR(50)     | Código da conta contábil        |
| descricao             | VARCHAR(250)    | Descrição da conta              |
| vl_saldo_inicial      | VARCHAR(20)     | Valor do saldo inicial          |
| vl_saldo_final        | VARCHAR(20)     | Valor do saldo final            |

#### Tabela: **demonstracoes_contabeis**
Tabela final que armazena as demonstrações contábeis processadas.

| Coluna                | Tipo de Dado    | Descrição                       |
|-----------------------|-----------------|---------------------------------|
| id                    | SERIAL          | Chave primária                 |
| data_                 | DATE            | Data do lançamento              |
| reg_ans               | INT             | Registro da ANS da operadora    |
| cd_conta_contabil     | VARCHAR(50)     | Código da conta contábil        |
| descricao             | VARCHAR(250)    | Descrição da conta              |
| vl_saldo_inicial      | NUMERIC         | Valor do saldo inicial          |
| vl_saldo_final        | NUMERIC         | Valor do saldo final            |
| despesas_totais       | NUMERIC         | Despesas totais (calculadas)    |

## Como Usar

1. **Criação do Banco de Dados**:
   Execute o comando `CREATE DATABASE` para criar o banco de dados **Demonstracoes**.

2. **Criação das Tabelas**:
   Utilize os comandos `CREATE TABLE` para criar as tabelas **operadoras**, **temp_demonstracoes_contabeis**, e **demonstracoes_contabeis**.

3. **Importação dos Dados**:
   O comando `COPY` é utilizado para importar os dados de arquivos CSV para as tabelas **operadoras** e **temp_demonstracoes_contabeis**.

4. **Conversão dos Dados**:
   Os valores de `vl_saldo_inicial` e `vl_saldo_final` na tabela **temp_demonstracoes_contabeis** são convertidos para o formato numérico após a importação.

5. **Inserção de Dados Processados**:
   Os dados convertidos são inseridos na tabela **demonstracoes_contabeis**.

6. **Cálculo das Despesas Totais**:
   A coluna `despesas_totais` é adicionada à tabela **demonstracoes_contabeis** e calculada como a diferença entre o saldo final e inicial.

7. **Consultas de Análise**:
   As consultas selecionam as 10 operadoras com maiores despesas em um determinado trimestre ou ano, filtrando pela categoria específica de "EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS DE ASSIST".

## Exemplo de Consultas

### 10 operadoras com maiores despesas no último trimestre

```sql
SELECT op.razao_social, SUM(dc.despesas_totais)
FROM operadoras op
INNER JOIN demonstracoes_contabeis dc ON op.registro_ans = dc.reg_ans
WHERE dc.descricao LIKE 'EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSIST%'
    AND dc.data_ BETWEEN '01-10-2024' AND '30-12-2024'
GROUP BY op.razao_social
ORDER BY SUM(dc.despesas_totais) DESC
LIMIT 10;
