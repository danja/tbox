const express = require('express');
const app = express();
const port = 8311;

app.get('/', (req, res) => {
    res.send('Hello, Sandboxed World!');
});

app.listen(port, '0.0.0.0', () => console.log(`Server running on port ${port}`));