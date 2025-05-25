#!/bin/bash
echo "Restarting Docker services..."
docker-compose down
docker-compose up -d
echo "Services restarted. Now run the dogbot script."
echo "Use: docker exec -it tbox-ssh-server-1 bash -c 'cd /home/projects/tia/dogbot && ./start-dogbot.sh'"