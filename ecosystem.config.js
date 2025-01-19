module.exports = {
    apps: [
        {
            name: 'app',
            script: './repositories/app/src/app.js',
            instances: 1,
            autorestart: true,
            watch: false,
            env: {
                NODE_ENV: 'production',
                PORT: 8311
            }
        },
        {
            name: 'monitor',
            script: './repositories/monitor/src/index.js',
            instances: 1,
            autorestart: true,
            watch: false,
            env: {
                NODE_ENV: 'production',
                PORT: 8080
            }
        }
    ]
};