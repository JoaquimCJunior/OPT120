var express = require('express');
var router = express.Router();
var connection = require('../connection/mysql_connection.js');
var jwt = require('jsonwebtoken');
var bcrypt = require('bcrypt');

const JWT_SECRET_KEY = '2f5b43295ff58fb8615bbd72ed4c145dd89d9ab17637dfaf1831b850e57cf72b'; 

// Middleware para verificar token JWT
function verifyToken(req, res, next) {
  const token = req.headers['jwt'];

  if (!token) {
    return res.status(403).send("Token não fornecido.");
  }

  jwt.verify(token, JWT_SECRET_KEY, function(err, decoded) {
    if (err) {
      return res.status(401).send("Token inválido.");
    }

    req.user = decoded;
    next();
  });
}

router.post('/', verifyToken, function (req, res, next) {
  const { id_usuario, id_atividade, data, nota } = req.body;
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  connection.query('INSERT INTO USUARIO_ATIVIDADE (id_usuario, id_atividade, data, nota) VALUES (?, ?, ?, ?)', [id_usuario, id_atividade, data, nota], function (error, results, fields) {
    if (error) {
      console.log("Erro ao associar usuário à atividade: ", error);
      res.status(500).send("Erro ao associar usuário à atividade.");
      return;
    }

    res.status(201).send("Usuário associado à atividade com sucesso.");
  });
});

router.get('/all-users-activity', verifyToken, function (req, res, next) {
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  connection.query('SELECT * FROM USUARIO_ATIVIDADE WHERE desabilitado = FALSE', function (error, results, fields) {
    if (error) {
      console.log("Erro ao buscar usuários: ", error);
      res.status(500).send("Erro ao buscar usuários.");
    }
    res.send(results);
  });

});

router.get('/:id', verifyToken, function (req, res, next) {
  const userActivityId = req.params.id;
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  connection.query('SELECT * FROM USUARIO_ATIVIDADE WHERE id = ?', [userActivityId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao buscar associação de usuário à atividade: ", error);
      res.status(500).send("Erro ao buscar associação de usuário à atividade.");
      return;
    }

    if (results.length === 0) {
      res.status(404).send("Associação de usuário à atividade não encontrada.");
      return;
    }

    res.send(results[0]);
  });
});

router.put('/:id', verifyToken, function (req, res, next) {
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  const userActivityId = req.params.id;
  const { id_usuario, id_atividade, data, nota, desabilitado } = req.body;

  let updates = [];
  let params = [];

  if (id_usuario) {
    updates.push('id_usuario = ?');
    params.push(id_usuario);
  }

  if (id_atividade) {
    updates.push('id_atividade = ?');
    params.push(id_atividade);
  }

  if (data) {
    updates.push('data = ?');
    params.push(data);
  }

  if (nota) {
    updates.push('nota = ?');
    params.push(nota);
  }

  if (desabilitado !== undefined) {
    updates.push('desabilitado = ?');
    params.push(desabilitado);
  }

  if (updates.length === 0) {
    res.status(400).send("Nenhum campo fornecido para atualização.");
    return;
  }

  params.push(userActivityId);

  const sql = `UPDATE USUARIO_ATIVIDADE SET ${updates.join(', ')} WHERE id = ?`;

  connection.query(sql, params, function (error, results, fields) {
    if (error) {
      console.log("Erro ao atualizar Atividade de Usuário: ", error);
      res.status(500).send("Erro ao atualizar Atividade de Usuário.");
      return;
    }

    res.send("Atividade de Usuário atualizado com sucesso.");
  });
});

router.delete('/:id', verifyToken, function (req, res, next) {
  const userActivityId = req.params.id;
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  connection.query('DELETE FROM USUARIO_ATIVIDADE WHERE id = ?', [userActivityId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao excluir associação de usuário à atividade: ", error);
      res.status(500).send("Erro ao excluir associação de usuário à atividade.");
      return;
    }

    res.send("Associação de usuário à atividade excluída com sucesso.");
  });
});

module.exports = router;