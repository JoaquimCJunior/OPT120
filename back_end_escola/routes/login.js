var express = require('express');
var router = express.Router();
var jwt = require('jsonwebtoken');
var bcrypt = require('bcrypt');
var connection = require('../connection/mysql_connection.js');

const JWT_SECRET_KEY = '2f5b43295ff58fb8615bbd72ed4c145dd89d9ab17637dfaf1831b850e57cf72b'; 

router.post('/', function(req, res, next) {
    const { email, password } = req.body;
  
    connection.query('SELECT * FROM USUARIO WHERE email = ?', [email], function(error, results, fields) {
      if (error) {
        console.log("Erro ao buscar usuário: ", error);
        res.status(500).send("Erro ao buscar usuário.");
        return;
      }
  
      if (results.length === 0) {
        res.status(401).send("Credenciais inválidas.");
        return;
      }
  
      const user = results[0];
  
      bcrypt.compare(password, user.password, function(err, result) {
        if (err) {
          console.log("Erro ao comparar senhas: ", err);
          res.status(500).send("Erro ao comparar senhas.");
          return;
        }
  
        if (!result) {
          res.status(401).send("Credenciais inválidas.");
          return;
        }
        const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET_KEY, { expiresIn: '1h' });
  
        res.send({ token, role: user.role });
      });
    });
});

module.exports = router;