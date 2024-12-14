CREATE database loja;

CREATE TABLE Livro (
    ID INT AUTO_INCREMENT PRIMARY KEY, 
    Titulo VARCHAR(255) NOT NULL,      
    Autor VARCHAR(255) NOT NULL,      
    Preco DECIMAL(10, 2) NOT NULL CHECK (Preco >= 0), 
    Estoque INT CHECK (Estoque >= 0), 
    Formato ENUM('fisico')
);



CREATE TABLE Cliente (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Data_Nascimento DATE,
    Endereco TEXT,
    Telefone VARCHAR(40)
);

CREATE TABLE Pedido (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ClienteID INT NOT NULL,
    Data_Pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Status ENUM('Pendente', 'Pago', 'Cancelado', 'Entregue') DEFAULT 'Pendente',
    Valor_Total DECIMAL(10, 2),
    Forma_Pagamento VARCHAR(50),
    FOREIGN KEY (ClienteID) REFERENCES Cliente(ID)
);

CREATE TABLE ItemPedido (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Valor_Total DECIMAL(10, 2) NOT NULL,
    PedidoID INT,
    LivroID INT,  -- Ajustado para LivroID em vez de LivroDigitalID
    Quantidade INT DEFAULT 1,
    FOREIGN KEY (PedidoID) REFERENCES Pedido(ID),
    FOREIGN KEY (LivroID) REFERENCES Livro(ID)
);



DELIMITER $$

CREATE PROCEDURE InserirPedido(
    IN p_cliente_id INT, -- ID do cliente que está fazendo o pedido
    IN p_status ENUM('Pendente', 'Pago', 'Cancelado', 'Entregue'), -- Status do pedido
    IN p_valor_total DECIMAL(10, 2), -- Valor total do pedido
    IN p_forma_pagamento VARCHAR(50), -- Forma de pagamento
    IN p_itens JSON -- Itens do pedido em formato JSON
)
BEGIN
    DECLARE pedido_id INT; -- ID do pedido gerado
    DECLARE livro_id INT; -- ID do livro
    DECLARE quantidade INT; -- Quantidade de itens do livro
    DECLARE valor_item DECIMAL(10, 2); -- Valor do item
    DECLARE done INT DEFAULT 0; -- Variável para sinalizar o final do cursor

    -- Declaração do cursor para processar os itens
    DECLARE item_cursor CURSOR FOR 
        SELECT jt.LivroID, jt.Quantidade, jt.ValorItem 
        FROM JSON_TABLE(
            p_itens, '$[*]'
            COLUMNS(
                LivroID INT PATH '$.livro_id',
                Quantidade INT PATH '$.quantidade',
                ValorItem DECIMAL(10, 2) PATH '$.valor_item'
            )
        ) AS jt; -- Adicionando o alias 'jt' à função JSON_TABLE

    -- Handler para detectar o final do cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Inicia a transação
    START TRANSACTION;

    -- Inserir o pedido na tabela Pedido
    INSERT INTO Pedido (ClienteID, Status, Valor_Total, Forma_Pagamento)
    VALUES (p_cliente_id, p_status, p_valor_total, p_forma_pagamento);

    -- Obter o ID do pedido recém-inserido
    SET pedido_id = LAST_INSERT_ID();

    -- Processar os itens do pedido
    OPEN item_cursor;
    item_loop: LOOP
        FETCH item_cursor INTO livro_id, quantidade, valor_item;
        IF done THEN
            LEAVE item_loop;
        END IF;

        -- Inserir cada item na tabela ItemPedido
        INSERT INTO ItemPedido (Valor_Total, PedidoID, LivroID, Quantidade)
        VALUES (valor_item, pedido_id, livro_id, quantidade);
    END LOOP;
    CLOSE item_cursor;

    -- Finalizar a transação
    COMMIT;
END$$

DELIMITER ;
