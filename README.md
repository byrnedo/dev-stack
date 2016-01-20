# dev-stack
[Capitan](https://github.com/byrnedo/capitan) stack for microservices

- Consul - Service Discovery
    - Dns on 172.17.0.1 (docker bridge). This can be configured to work for dns on ubuntu host by editing /etc/dchp/dhcclient.conf
    
    prepend domain-name-servers 172.17.0.1;

- Registrator - Service Registration
- Mongo - Database
- Redis - Cache/storage
- NATS - Message queue
- Tyk - Api Gateway
- Tyk Dashboard - Frontend for tyk gateway
