const express = require('express');
const app = express();
const port = 8311;

app.get('/', (req, res) => {
    const headers = JSON.stringify(req.headers, null, 2);
    res.send(`
        <pre>Request Headers:
        ${headers}</pre>
        <hr>
        Hello, Sandboxed World!
    `);
});

app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        time: new Date(),
        uptime: process.uptime()
    });
});

app.listen(port, '0.0.0.0', () => console.log(`Server running on port ${port}`));