var express = require('express');
var router = express.Router();
var connection = require('../connection/mysql_connection.js');

router.post('/', function (req, res, next) {
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

router.get('/all-activity', function (req, res, next) {
    connection.query('SELECT * FROM ATIVIDADE', function (error, results, fields) {
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

router.get('/:id', function (req, res, next) {
  const atividadeId = req.params.id;

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

router.put('/:id', function (req, res, next) {
  const atividadeId = req.params.id;
  const { titulo, descricao, data } = req.body;

  connection.query('UPDATE ATIVIDADE SET titulo = ?, descricao = ?, data = ? WHERE id = ?', [titulo, descricao, data, atividadeId], function (error, results, fields) {
    if (error) {
      console.log("Erro ao atualizar atividade: ", error);
      res.status(500).send("Erro ao atualizar atividade.");
      return;
    }

    res.send("Atividade atualizada com sucesso.");
  });
});

router.delete('/:id', function (req, res, next) {
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