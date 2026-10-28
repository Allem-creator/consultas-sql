INSERT INTO gastos (descricao, categoria, valor, data_vencimento, status) VALUES
('Aluguel','Moradia',1500.00,'2026-08-05','pago'),
('Internet','Moradia',120.00,'2026-08-10','pago'),
('Mercado','Alimentação',650.00,'2026-08-15','pago'),
('Fatura cartão','Cartão',900.00,'2026-09-05','pago'),
('Aluguel','Moradia',1500.00,'2026-09-05','pago'),
('Mercado','Alimentação',700.00,'2026-09-18','pendente'),
('Curso online','Educação',350.00,'2026-09-20','pendente'),
('Aluguel','Moradia',1500.00,'2026-10-05','pendente'),
('Combustível','Transporte',280.00,'2026-10-08','pendente');
 
INSERT INTO eventos (cliente, tipo, data_evento, valor, valor_pago) VALUES
('Ana','Aniversário','2026-08-12',2000,2000),
('Bruno','Casamento','2026-08-28',5500,5500),
('Carla','Corporativo','2026-09-14',3200,1600),
('Diego','Aniversário','2026-09-27',1800,1800),
('Elisa','Casamento','2026-10-18',6000,3000),
('Fábio','Corporativo','2026-10-25',2500,0);
 
INSERT INTO produtos (nome, categoria, preco, estoque) VALUES
('Vestido Floral','Vestidos',129.90,12),
('Vestido Longo','Vestidos',189.90,5),
('Blusa Básica','Blusas',59.90,30),
('Calça Jeans','Calças',149.90,0),
('Saia Plissada','Saias',99.90,8);
 
INSERT INTO vendas (data_venda, produto_id, quantidade, valor_total) VALUES
('2026-08-20',1,2,259.80),
('2026-09-03',3,3,179.70),
('2026-09-10',2,1,189.90),
('2026-09-21',3,2,119.80),
('2026-10-02',1,1,129.90),
('2026-10-09',4,2,299.80),
('2026-10-15',3,4,239.60);
