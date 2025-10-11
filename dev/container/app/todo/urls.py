from django.urls import path
from . import views

app_name = 'todo'

urlpatterns = [
    path('', views.index, name='index'),
    path('create/', views.create, name='create'),
    path('toggle/<int:todo_id>/', views.toggle, name='toggle'),
    path('delete/<int:todo_id>/', views.delete, name='delete'),
    path('api/list/', views.api_list, name='api_list'),
]
