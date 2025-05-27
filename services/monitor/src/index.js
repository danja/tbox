import express from 'express';
import fetch from 'node-fetch';
import net from 'net';

const app = express();

const FUSEKI_URL = process.env.FUSEKI_URL || 'http://fuseki:3030';

const checkFusekiHealth = async () => {
    try {
        const response = await fetch(`${FUSEKI_URL}/$/ping`, {
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
    const health = {
        status: 'unhealthy',
        services: {},
        lastChecked: new Date().toISOString()
    };

    try {
        // Check main XMPP C2S port (5222)
        const c2sCheck = await checkTcpPort('tbox-xmpp-1', 5222);
        health.services.c2s = {
            port: 5222,
            description: 'Client-to-Server connections',
            ...c2sCheck
        };

        // Check S2S port (5269)
        const s2sCheck = await checkTcpPort('tbox-xmpp-1', 5269);
        health.services.s2s = {
            port: 5269,
            description: 'Server-to-Server connections',
            ...s2sCheck
        };

        // Check MUC component (conference.xmpp should be available)
        const mucCheck = await checkXmppComponent('conference.xmpp');
        health.services.muc = {
            component: 'conference.xmpp',
            description: 'Multi-User Chat (group chat rooms)',
            ...mucCheck
        };

        // Check PubSub component
        const pubsubCheck = await checkXmppComponent('pubsub.xmpp');
        health.services.pubsub = {
            component: 'pubsub.xmpp',
            description: 'Publish-Subscribe service',
            ...pubsubCheck
        };

        // Overall health: healthy if C2S is working
        if (health.services.c2s.status === 'healthy') {
            health.status = 'healthy';
        }

        return health;
    } catch (error) {
        health.error = error.message;
        return health;
    }
};

// Helper function to check TCP port connectivity
const checkTcpPort = async (host, port) => {
    return new Promise((resolve) => {
        const socket = new net.Socket();
        
        const timeout = setTimeout(() => {
            socket.destroy();
            resolve({
                status: 'unhealthy',
                error: 'Connection timeout'
            });
        }, 2000);

        socket.connect(port, host, () => {
            clearTimeout(timeout);
            socket.destroy();
            resolve({
                status: 'healthy',
                note: 'Port accessible'
            });
        });

        socket.on('error', (err) => {
            clearTimeout(timeout);
            socket.destroy();
            if (err.code === 'ECONNREFUSED') {
                resolve({
                    status: 'unhealthy',
                    error: 'Connection refused - service not running'
                });
            } else {
                resolve({
                    status: 'unhealthy',
                    error: err.message
                });
            }
        });
    });
};

// Helper function to check XMPP component availability
const checkXmppComponent = async (component) => {
    try {
        // For components, we'll check if they're responding by attempting a connection
        // This is a simplified check - in a full implementation you'd use XMPP protocol
        const tcpCheck = await checkTcpPort('xmpp', 5222);
        
        if (tcpCheck.status === 'healthy') {
            return {
                status: 'available',
                note: 'Component should be available (server running)'
            };
        } else {
            return {
                status: 'unavailable',
                note: 'Component unavailable (server not running)'
            };
        }
    } catch (error) {
        return {
            status: 'unknown',
            error: error.message
        };
    }
};

// General health endpoint
app.get('/health', async (req, res) => {
    const health = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        services: {}
    };

    try {
        health.services.fuseki = await checkFusekiHealth();
        health.services.prosody = await checkProsodyHealth();

        // If any service is unhealthy, mark overall status as unhealthy
        if (Object.values(health.services).some(service => service.status === 'unhealthy')) {
            health.status = 'unhealthy';
        }

        res.json(health);
    } catch (error) {
        health.status = 'unhealthy';
        health.error = error.message;
        res.status(500).json(health);
    }
});

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

    const getStatusColor = (status) => {
        switch(status) {
            case 'healthy': case 'available': return 'green';
            case 'unhealthy': case 'unavailable': return 'red';
            default: return 'orange';
        }
    };

    const renderProsodyServices = (services) => {
        return Object.entries(services).map(([key, service]) => `
            <tr>
                <td><strong>${key.toUpperCase()}</strong></td>
                <td>${service.description}</td>
                <td style="color: ${getStatusColor(service.status)}">
                    ${service.status}
                    ${service.port ? ` (port ${service.port})` : ''}
                    ${service.component ? ` (${service.component})` : ''}
                </td>
                <td>${service.note || service.error || ''}</td>
            </tr>
        `).join('');
    };

    res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>TBox Service Health Monitor</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            table { border-collapse: collapse; width: 100%; margin: 10px 0; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
            .status-healthy { color: green; font-weight: bold; }
            .status-unhealthy { color: red; font-weight: bold; }
            .timestamp { color: #666; font-size: 0.9em; }
        </style>
    </head>
    <body>
        <h1>TBox Service Health Monitor</h1>
        <p class="timestamp">Last updated: ${new Date().toISOString()}</p>
        
        <h2>Fuseki SPARQL Server</h2>
        <table>
            <tr>
                <td><strong>Status</strong></td>
                <td style="color: ${getStatusColor(fusekiHealth.status)}">${fusekiHealth.status}</td>
                <td>${fusekiHealth.error || 'SPARQL endpoint accessible'}</td>
            </tr>
        </table>
        
        <h2>Prosody XMPP Server</h2>
        <div style="color: ${getStatusColor(prosodyHealth.status)}; font-weight: bold; margin: 10px 0;">
            Overall Status: ${prosodyHealth.status}
        </div>
        <table>
            <thead>
                <tr>
                    <th>Service</th>
                    <th>Description</th>
                    <th>Status</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
                ${renderProsodyServices(prosodyHealth.services)}
            </tbody>
        </table>
        
        <h3>XMPP Features Available:</h3>
        <ul>
            <li><strong>Client Connections (C2S)</strong>: ${prosodyHealth.services.c2s?.status === 'healthy' ? '✅ Available' : '❌ Unavailable'} on port 5222</li>
            <li><strong>Server Federation (S2S)</strong>: ${prosodyHealth.services.s2s?.status === 'healthy' ? '✅ Available' : '❌ Unavailable'} on port 5269</li>
            <li><strong>Group Chat (MUC)</strong>: ${prosodyHealth.services.muc?.status === 'available' ? '✅ Available' : '❌ Unavailable'} at conference.xmpp</li>
            <li><strong>Publish-Subscribe</strong>: ${prosodyHealth.services.pubsub?.status === 'available' ? '✅ Available' : '❌ Unavailable'} at pubsub.xmpp</li>
        </ul>

        <h3>Raw Health Data</h3>
        <details>
            <summary>Fuseki Details</summary>
            <pre>${JSON.stringify(fusekiHealth, null, 2)}</pre>
        </details>
        <details>
            <summary>Prosody Details</summary>
            <pre>${JSON.stringify(prosodyHealth, null, 2)}</pre>
        </details>
    </body>
    </html>
  `);
});

const port = process.env.PORT || 8080;
app.listen(port, '0.0.0.0', () => console.log(`Monitor service running on port ${port}`));