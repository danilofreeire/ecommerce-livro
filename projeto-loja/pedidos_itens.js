const mysql = require('mysql2/promise');

// Configuração do banco de dados
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'danilo123',
  database: 'loja',
};

async function seedPedidosEAtualizarEstoque() {
  const connection = await mysql.createConnection(dbConfig);

  try {
    console.log('Conectado ao banco de dados!');

    // Inserir Pedidos e Itens
    console.log('Inserindo Pedidos e Atualizando Estoques...');
    for (let i = 1; i <= 100; i++) {
      const clienteID = (i % 60) + 1; // ClienteID cíclico entre 1 e 60
      const status = ['Pendente', 'Pago', 'Cancelado', 'Entregue'][i % 4]; // Alterna status
      const valorTotal = (100 + i * 10).toFixed(2); // Valor total fixo
      const formaPagamento = ['Cartão de Crédito', 'Boleto', 'Pix'][i % 3]; // Alterna forma de pagamento

      // Inserir o pedido
      const [pedidoResult] = await connection.query(
        'INSERT INTO Pedido (ClienteID, Status, Valor_Total, Forma_Pagamento) VALUES (?, ?, ?, ?)',
        [clienteID, status, valorTotal, formaPagamento]
      );
      const pedidoID = pedidoResult.insertId;

      // Gerar e inserir itens para o pedido (mínimo 2 itens por pedido)
      const numItens = 2;
      for (let j = 0; j < numItens; j++) {
        const livroID = (i + j) % 60 + 1; // ID do livro
        const quantidade = j + 2; // Quantidade crescente
        const valorItem = (quantidade * 15).toFixed(2); // Valor baseado na quantidade

        // Verificar estoque
        const [livro] = await connection.query(
          'SELECT Estoque FROM Livro WHERE ID = ?',
          [livroID]
        );
        const estoqueAtual = livro[0]?.Estoque || 0;

        if (estoqueAtual < quantidade) {
          console.error(
            `Estoque insuficiente para Livro ${livroID}. Pedido ${pedidoID} não pode ser processado.`
          );
          continue;
        }

        // Atualizar estoque
        await connection.query(
          'UPDATE Livro SET Estoque = Estoque - ? WHERE ID = ?',
          [quantidade, livroID]
        );

        // Inserir item no pedido
        await connection.query(
          'INSERT INTO ItemPedido (Valor_Total, PedidoID, LivroID, Quantidade) VALUES (?, ?, ?, ?)',
          [valorItem, pedidoID, livroID, quantidade]
        );
      }

      console.log(`Pedido ${i} inserido com sucesso!`);
    }

    console.log('Pedidos inseridos e estoques atualizados com sucesso!');
  } catch (error) {
    console.error('Erro ao inserir pedidos:', error);
  } finally {
    await connection.end();
    console.log('Conexão encerrada.');
  }
}

seedPedidosEAtualizarEstoque();
