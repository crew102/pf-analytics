#!/bin/bash

# secrets that are stored as env vars on travis
secrets=(MYSQL_ROOT_PASSWORD AUTH0_CLIENT_SECRET AUTH0_CLIENT_ID COOKIE_SECRET \
PF_KEY RSTUDIO_CBAKER_PASSWORD)

for i in ${secrets[*]}
do
val=$(eval echo "$""${i}")
echo $val > `pwd`/secrets/"$i"
done
