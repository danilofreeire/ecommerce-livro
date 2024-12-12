CREATE SCHEMA LojaVirtual;

CREATE TABLE Livro (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Titulo VARCHAR(255) NOT NULL,
    Autor VARCHAR(255) NOT NULL,
    Preco DECIMAL(10, 2) NOT NULL,
    Estoque INT CHECK (estoque >= 0),
    Formato ENUM('digital', 'fisico')
);

CREATE TABLE Cliente (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Data_Nascimento DATE,
    Endereco TEXT,
    Telefone VARCHAR(20)
);

CREATE TABLE LojaVirtual.Pedido (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ClienteID INT NOT NULL,
    Data_Pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Status ENUM('Pendente', 'Pago', 'Cancelado', 'Entregue') DEFAULT 'Pendente',
    Valor_Total DECIMAL(10, 2),
    Forma_Pagamento VARCHAR(50),
    FOREIGN KEY (ClienteID) REFERENCES LojaVirtual.Cliente(ID)
);

CREATE TABLE ItemPedido (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Valor_Total DECIMAL(10, 2) NOT NULL,
    PedidoID INT,
    LivroID INT,  -- Ajustado para LivroID em vez de LivroDigitalID
    Quantidade INT DEFAULT 1,
    FOREIGN KEY (PedidoID) REFERENCES LojaVirtual.Pedido(ID),
    FOREIGN KEY (LivroID) REFERENCES LojaVirtual.Livro(ID)
);





DROP TABLE CLIENTE;
DROP TABLE ITEMPEDIDO;
DROP TABLE LIVRO;
DROP TABLE PEDIDO;

DELIMITER $$

CREATE PROCEDURE InserirDados()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT;
    DECLARE pedidoID INT;

    -- Inserir 60 Clientes
    WHILE i <= 60 DO
        INSERT INTO LojaVirtual.Cliente (Nome, Email, Data_Nascimento, Endereco, Telefone)
        VALUES (CONCAT('Cliente', i), CONCAT('cliente', i, FLOOR(1 + RAND() * 10000), '@exemplo.com'), '1990-01-01', CONCAT('Endereco ', i), CONCAT('Telefone ', i));
        SET i = i + 1;
    END WHILE;

    SET i = 1;

    -- Inserir 60 Livros
    WHILE i <= 60 DO
        INSERT INTO LojaVirtual.Livro (Titulo, Autor, Preco, Estoque, Formato)
        VALUES (CONCAT('Livro ', i), CONCAT('Autor ', i), 50.00, FLOOR(RAND() * 100), 'digital');
        SET i = i + 1;
    END WHILE;

    SET i = 1;

    -- Inserir 100 Pedidos
    WHILE i <= 100 DO
        SET j = 1;
        INSERT INTO LojaVirtual.Pedido (ClienteID, Status, Valor_Total, Forma_Pagamento)
        VALUES (FLOOR(1 + RAND() * 60), 'Pago', 100.00, 'Cartão de Crédito');
        SET pedidoID = LAST_INSERT_ID();

        -- Inserir pelo menos 2 Itens por Pedido
        WHILE j <= 2 DO
            INSERT INTO LojaVirtual.ItemPedido (Valor_Total, PedidoID, LivroID, Quantidade)
            VALUES (50.00, pedidoID, FLOOR(1 + RAND() * 60), 1);
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;




DROP PROCEDURE IF EXISTS InserirDados;


SHOW INDEX FROM LivroDigital;


ALTER TABLE LojaVirtual.LivroDigital
DROP INDEX ISBN;


SHOW INDEX FROM LojaVirtual.LivroDigital;
ALTER TABLE LivroDigital
MODIFY COLUMN ISBN VARCHAR(20) UNIQUE;

ALTER TABLE LojaVirtual.LivroDigital
MODIFY COLUMN ISBN VARCHAR(255) UNIQUE;


CALL InserirDados();



