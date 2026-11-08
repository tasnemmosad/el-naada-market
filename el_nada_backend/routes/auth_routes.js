
const authenticateToken = require('../middleware/auth_middleware');
const express = require('express');

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');


const db = require('../config/database');

const router = express.Router();

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: {
    message: 'تم تجاوز عدد المحاولات المسموح بها.',
  },
});

function normalizePhone(input) {
  if (typeof input !== 'string') return null;

  const phone = input.trim();

  if (/^01[0125][0-9]{8}$/.test(phone)) {
    return '+2' + phone;
  }

  if (/^\+201[0125][0-9]{8}$/.test(phone)) {
    return phone;
  }

  return null;
}

function generateToken(user) {
  return jwt.sign(
    {
      userId: user.id,
      phone: user.phone,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '1d',
    }
  );
}

// REGISTER
router.post('/register', authLimiter, async (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const password = req.body?.password;

  if (!phone) {
    return res.status(400).json({
      message: 'يرجى إدخال رقم موبايل صحيح.',
    });
  }

  if (
    typeof password !== 'string' ||
    password.length < 8 ||
    Buffer.byteLength(password, 'utf8') > 72
  ) {
    return res.status(400).json({
      message: 'يرجى إدخال كلمة مرور من 8 أحرف على الأقل.',
    });
  }

  try {
    const passwordHash = await bcrypt.hash(password, 12);

    const [result] = await db.execute(
      `INSERT INTO users (phone, password_hash)
       VALUES (?, ?)`,
      [phone, passwordHash]
    );

    const user = {
      id: result.insertId,
      phone,
    };

    const token = generateToken(user);

    return res.status(201).json({
      success: true,
      message: 'تم إنشاء الحساب بنجاح.',
      token,
      user: {
        id: user.id,
        phone: user.phone,
      },
    });

  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        message: 'هذا الرقم مسجل بالفعل.',
      });
    }

    console.error('Register error:', error.message);

    return res.status(500).json({
      message: 'تعذر إنشاء الحساب. يرجى المحاولة لاحقًا.',
    });
  }
});

// LOGIN
router.post('/login', authLimiter, async (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const password = req.body?.password;

  const invalidCredentials = {
    message: 'رقم الموبايل أو كلمة المرور غير صحيحة.',
  };

  if (
    !phone ||
    typeof password !== 'string' ||
    Buffer.byteLength(password, 'utf8') > 72
  ) {
    return res.status(401).json(invalidCredentials);
  }

  try {
    const [rows] = await db.execute(
      `SELECT id, phone, password_hash
       FROM users
       WHERE phone = ?
       LIMIT 1`,
      [phone]
    );

    if (rows.length === 0) {
      return res.status(401).json(invalidCredentials);
    }

    const user = rows[0];

    const isCorrect = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!isCorrect) {
      return res.status(401).json(invalidCredentials);
    }

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: 'تم تسجيل الدخول بنجاح.',
      token,
      user: {
        id: user.id,
        phone: user.phone,
      },
    });

  } catch (error) {
    // console.error('Login error:', error.message);
console.error('LOGIN ERROR DETAILS:');
console.error(error);
console.error('Error code:', error.code);
console.error('Error message:', error.message);
console.error('Error stack:', error.stack);
    return res.status(500).json({
      message: 'تعذر تسجيل الدخول. يرجى المحاولة لاحقًا.',
    });
  }
  
});
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT id, phone FROM users WHERE id = ? LIMIT 1`,
      [req.user.userId]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        message: 'المستخدم غير موجود.',
      });
    }

    return res.status(200).json({
      success: true,
      user: rows[0],
    });

  } catch (error) {
    console.error('Auth verification error:', error.message);

    return res.status(500).json({
      message: 'تعذر التحقق من الحساب.',
    });
  }
});
console.log('AUTH ROUTES LOADED');
console.log(
  'Registered auth routes:',
  router.stack.map(layer => ({
    path: layer.route?.path,
    methods: layer.route?.methods,
  }))
);
module.exports = router;
