const mysql = require('mysql2/promise');

// Configuração do banco de dados
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'danilo123',
  database: 'loja',
};

async function seedClientesELivros() {
  const connection = await mysql.createConnection(dbConfig);

  try {
    console.log('Conectado ao banco de dados!');

    // Limpar tabelas (opcional)
    await connection.query('SET FOREIGN_KEY_CHECKS = 0;');
    await connection.query('TRUNCATE TABLE Cliente;');
    await connection.query('TRUNCATE TABLE Livro;');
    await connection.query('SET FOREIGN_KEY_CHECKS = 1;');

    // Inserir Livros (apenas físicos)
    console.log('Inserindo Livros...');
    const livros = [];
    for (let i = 1; i <= 60; i++) {
      livros.push([
        `Livro ${i}`, // Título
        `Autor ${i}`, // Autor
        (i * 10).toFixed(2), // Preço
        i * 5, // Estoque inicial
        'fisico', // Apenas livros físicos
      ]);
    }
    await connection.query(
      'INSERT INTO Livro (Titulo, Autor, Preco, Estoque, Formato) VALUES ?',
      [livros]
    );

    // Inserir Clientes
    console.log('Inserindo Clientes...');
    const clientes = [];
    for (let i = 1; i <= 60; i++) {
      clientes.push([
        `Cliente ${i}`, // Nome
        `cliente${i}@email.com`, // Email
        `198${i % 10}-01-01`, // Data de nascimento
        `Rua ${i}, Bairro ${i}, Cidade ${i}, Estado ${i}`, // Endereço
        `(55) 9${i}234-5678`, // Telefone
      ]);
    }
    await connection.query(
      'INSERT INTO Cliente (Nome, Email, Data_Nascimento, Endereco, Telefone) VALUES ?',
      [clientes]
    );

    console.log('Clientes e Livros inseridos com sucesso!');
  } catch (error) {
    console.error('Erro ao inserir dados:', error);
  } finally {
    await connection.end();
    console.log('Conexão encerrada.');
  }
}

seedClientesELivros();
