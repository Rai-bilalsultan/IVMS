from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/alerts/admin/$', consumers.AlertConsumer.as_asgi()),
    re_path(r'ws/alerts/(?P<user_id>\d+)/$', consumers.AlertConsumer.as_asgi()),
]
