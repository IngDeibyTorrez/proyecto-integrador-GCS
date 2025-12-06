from django.urls import path
from . import views
urlpatterns = [
    path('', views.lista, name='order-list'),
    path('<int:pk>/', views.detalle, name='order-detail'),
]
