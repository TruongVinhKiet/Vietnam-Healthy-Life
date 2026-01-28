(async ()=>{
  try{
    const ts = Date.now();
    const email = `node_test_${ts}@example.com`;
    console.log('register', email);
    const r = await fetch('http://localhost:60491/auth/register', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ full_name: 'Node Test', email, password: 'testpass' })
    });
    const text = await r.text();
    console.log('register status', r.status, text);
    const data = text ? JSON.parse(text) : {};
    const token = data.token;
    console.log('token', token);

    console.log('sending PUT /auth/me');
    const p = await fetch('http://localhost:60491/auth/me', {
      method: 'PUT', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
      body: JSON.stringify({ full_name: 'Node Test Updated', age: 30 })
    });
    const pt = await p.text();
    console.log('put status', p.status, pt);
  } catch (e) {
    console.error('error', e);
  }
})();
