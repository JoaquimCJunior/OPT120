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
  connection.query('SELECT * FROM USUARIO WHERE desabilitado = FALSE', function (error, results, fields) {
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
  const { nome, email, password, desabilitado } = req.body;

  let updates = [];
  let params = [];

  if (nome) {
    updates.push('nome = ?');
    params.push(nome);
  }

  if (email) {
    updates.push('email = ?');
    params.push(email);
  }

  if (password) {
    updates.push('password = ?');
    params.push(password);
  }

  if (desabilitado !== undefined) {
    updates.push('desabilitado = ?');
    params.push(desabilitado);
  }

  if (updates.length === 0) {
    res.status(400).send("Nenhum campo fornecido para atualização.");
    return;
  }

  params.push(userId);

  const sql = `UPDATE USUARIO SET ${updates.join(', ')} WHERE id = ?`;

  connection.query(sql, params, function (error, results, fields) {
    if (error) {
      console.log("Erro ao atualizar usuário: ", error);
      res.status(500).send("Erro ao atualizar usuário.");
      return;
    }

    if (desabilitado !== undefined) {
      if (desabilitado) {
        const sqlUpdateUsuarioAtividade = `UPDATE USUARIO_ATIVIDADE SET desabilitado = ${desabilitado} WHERE id_usuario = ?`;
        connection.query(sqlUpdateUsuarioAtividade, [userId], function (err, results, fields) {
          if (err) {
            console.log("Erro ao atualizar USUARIO_ATIVIDADE: ", err);
          }
        });
      }
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
