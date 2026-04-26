import nodemailer from 'nodemailer';
import { emailQueue } from '../config/bull.js';
import logger from '../config/logger.js';

export const setupEmailWorker = () => {
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '465', 10),
    secure: process.env.SMTP_SECURE === 'true' || true,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  emailQueue.process(async (job) => {
    const { to, subject, html } = job.data;

    try {
      const info = await transporter.sendMail({
        from: `"${process.env.SMTP_FROM_NAME || 'SmartCampus'}" <${process.env.SMTP_FROM_EMAIL || process.env.SMTP_USER}>`,
        to,
        subject,
        html,
      });
      logger.info(`Email sent to ${to}: ${info.messageId}`);
      
      // If using Ethereal, log the URL to view the email
      if (process.env.SMTP_HOST && process.env.SMTP_HOST.includes('ethereal.email')) {
        logger.info(`Preview URL: ${nodemailer.getTestMessageUrl(info)}`);
      }
      return info;
    } catch (error) {
      logger.error(`Failed to send email to ${to}: ${error.message}`);
      throw error;
    }
  });

  logger.info('Email worker configured and listening for jobs.');
};
