require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const Anthropic = require('@anthropic-ai/sdk');

const app = express();
const PORT = process.env.PORT || 3000;

// ---- Config ----
const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;
const APP_SHARED_SECRET = process.env.APP_SHARED_SECRET;
const MODEL = process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6';
const MAX_TOKENS = parseInt(process.env.MAX_TOKENS || '600', 10);

if (!ANTHROPIC_API_KEY) {
  console.error('FATAL: ANTHROPIC_API_KEY is not set. Set it in your .env (local) or host env vars (Railway/Render).');
  process.exit(1);
}

const anthropic = new Anthropic({ apiKey: ANTHROPIC_API_KEY });

app.use(cors());
app.use(express.json({ limit: '1mb' }));

const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, slow down a moment.' },
});
app.use('/api/', limiter);

function requireAppSecret(req, res, next) {
  if (!APP_SHARED_SECRET) return next();
  const provided = req.header('x-app-key');
  if (provided !== APP_SHARED_SECRET) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

app.get('/health', (req, res) => {
  res.json({ status: 'ok', model: MODEL, time: new Date().toISOString() });
});

app.post('/api/caddie-advice', requireAppSecret, async (req, res) => {
  try {
    const { prompt, system, maxTokens } = req.body;

    if (!prompt || typeof prompt !== 'string') {
      return res.status(400).json({ error: 'Missing "prompt" string in request body.' });
    }

    const message = await anthropic.messages.create({
      model: MODEL,
      max_tokens: Math.min(maxTokens || MAX_TOKENS, 1024),
      system: system || undefined,
      messages: [{ role: 'user', content: prompt }],
    });

    const text = message.content
      .filter((block) => block.type === 'text')
      .map((block) => block.text)
      .join('\n');

    res.json({ advice: text, usage: message.usage });
  } catch (err) {
    console.error('Anthropic API error:', err?.message || err);
    res.status(502).json({ error: 'Failed to get caddie advice. Please try again.' });
  }
});

app.listen(PORT, () => {
  console.log(`GolfIQ proxy listening on port ${PORT}`);
  console.log(`Model: ${MODEL}, max_tokens ceiling: ${MAX_TOKENS}`);
  console.log(APP_SHARED_SECRET ? 'App shared-secret auth: ON' : 'WARNING: App shared-secret auth is OFF (set APP_SHARED_SECRET)');
});
