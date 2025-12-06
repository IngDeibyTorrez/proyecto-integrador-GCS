from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = 'changeme'
DEBUG = True
ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.staticfiles',
    'order',
]

MIDDLEWARE = [
    'django.middleware.common.CommonMiddleware',
]

ROOT_URLCONF = 'service_template.urls'
STATIC_URL = '/static/'
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('POSTGRES_DB','deliverydb_bo'),
        'USER': os.environ.get('POSTGRES_USER','postgres'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD','sistemas'),
        'HOST': os.environ.get('POSTGRES_HOST','localhost'),
        'PORT': os.environ.get('POSTGRES_PORT','5432'),
    }
}
