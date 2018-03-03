Most of the services defined in ../docker-compose.yml are built using files in this dir.

* nginx reverse proxy listening on port 8080, forwarding requests to shiny-auth0 proxy
* shiny-auth0 proxy listening on port 3000, forwarding requests to shiny server 
* mysql server listening on port 3306

* secrets used by services include: `MYSQL_ROOT_PASSWORD`, `AUTH0_CLIENT_SECRET`, `AUTH0_CLIENT_ID`, `COOKIE_SECRET`. These need to be specified in secrets dir, one secret per file

* shiny server (listening on port 3838) is set up in ../shiny-server/dockerfile
