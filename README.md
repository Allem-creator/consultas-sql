# Consultas SQL | Análise de Finanças, Eventos e Vendas

Consultas em PostgreSQL (Neon) sobre dados fictícios, criadas para praticar análise de dados com `JOIN`, `CTE`, `CASE`, `HAVING` e funções de janela (`LAG`, `RANK`, `SUM OVER`).

## Estrutura

- `01_criar_tabelas.sql`: criação das tabelas
- `02_inserir_dados.sql`: dados de exemplo
- `03_consultas.sql`: as 10 consultas de análise
- `imagens/`: prints dos resultados

## Tabelas

| Tabela | Descrição |
|---|---|
| `gastos` | Despesas com categoria, valor, vencimento e status (pago/pendente) |
| `eventos` | Eventos com cliente, tipo, valor combinado e valor pago |
| `produtos` | Catálogo de produtos com categoria, preço e estoque |
| `vendas` | Vendas ligadas aos produtos |


## Consultas

### Q1. Quanto gastei por categoria?
Agrupa os gastos por categoria, com quantidade, total e média.

```sql
SELECT categoria,
       COUNT(*) AS qtd,
       SUM(valor) AS total,
       ROUND(AVG(valor), 2) AS media
FROM gastos
GROUP BY categoria
ORDER BY total DESC;
```

Resultado Q1 <img width="1066" height="719" alt="image" src="https://github.com/user-attachments/assets/b638aa91-2e3e-40ed-92c4-feb75fea17f8" />

### Q2. Gastos pagos x pendentes por mês
Usa FILTER para separar o que já foi pago do que ainda está pendente em cada mês.

```sql
SELECT to_char(data_vencimento, 'YYYY-MM') AS mes,
       COALESCE(SUM(valor) FILTER (WHERE status = 'pago'), 0) AS pago,
       COALESCE(SUM(valor) FILTER (WHERE status = 'pendente'), 0) AS pendente
FROM gastos
GROUP BY 1
ORDER BY 1;
```

Resultado Q2 <img width="1074" height="683" alt="image" src="https://github.com/user-attachments/assets/a75ded4a-a433-43b9-b396-51c1567940e6" />


### Q3. As 5 maiores despesas
Lista as cinco maiores despesas registradas.

```sql
SELECT descricao, categoria, valor
FROM gastos
ORDER BY valor DESC
LIMIT 5;
```

Resultado Q3 <img width="1070" height="736" alt="image" src="https://github.com/user-attachments/assets/5b5681c9-8758-415d-b53f-5f6dc7787a9e" />


### Q4. Gasto acumulado ao longo do tempo
Usa função de janela (SUM OVER) para calcular o total corrente.

```sql
SELECT data_vencimento,
       descricao,
       valor,
       SUM(valor) OVER (ORDER BY data_vencimento, id) AS acumulado
FROM gastos;
```

Resultado Q4 <img width="1064" height="877" alt="image" src="https://github.com/user-attachments/assets/b6c6e8ad-b27b-42a2-815b-4370e21e6bdb" />


### Q5. Quanto ainda tenho a receber por evento?
Mostra os eventos com pagamento incompleto e o saldo a receber.

```sql
SELECT cliente,
       tipo,
       valor,
       valor_pago,
       valor - valor_pago AS saldo_a_receber
FROM eventos
WHERE valor_pago < valor
ORDER BY saldo_a_receber DESC;
```

Resultado Q5 <img width="1070" height="861" alt="image" src="https://github.com/user-attachments/assets/3549bbd4-2c9e-45fd-ae75-6ad25fe036a1" />


### Q6. Receita mensal e variação em relação ao mês anterior
Usa CTE e LAG para calcular a variação percentual mês a mês.

```sql
WITH mensal AS (
  SELECT date_trunc('month', data_evento)::date AS mes,
         SUM(valor) AS receita
  FROM eventos
  GROUP BY 1
)
SELECT mes,
       receita,
       LAG(receita) OVER (ORDER BY mes) AS receita_anterior,
       ROUND(
         (receita - LAG(receita) OVER (ORDER BY mes)) * 100.0
         / NULLIF(LAG(receita) OVER (ORDER BY mes), 0), 1
       ) AS variacao_pct
FROM mensal
ORDER BY mes;
```

Resultado Q6 <img width="1068" height="893" alt="image" src="https://github.com/user-attachments/assets/c13db9a6-1f58-4ab7-a631-c74f6c4f0f1b" />


### Q7. Resultado mensal: receita recebida x despesas
Combina duas CTEs com FULL JOIN para chegar ao saldo de cada mês.

```sql
WITH r AS (
  SELECT date_trunc('month', data_evento)::date AS mes,
         SUM(valor_pago) AS receita
  FROM eventos GROUP BY 1
),
d AS (
  SELECT date_trunc('month', data_vencimento)::date AS mes,
         SUM(valor) AS despesa
  FROM gastos GROUP BY 1
)
SELECT COALESCE(r.mes, d.mes) AS mes,
       COALESCE(receita, 0) AS receita,
       COALESCE(despesa, 0) AS despesa,
       COALESCE(receita, 0) - COALESCE(despesa, 0) AS saldo
FROM r
FULL JOIN d ON r.mes = d.mes
ORDER BY mes;
```

Resultado Q7 <img width="1062" height="938" alt="image" src="https://github.com/user-attachments/assets/d4569100-d02e-408c-a18f-120fba4cbc8d" />


### Q8. Ranking de produtos mais vendidos
Usa JOIN e RANK para ordenar os produtos por unidades vendidas.

```sql
SELECT p.nome,
       SUM(v.quantidade) AS unidades,
       SUM(v.valor_total) AS receita,
       RANK() OVER (ORDER BY SUM(v.quantidade) DESC) AS ranking
FROM vendas v
JOIN produtos p ON p.id = v.produto_id
GROUP BY p.nome
ORDER BY ranking;
```

Resultado Q8 <img width="1061" height="806" alt="image" src="https://github.com/user-attachments/assets/8a1a0017-bbe0-4a38-a671-5a79b614f083" />


### Q9. Participação de cada categoria na receita (%)
Calcula o percentual de cada categoria sobre o total usando SUM OVER.

```sql
SELECT p.categoria,
       SUM(v.valor_total) AS receita,
       ROUND(SUM(v.valor_total) * 100.0 / SUM(SUM(v.valor_total)) OVER (), 1) AS pct_do_total
FROM vendas v
JOIN produtos p ON p.id = v.produto_id
GROUP BY p.categoria
ORDER BY receita DESC;
```

Resultado Q9 <img width="1063" height="756" alt="image" src="https://github.com/user-attachments/assets/4cb2d701-67b7-4ef3-a283-caf3ac225a1b" />


### Q10. Produtos parados (sem vendas) ou com estoque baixo
Usa LEFT JOIN, CASE e HAVING para achar produtos sem giro ou com estoque até 5 unidades.

```sql
SELECT p.nome,
       p.estoque,
       CASE WHEN COUNT(v.id) = 0 THEN 'sem vendas' ELSE 'com vendas' END AS situacao
FROM produtos p
LEFT JOIN vendas v ON v.produto_id = p.id
GROUP BY p.id, p.nome, p.estoque
HAVING COUNT(v.id) = 0 OR p.estoque <= 5
ORDER BY p.estoque;
```

Resultado Q10 <img width="1067" height="700" alt="image" src="https://github.com/user-attachments/assets/0ddb9097-5f86-4ea6-a9c6-bbd651c0752e" />


## Tecnologias

PostgreSQL
