#!/bin/bash

# start python flask
cd /var/www/FlaskApp
source env/test/bin/activate
python app.py > flaskapp.log 2>&1 &

# end of python installation
