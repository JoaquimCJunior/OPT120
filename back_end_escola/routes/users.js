var express = require('express');
var router = express.Router();
var connection = require('../connection/mysql_connection.js')

router.post('/', function (req, res, next) {
  const { nome, email, password } = req.body;

  connection.query('INSERT INTO USUARIO (nome, email, password) VALUES (?, ?, ?)', [nome, email, password], function (error, results, fields) {
    if (error) {
      console.log("Erro ao criar usuário: ", error);
      res.status(500).send("Erro ao criar usuário.");
      return;
    }

    res.status(201).send("Usuário criado com sucesso.");
  });
});

router.get('/all-users', function (req, res, next) {
  connection.query('SELECT * FROM USUARIO', function (error, results, fields) {
    if(error) {
      console.log("Erro ao buscar usuários: ", error);
      res.status(500).send("Erro ao buscar usuários.");
    }
    res.send(results);
  });

});

router.get('/:id', function (req, res, next) {
  const userId = req.params.id;

  connection.query('SELECT * FROM USUARIO WHERE id = ?', [userId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao buscar usuário: ", error);
      res.status(500).send("Erro ao buscar usuário.");
      return;
    }

    if (results.length === 0) {
      res.status(404).send("Usuário não encontrado.");
      return;
    }

    res.send(results[0]);
  });
});

router.put('/:id', function (req, res, next) {
  const userId = req.params.id;
  const { nome, email, password } = req.body;

  connection.query('UPDATE USUARIO SET nome = ?, email = ?, password = ? WHERE id = ?', [nome, email, password, userId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao atualizar usuário: ", error);
      res.status(500).send("Erro ao atualizar usuário.");
      return;
    }

    res.send("Usuário atualizado com sucesso.");
  });
});

router.delete('/:id', function (req, res, next) {
  const userId = req.params.id;

  connection.query('DELETE FROM USUARIO WHERE id = ?', [userId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao excluir usuário: ", error);
      res.status(500).send("Erro ao excluir usuário.");
      return;
    }

    res.send("Usuário excluído com sucesso.");
  });
});

module.exports = router;
