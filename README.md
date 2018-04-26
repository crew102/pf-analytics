pf-analytics
================

> A pet adoption analytics app based on pet finder data

[![Linux Build Status](https://travis-ci.org/crew102/pf-analytics.svg?branch=master)](https://travis-ci.org/crew102/pf-analytics)

* services defined in docker-compose.yml:

1. nginx reverse proxy
    * listens on port 8080, forwards requests to shiny-auth0 proxy
    * nginx image
2. shiny-auth0 proxy 
    * listens on 3000, forwards requests to shiny server
    * dockerfile that sets up customized version of shiny-auth0
    * requires .env file (described in https://github.com/crew102/shiny-auth0-plus) at services/shiny-auth0/.env
3. shiny server 
    * listens on 3838
    * dockerfile that installs rstudio server on top of rocker/tidyverse, sets server config, and installs app code. deploys server at run-time.
4. rstudio server
    * listens on 8780
    * dockerfile that installs prototype code. starts cron and deploys rstudio server (for interactive dev) at run-time.
5. mysql server 
    * listens on 3306
    * mysql image

* secrets used by services include: `MYSQL_ROOT_PASSWORD`, `AUTH0_CLIENT_SECRET`, `AUTH0_CLIENT_ID`, `COOKIE_SECRET`, `PF_KEY`, and `RSTUDIO_CBAKER_PASSWORD`. These need to be specified in services/secrets/ dir, one secret per file.