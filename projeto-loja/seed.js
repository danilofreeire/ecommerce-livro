const mysql = require('mysql2/promise');

// Configuração do banco de dados
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'danilo123',
  database: 'loja',
};

async function seedDatabase() {
  const connection = await mysql.createConnection(dbConfig);

  try {
    console.log('Conectado ao banco de dados!');

    // Limpar tabelas (opcional)
    await connection.query('SET FOREIGN_KEY_CHECKS = 0;');
    await connection.query('TRUNCATE TABLE ItemPedido;');
    await connection.query('TRUNCATE TABLE Pedido;');
    await connection.query('TRUNCATE TABLE Cliente;');
    await connection.query('TRUNCATE TABLE Livro;');
    await connection.query('SET FOREIGN_KEY_CHECKS = 1;');

    // Inserir Livros
    console.log('Inserindo Livros...');
    const livros = [];
    for (let i = 1; i <= 60; i++) {
      livros.push([`Livro ${i}`, `Autor ${i}`, (i * 10).toFixed(2), i * 5, i % 2 === 0 ? 'fisico' : 'digital']);
    }
    await connection.query('INSERT INTO Livro (Titulo, Autor, Preco, Estoque, Formato) VALUES ?', [livros]);

    // Inserir Clientes
    console.log('Inserindo Clientes...');
    const clientes = [];
    for (let i = 1; i <= 60; i++) {
      clientes.push([`Cliente ${i}`, `cliente${i}@email.com`, `198${i % 10}-01-01`, `Rua ${i}, Bairro ${i}, Cidade ${i}, Estado ${i}`, `(55) 9${i}234-5678`]);
    }
    await connection.query('INSERT INTO Cliente (Nome, Email, Data_Nascimento, Endereco, Telefone) VALUES ?', [clientes]);

    // Inserir Pedidos e Itens chamando a stored procedure
    console.log('Inserindo Pedidos e Itens...');
    for (let i = 1; i <= 100; i++) {
      const clienteID = (i % 60) + 1; // ClienteID cíclico entre 1 e 60
      const status = ['Pendente', 'Pago', 'Cancelado', 'Entregue'][i % 4]; // Alterna status
      const valorTotal = (100 + i * 10).toFixed(2); // Valor total fixo
      const formaPagamento = ['Cartão', 'Boleto', 'Pix'][i % 3]; // Alterna forma de pagamento

      // Gerar itens do pedido como JSON
      const numItens = 2; // Sempre 2 itens por pedido
      const itens = [];
      for (let j = 0; j < numItens; j++) {
        itens.push({
          livro_id: (i + j) % 60 + 1, // ID do livro
          quantidade: j + 2, // Quantidade crescente
          valor_item: (j + 2) * 15, // Valor baseado na quantidade
        });
      }
      const itensJSON = JSON.stringify(itens);

      // Chamar a stored procedure
      try {
        await connection.query('CALL InserirPedido(?, ?, ?, ?, ?)', [clienteID, status, valorTotal, formaPagamento, itensJSON]);
        console.log(`Pedido ${i} inserido com sucesso!`);
      } catch (error) {
        console.error(`Erro ao inserir pedido ${i}:`, error.message);
      }
    }

    console.log('Dados inseridos com sucesso!');
  } catch (error) {
    console.error('Erro ao inserir dados:', error);
  } finally {
    await connection.end();
    console.log('Conexão encerrada.');
  }
}

seedDatabase();
