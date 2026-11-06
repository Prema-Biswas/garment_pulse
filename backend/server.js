const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');

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

// Add a new order
app.post('/api/orders', (req, res) => {
    const { buyer, product, quantity, status } = req.body;

    // Validate order data
    if (!buyer || !product || !quantity || !status) {
        return res.status(400).json({
            message: 'All fields are required'
        });
    }

    const newOrder = {
        id: orders.length + 1,
        buyer,
        product,
        quantity,
        status
    };

    orders.push(newOrder);

    res.status(201).json({
        message: 'Order added successfully!',
        order: newOrder
    });
});
// User Registration API
app.post('/api/auth/register', async (req, res) => {
    try {
        const {
            full_name,
            username,
            email,
            phone,
            password
        } = req.body;

        // Validate required fields
        if (!full_name || !username || !email || !password) {
            return res.status(400).json({
                message: 'Full name, username, email and password are required'
            });
        }

        if (password.length < 8) {
            return res.status(400).json({
                message: 'Password must be at least 8 characters long'
            });
        }

        // Check duplicate username or email
        const [existingUsers] = await db.execute(
            'SELECT id FROM users WHERE username = ? OR email = ?',
            [username, email]
        );

        if (existingUsers.length > 0) {
            return res.status(409).json({
                message: 'Username or email already exists'
            });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert user into database
        const [result] = await db.execute(
            `INSERT INTO users
            (full_name, username, email, phone, password)
            VALUES (?, ?, ?, ?, ?)`,
            [
                full_name,
                username,
                email,
                phone || null,
                hashedPassword
            ]
        );

        res.status(201).json({
            message: 'Registration successful!',
            userId: result.insertId
        });

    } catch (error) {
        console.error('Registration error:', error);

        res.status(500).json({
            message: 'Server error during registration'
        });
    }
});
// User Login API
app.post('/api/auth/login', async (req, res) => {
    try {
        const { identifier, password } = req.body;

        if (!identifier || !password) {
            return res.status(400).json({
                message: 'Username/email and password are required'
            });
        }

        // Find user by username or email
        const [users] = await db.execute(
            'SELECT * FROM users WHERE username = ? OR email = ? LIMIT 1',
            [identifier, identifier]
        );

        if (users.length === 0) {
            return res.status(401).json({
                message: 'Invalid username/email or password'
            });
        }

        const user = users[0];

        // Verify password
        const isPasswordValid = await bcrypt.compare(
            password,
            user.password
        );

        if (!isPasswordValid) {
            return res.status(401).json({
                message: 'Invalid username/email or password'
            });
        }

        // Generate JWT token
        const token = jwt.sign(
            {
                userId: user.id,
                username: user.username,
                role: user.role
            },
            process.env.JWT_SECRET,
            {
                expiresIn: process.env.JWT_EXPIRES_IN || '1d'
            }
        );

        res.json({
            message: 'Login successful',
            token: token,
            user: {
                id: user.id,
                fullName: user.full_name,
                username: user.username,
                email: user.email,
                role: user.role
            }
        });

    } catch (error) {
        console.error('Login error:', error);

        res.status(500).json({
            message: 'Server error during login'
        });
    }
});
console.log('REGISTER AND LOGIN ROUTES LOADED');

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Garment Pulse API running on port ${PORT}`);
});