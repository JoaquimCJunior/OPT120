const mysql = require('mysql');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'Junior',
  password: 'Juka9999',
  database: 'escola_express'
});

connection.connect((err) => {
  if (err) {
    console.error('Erro ao conectar ao MySQL:', err);
    return;
  }
  console.log('Conexão com MySQL estabelecida com sucesso');
  
});

module.exports = connection;