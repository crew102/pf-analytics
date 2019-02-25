pf-analytics
================

> A pet adoption analytics app based on pet finder data

[![Linux Build Status](https://travis-ci.org/crew102/pf-analytics.svg?branch=master)](https://travis-ci.org/crew102/pf-analytics)

* services defined in docker-compose.yml:

1. shiny server 
    * listens on 3838
    * dockerfile that installs rstudio server on top of rocker/tidyverse, sets server config, and installs app code. deploys server at run-time.
2. rstudio server
    * listens on 8780
    * dockerfile that installs prototype code. starts cron and deploys rstudio server (for interactive dev) at run-time.
3. mysql server 
    * listens on 3306
    * mysql image

* secrets used by services include: `MYSQL_ROOT_PASSWORD`, `AUTH0_CLIENT_SECRET`, `AUTH0_CLIENT_ID`, `COOKIE_SECRET`, `PF_KEY`, and `RSTUDIO_CBAKER_PASSWORD`. These need to be specified in secrets dir, one secret per file.
