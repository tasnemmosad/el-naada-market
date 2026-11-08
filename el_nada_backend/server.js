
// require('dotenv').config();

// const express = require('express');
// const helmet = require('helmet');

// const { auth } = require('./config/firebase');
// const authRoutes = require('./routes/auth_routes');

// const app = express();

// app.disable('x-powered-by');

// app.use(helmet());
// app.use(express.json({ limit: '10kb' }));

// // Backend health check
// app.get('/health', (req, res) => {
//   res.json({
//     success: true,
//     message: 'El Nada Backend is running',
//   });
// });

// // Firebase connection check (local development only)
// if (process.env.NODE_ENV !== 'production') {
//   app.get('/health/firebase', async (req, res) => {
//     try {
//       await auth.listUsers(1);

//       res.json({
//         success: true,
//         message: 'Firebase connected successfully',
//       });
//     } catch (error) {
//       console.error('Firebase error:', error.code);

//       res.status(500).json({
//         success: false,
//         message: 'Firebase connection failed',
//       });
//     }
//   });
// }

// // Authentication APIs
// app.use('/auth', authRoutes);

// const PORT = process.env.PORT || 3000;

// app.listen(PORT, '0.0.0.0', () => {
//   console.log(`Server running on port ${PORT}`);
// });

require('dotenv').config();

const express = require('express');
const helmet = require('helmet');

const db = require('./config/database');
const authRoutes = require('./routes/auth_routes');

const app = express();

app.disable('x-powered-by');

app.use(helmet());
app.use(express.json({ limit: '10kb' }));

// Backend health check
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'El Nada Backend is running',
  });
});

// MySQL connection check
app.get('/health/db', async (req, res) => {
  try {
    await db.query('SELECT 1');

    res.json({
      success: true,
      message: 'MySQL connected successfully',
    });
  } catch (error) {
    console.error('Database error:', error.message);

    res.status(500).json({
      success: false,
      message: 'MySQL connection failed',
    });
  }
});

// Authentication APIs
app.use('/auth', authRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
