const express = require('express');

const app = express();
const PORT = 3000;

app.use(express.json());

// Temporary order data
const orders = [
    {
        id: 1,
        buyer: "ABC Fashion",
        product: "T-Shirt",
        quantity: 500,
        status: "In Production"
    },
    {
        id: 2,
        buyer: "XYZ Garments",
        product: "Jeans",
        quantity: 300,
        status: "Completed"
    }
];

// Test endpoint
app.get('/', (req, res) => {
    res.send('Garment Pulse API is running!');
});

// Get all orders
app.get('/api/orders', (req, res) => {
    res.json(orders);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Garment Pulse API running on port ${PORT}`);
});