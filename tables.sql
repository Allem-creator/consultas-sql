CREATE TABLE gastos (
  id SERIAL PRIMARY KEY,
  descricao TEXT,
  categoria TEXT,
  valor NUMERIC(10,2),
  data_vencimento DATE,
  status TEXT CHECK (status IN ('pago','pendente'))
);

CREATE TABLE eventos (
  id SERIAL PRIMARY KEY,
  cliente TEXT,
  tipo TEXT,
  data_evento DATE,
  valor NUMERIC(10,2),
  valor_pago NUMERIC(10,2)
);

CREATE TABLE produtos (
  id SERIAL PRIMARY KEY,
  nome TEXT,
  categoria TEXT,
  preco NUMERIC(10,2),
  estoque INT
);

CREATE TABLE vendas (
  id SERIAL PRIMARY KEY,
  data_venda DATE,
  produto_id INT REFERENCES produtos(id),
  quantidade INT,
  valor_total NUMERIC(10,2)
);
