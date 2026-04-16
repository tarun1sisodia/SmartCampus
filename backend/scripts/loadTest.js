import '../src/config/env.js';
import mongoose from 'mongoose';
import User from '../src/models/User.model.js';

const API_URL = 'http://localhost:5000/api/v1';

async function simulateTeacherSession(email, password) {
  const start = Date.now();
  try {
    // 1. Login
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    const loginData = await loginRes.json();
    if (!loginData.success) throw new Error('Login failed');

    const token = loginData.data.accessToken;

    // 2. Fetch Sessions
    const sessionRes = await fetch(`${API_URL}/sessions?date=today`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const sessionData = await sessionRes.json();
    if (!sessionData.success) throw new Error('Fetch sessions failed');

    const duration = Date.now() - start;
    return { success: true, duration };
  } catch (err) {
    return { success: false, error: err.message, duration: Date.now() - start };
  }
}

async function runLoadTest(limit = 500) {
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus');
  
  console.log(`🔍 Fetching ${limit} teachers for load testing...`);
  const teachers = await User.find({ role: 'teacher' }).limit(limit);
  console.log(`👥 Found ${teachers.length} teachers. Starting parallel execution...`);

  const startTime = Date.now();
  
  // Running in parallel
  const results = await Promise.all(
    teachers.map(t => simulateTeacherSession(t.email, 'TeacherPassword123'))
  );

  const totalTime = Date.now() - startTime;
  const successes = results.filter(r => r.success);
  const failures = results.filter(r => !r.success);
  
  const avgDuration = successes.reduce((acc, r) => acc + r.duration, 0) / successes.length;

  console.log('\n--- Load Test Results ---');
  console.log(`Total Parallel Users: ${results.length}`);
  console.log(`Successes: ${successes.length}`);
  console.log(`Failures: ${failures.length}`);
  console.log(`Total Wall Clock Time: ${(totalTime / 1000).toFixed(2)}s`);
  console.log(`Average Session Duration: ${avgDuration.toFixed(2)}ms`);
  
  if (failures.length > 0) {
    console.log('Sample Error:', failures[0].error);
  }

  process.exit(0);
}

runLoadTest(500);
