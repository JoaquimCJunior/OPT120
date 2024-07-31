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
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  const { titulo, descricao, data } = req.body;

  connection.query('INSERT INTO ATIVIDADE (titulo, descricao, data) VALUES (?, ?, ?)', [titulo, descricao, data], function (error, results, fields) {
    if (error) {
      console.log("Erro ao criar atividade: ", error);
      res.status(500).send("Erro ao criar atividade.");
      return;
    }

    res.status(201).send("Atividade criada com sucesso.");
  });
});

router.get('/all-activity', verifyToken, function (req, res, next) {
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  connection.query('SELECT * FROM ATIVIDADE WHERE desabilitado = FALSE', function (error, results, fields) {
    if(error) {
      console.log("Erro ao buscar atividades: ", error);
      res.status(500).send("Erro ao buscar atividades.");
    }
    if(results === null){
    res.send("Nenhuma atividade cadastrada!");

    }
    res.send(results);
  });
});

router.get('/:id', verifyToken, function (req, res, next) {
  const atividadeId = req.params.id;
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  connection.query('SELECT * FROM ATIVIDADE WHERE id = ?', [atividadeId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao buscar atividade: ", error);
      res.status(500).send("Erro ao buscar atividade.");
      return;
    }

    if (results.length === 0) {
      res.status(404).send("Atividade não encontrada.");
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

  const activityId = req.params.id;
  const { titulo, descricao, data, desabilitado } = req.body;

  let updates = [];
  let params = [];

  if (titulo) {
    updates.push('titulo = ?');
    params.push(titulo);
  }

  if (descricao) {
    updates.push('descricao = ?');
    params.push(descricao);
  }

  if (data) {
    updates.push('data = ?');
    params.push(data);
  }

  if (desabilitado !== undefined) {
    updates.push('desabilitado = ?');
    params.push(desabilitado);
  }

  if (updates.length === 0) {
    res.status(400).send("Nenhum campo fornecido para atualização.");
    return;
  }

  params.push(activityId);

  const sql = `UPDATE ATIVIDADE SET ${updates.join(', ')} WHERE id = ?`;

  connection.query(sql, params, function (error, results, fields) {
    if (error) {
      console.log("Erro ao atualizar Atividade: ", error);
      res.status(500).send("Erro ao atualizar Atividade.");
      return;
    }

    if (desabilitado !== undefined) {
      if (desabilitado) {
        const sqlUpdateUsuarioAtividade = `UPDATE USUARIO_ATIVIDADE SET desabilitado = ${desabilitado} WHERE id_atividade = ?`;
        connection.query(sqlUpdateUsuarioAtividade, [activityId], function (err, results, fields) {
          if (err) {
            console.log("Erro ao atualizar USUARIO_ATIVIDADE: ", err);
          }
        });
      }
    }

    res.send("Atividade atualizado com sucesso.");
  });
});

router.delete('/:id', verifyToken, function (req, res, next) {
  const atividadeId = req.params.id;

  connection.query('DELETE FROM ATIVIDADE WHERE id = ?', [atividadeId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao excluir atividade: ", error);
      res.status(500).send("Erro ao excluir atividade.");
      return;
    }

    res.send("Atividade excluída com sucesso.");
  });
});

module.exports = router;