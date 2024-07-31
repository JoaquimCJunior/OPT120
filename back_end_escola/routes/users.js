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

router.post('/', function (req, res, next) {
  const { nome, email, password } = req.body;

  bcrypt.hash(password, 256, function(err, hash) {
    if (err) {
      console.log("Erro ao criptografar senha: ", err);
      res.status(500).send("Erro ao criar usuário.");
      return;
    }

    connection.query('INSERT INTO USUARIO (nome, email, password, role) VALUES (?, ?, ?, ?)', [nome, email, hash, 'ALUNO'], function (error, results, fields) {
      if (error) {
        console.log("Erro ao criar usuário: ", error);
        res.status(500).send("Erro ao criar usuário.");
        return;
      }

      res.status(201).send("Usuário criado com sucesso.");
    });
  });
});

router.get('/all-users', verifyToken, function (req, res, next) {
  const { roleUser } = req.query;

  if (roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

  connection.query('SELECT * FROM USUARIO WHERE desabilitado = FALSE', function (error, results, fields) {
    if (error) {
      console.log("Erro ao buscar usuários: ", error);
      return res.status(500).send("Erro ao buscar usuários.");
    }
    
    res.send(results);
  });
});


router.get('/:id', verifyToken, function (req, res, next) {
  const userId = req.params.id;
  const { roleUser } = req.query;

  if (roleUser !== 'ALUNO' && roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

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

router.put('/:id', verifyToken, function (req, res, next) {
  const userId = req.params.id;
  const { roleUser } = req.query;

  const { nome, email, password, role, desabilitado } = req.body;

  if (roleUser !== 'ALUNO' && roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

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

  if (role) {
    updates.push('role = ?');
    params.push(role);
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

router.delete('/:id', verifyToken, function (req, res, next) {
  const userId = req.params.id;
  const { roleUser } = req.query;

  if (roleUser !== 'ALUNO' && roleUser !== 'PROFESSOR') {
    return res.status(401).send("Usuário sem permissão!");
  }

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
