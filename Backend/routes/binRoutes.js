const express = require('express');
const router = express.Router();
const db = require('../config/db');

// Get all bins
router.get('/', (req, res) => {
    db.query('SELECT * FROM bin', (err, results) => {
        if (err) throw err;
        res.json(results);
    });
});

// Get bin by ID
router.get('/:id', (req, res) => {
    const { id } = req.params;
    db.query('SELECT * FROM bin WHERE serie_num = ?', [id], (err, results) => {
        if (err) throw err;
        res.json(results[0]);
    });
});

// Create new bin
router.post('/', (req, res) => {
    const { name, poids, longitude, latitude } = req.body;
    db.query('INSERT INTO bin (name, poids, longitude, latitude) VALUES (?, ?, ?, ?)', [name, poids, longitude, latitude], (err, result) => {
        if (err) throw err;
        res.json({ id: result.insertId });
    });
});

// Update bin
router.put('/:id', (req, res) => {
    const { id } = req.params;
    const { name, poids, longitude, latitude } = req.body;
    db.query('UPDATE bin SET name = ?, poids = ?, longitude = ?, latitude = ? WHERE serie_num = ?', [name, poids, longitude, latitude, id], (err) => {
        if (err) throw err;
        res.json({ message: 'Bin updated' });
    });
});

// Delete bin
router.delete('/:id', (req, res) => {
    const { id } = req.params;
    db.query('DELETE FROM bin WHERE serie_num = ?', [id], (err) => {
        if (err) throw err;
        res.json({ message: 'Bin deleted' });
    });
});

module.exports = router;
