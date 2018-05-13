#!/bin/sh

set -e
set -x

python3 manage.py check
python3 manage.py migrate
python3 manage.py collectstatic --noinput
python3 manage.py loaddata default_tags default_states
python3 manage.py runserver 0.0.0.0:8000
