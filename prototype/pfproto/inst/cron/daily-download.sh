#!/bin/bash

cd pfproto
/usr/local/bin/Rscript -e "devtools::load_all(); dev_daily_download()"
