import express from 'express';
import fetch from 'node-fetch';

const app = express();

const checkFusekiHealth = async () => {
    try {
        const response = await fetch('http://fuseki:3030/$/ping', {
            timeout: 5000
        });
        return {
            status: response.ok ? 'healthy' : 'unhealthy',
            responseTime: response.headers.get('X-Response-Time'),
            lastChecked: new Date().toISOString()
        };
    } catch (error) {
        return {
            status: 'unhealthy',
            error: error.message,
            lastChecked: new Date().toISOString()
        };
    }
};

const checkProsodyHealth = async () => {
    try {
        const response = await fetch('http://xmpp:5282/http-monitor', {
            timeout: 5000
        });
        return {
            status: response.ok ? 'healthy' : 'unhealthy',
            responseTime: response.headers.get('X-Response-Time'),
            lastChecked: new Date().toISOString()
        };
    } catch (error) {
        return {
            status: 'unhealthy',
            error: error.message,
            lastChecked: new Date().toISOString()
        };
    }
};

app.get('/health/fuseki', async (req, res) => {
    const health = await checkFusekiHealth();
    res.json(health);
});

app.get('/health/prosody', async (req, res) => {
    const health = await checkProsodyHealth();
    res.json(health);
});

app.get('/', async (req, res) => {
    const [fusekiHealth, prosodyHealth] = await Promise.all([
        checkFusekiHealth(),
        checkProsodyHealth()
    ]);

    res.send(`
    <h1>Service Health</h1>
    <h2>Fuseki</h2>
    <pre>${JSON.stringify(fusekiHealth, null, 2)}</pre>
    <h2>Prosody</h2>
    <pre>${JSON.stringify(prosodyHealth, null, 2)}</pre>
  `);
});

const port = process.env.PORT || 8080;
app.listen(port, '0.0.0.0', () => console.log(`Monitor service running on port ${port}`));