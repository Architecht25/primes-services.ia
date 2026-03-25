/**
 * mailer.js – Nodemailer script for Office 365 SMTP
 * Called by Rails EmailService via system command.
 *
 * Usage:
 *   node mailer.js '{"to":"dest@example.com","subject":"Test","html":"<p>Hello</p>"}'
 *
 * Env vars required: SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD
 */

const nodemailer = require('nodemailer');

const { SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD } = process.env;

if (!SMTP_HOST || !SMTP_PORT || !SMTP_USERNAME || !SMTP_PASSWORD) {
  console.error('[Mailer] Variables SMTP_* manquantes dans .env');
  process.exit(1);
}

const payload = JSON.parse(process.argv[2] || '{}');
const { to, subject, html, text } = payload;

if (!to || !subject) {
  console.error('[Mailer] Paramètres manquants: to et subject requis');
  process.exit(1);
}

const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: parseInt(SMTP_PORT, 10),
  secure: parseInt(SMTP_PORT, 10) === 465,
  auth: {
    user: SMTP_USERNAME,
    pass: SMTP_PASSWORD
  }
});

transporter.verify()
  .then(() => {
    console.log('[Mailer] SMTP OK');
    return transporter.sendMail({
      from: `"Primes Services" <${SMTP_USERNAME}>`,
      to,
      subject,
      html: html || '',
      text: text || ''
    });
  })
  .then(info => {
    console.log('[Mailer] Email envoyé:', info.messageId);
    process.exit(0);
  })
  .catch(err => {
    console.error('[Mailer] Erreur:', err.message);
    process.exit(1);
  });
