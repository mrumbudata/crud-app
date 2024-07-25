const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config();

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// Create a connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// CRUD Operations

// Create
app.post('/items', async (req, res) => {
  const { name, quantity } = req.body;
  const [result] = await pool.query('INSERT INTO items (name, quantity) VALUES (?, ?)', [name, quantity]);
  res.status(201).send({ id: result.insertId, name, quantity });
});

// Read all items
app.get('/items', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM items');
  res.status(200).send(rows);
});

// Read a specific item
app.get('/items/:id', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM items WHERE id = ?', [req.params.id]);
  if (rows.length === 0) {
    return res.status(404).send({ message: 'Item not found' });
  }
  res.status(200).send(rows[0]);
});

// Update
app.put('/items/:id', async (req, res) => {
  const { name, quantity } = req.body;
  await pool.query('UPDATE items SET name = ?, quantity = ? WHERE id = ?', [name, quantity, req.params.id]);
  res.status(200).send({ id: req.params.id, name, quantity });
});

// Delete
app.delete('/items/:id', async (req, res) => {
  await pool.query('DELETE FROM items WHERE id = ?', [req.params.id]);
  res.status(204).send();
});

// Start the server
app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});
