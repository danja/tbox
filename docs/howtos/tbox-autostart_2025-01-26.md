# TBox Autostart Guide

## Setup Steps

1. Create systemd service file:

```bash
sudo nano /etc/systemd/system/tbox.service
```

Add the following content:

```ini
[Unit]
Description=TBox Docker Environment
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/path/to/your/tbox
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

2. Enable and start the service:

```bash
sudo systemctl enable tbox.service
sudo systemctl start tbox.service
```

## Managing Updates

When you need to rebuild the container:

1. Stop the service:
```bash
sudo systemctl stop tbox.service
```

2. Make your changes to the tbox configuration

3. Rebuild and restart:
```bash
cd /path/to/your/tbox
docker compose build --no-cache
sudo systemctl start tbox.service
```

## Monitoring

Check service status:
```bash
sudo systemctl status tbox.service
```

View logs:
```bash
journalctl -u tbox.service
```

## Troubleshooting

If the service fails to start:
1. Check logs using journalctl
2. Verify Docker service is running
3. Ensure correct working directory path in service file
4. Check file permissions in tbox directory