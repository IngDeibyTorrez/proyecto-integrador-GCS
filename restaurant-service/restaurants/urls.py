from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from restaurant_service.restaurants.views import RestaurantViewSet

router = routers.DefaultRouter()
router.register(r'restaurants', RestaurantViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(router.urls)),
]
