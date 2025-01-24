# Fuseki Configuration Files

1. /config/fuseki/config.ttl
Purpose: Main Fuseki server configuration defining services and datasets
ALL

2. /config/fuseki/shiro.ini
Purpose: Authentication configuration
Relevant section:
```ini
[users]
admin=admin123

[urls]
/$/status = anon
/$/ping   = anon
/$/** = authcBasic,user[admin]
/**=anon
```

3. /docker-compose.yml
Purpose: Docker container configuration for Fuseki service
Relevant section:
```yaml
  fuseki:
    image: stain/jena-fuseki
    ports:
      - "4030:3030"
    volumes:
      - ./data/fuseki:/fuseki/databases
    environment:
      - ADMIN_PASSWORD=admin123
      - FUSEKI_DATASET_1=ds
      - FUSEKI_DATASET_2=semem
      - FUSEKI_DATASET_3=test-db
      - FUSEKI_DATASET_4=test-mem
      - JVM_ARGS=-Xmx2g
```

4. /config/nginx/nginx.conf
Purpose: Nginx reverse proxy configuration for Fuseki
Relevant section:
```nginx
    upstream fuseki_server {
        server fuseki:3030;
    }

    location /fuseki/ {
        proxy_pass http://fuseki_server/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
```

5. /config/fuseki/databases/ds.ttl
Purpose: Dataset configuration for the 'ds' dataset
ALL
