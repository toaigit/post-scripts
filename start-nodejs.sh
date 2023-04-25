#!/bin/bash

cd /var/www/ExpressJS
# start simple node app w/o express
#node app.js

# start node app with express
nohup node express-app.js > /var/log/nodejs.log 2>&1 &
