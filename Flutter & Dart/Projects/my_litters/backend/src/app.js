const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();
const env = require('./config/env');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const vehicleRoutes = require('./routes/vehicleRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const subscriptionRoutes = require('./routes/subscriptionRoutes');
const installmentRoutes = require('./routes/installmentRoutes');
const cardRoutes = require('./routes/cardRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

app.use(helmet());
// If CORS_ORIGINS is set, restrict to that allowlist; otherwise stay open
// (dev + native apps send no browser Origin header).
app.use(
  cors(
    env.corsOrigins
      ? {
          origin(origin, cb) {
            if (!origin || env.corsOrigins.includes(origin)) {
              return cb(null, true);
            }
            return cb(new Error('Not allowed by CORS'));
          },
        }
      : {},
  ),
);
app.use(express.json({ limit: '256kb' }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

app.get('/', (req, res) => {
  res.json({ name: 'my-litters-api', status: 'ok' });
});

app.get('/health', (req, res) => {
  res.json({ ok: true, ts: new Date().toISOString() });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/installments', installmentRoutes);
app.use('/api/cards', cardRoutes);
app.use('/api/transactions', transactionRoutes);

app.use((req, res) => res.status(404).json({ success: false, message: 'Not found' }));
app.use(errorHandler);

module.exports = app;
