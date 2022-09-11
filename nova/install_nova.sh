#! /bin/bash

# Logs go here, see https://github.com/dstndstn/astrometry.net/blob/abe3582fb4bd7bcd9c0b2fdfa17c1a8b38d9887f/net/wsgi.py#L22
mkdir -p /data/nova

pip install --no-cache-dir Django \
                       python-openid \
                       django-openid-auth \
                       South \
                       Pillow \
                       simplejson \
                       social-auth-core \
                       matplotlib \
                       social-auth-app-django \
                       django-social-auth3 \
                       gunicorn

# add secrets:
cp -r secrets/ /astrometry.net/net/
# install astrometry python package:
cd /astrometry.net/net

# link basic settings file:
ln -s settings_test.py settings.py

mkdir appsecrets
touch appsecrets/__init__.py
touch appsecrets/auth.py

DJANGO_SECRET=$(head /dev/urandom | sha256sum | awk '{ print $1 }')
echo "DJANGO_SECRET_KEY='${DJANGO_SECRET}'" > appsecrets/django.py

# make migrations:
python manage.py makemigrations && \
    python manage.py migrate && \
    python manage.py makemigrations net && \
    python manage.py migrate net && \
    python manage.py loaddata fixtures/initial_data.json && \
    python manage.py loaddata fixtures/flags.json

cat <<EOF >> ./settings_common.py
# Allow any:
ALLOWED_HOSTS = ['*']
EOF

#cat <<EOF >> ./urls.py
## Allow static file serving via wsgi app in Docker container:
#from django.conf.urls import patterns
#urlpatterns += patterns('',(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATICFILES_DIRS[0]}),)
#EOF

