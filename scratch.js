async function test() {
  try {
    const loginRes = await fetch('http://localhost:3000/api/v1/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'ketua@test.com', // wait, is this a real user? I'll fetch db users first
        password: 'password123'
      })
    });
    const loginData = await loginRes.json();
    console.log(loginData);
  } catch (err) {
    console.error(err);
  }
}
test();
