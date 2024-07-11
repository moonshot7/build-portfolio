const express = require('express');
const router = express.Router();
const db = require('../config/db');
// Get all trucks
router.get('/', (req, res) => {
    db.query('SELECT * FROM truck', (err, results) => {
        if (err) throw err;
        res.json(results);
    });
});

// Get truck by ID
router.get('/:id', (req, res) => {
    const { id } = req.params;
    db.query('SELECT * FROM truck WHERE truck_num = ?', [id], (err, results) => {
        if (err) throw err;
        res.json(results[0]);
    });
});

// Create new truck
router.post('/', (req, res) => {
    const { matricule, poids } = req.body;
    db.query('INSERT INTO truck (matricule, poids) VALUES (?, ?)', [matricule, poids], (err, result) => {
        if (err) throw err;
        res.json({ id: result.insertId });
    });
});

// Update truck
router.put('/:id', (req, res) => {
    const { id } = req.params;
    const { matricule, poids } = req.body;
    db.query('UPDATE truck SET matricule = ?, poids = ? WHERE truck_num = ?', [matricule, poids, id], (err) => {
        if (err) throw err;
        res.json({ message: 'Truck updated' });
    });
});

// Delete truck
router.delete('/:id', (req, res) => {
    const { id } = req.params;
    db.query('DELETE FROM truck WHERE truck_num = ?', [id], (err) => {
        if (err) throw err;
        res.json({ message: 'Truck deleted' });
    });
});

module.exports = router;
