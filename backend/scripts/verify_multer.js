import express from 'express';
import multer from 'multer';
import request from 'supertest';

const upload = multer({ dest: 'uploads/' });
const app = express();

app.post('/upload', upload.single('file'), (req, res) => {
  res.status(200).send('Uploaded');
});

// Test the vulnerability: empty string field name
async function test() {
  try {
    const res = await request(app)
      .post('/upload')
      .attach('', Buffer.from('test'), 'test.txt'); // Empty field name
    
    console.log('Status:', res.status);
    console.log('Response:', res.text);
    if (res.status === 200 || res.status === 400) {
      console.log('Vulnerability fixed: Server did not crash.');
    } else {
      console.log('Unexpected status:', res.status);
    }
  } catch (err) {
    console.error('Vulnerability detected: Server crashed!', err);
    process.exit(1);
  }
}

test();
