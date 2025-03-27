- add key repos
- get xmpp working

---

q4: Running multiple apps:

Use PM2 process manager
Create ecosystem.config.js for app definitions
Specify different ports in app configs
Use nginx as reverse proxy if needed

q1: How do I configure PM2 for the setup?
q2: What's the best logging strategy for multiple apps?
q3: How can I monitor resource usage per app?
q4: What's the best way to handle app crashes?

I want to have various nodejs services running in the Docker container managed by PM2. The services will be installed using `projects/setup-repos.sh`. Please take a look in the project knowledge for the current configuration, and advise me on how to set up PM2 in this environment. Would some kind of `ecosystem.config.js` be useful?
