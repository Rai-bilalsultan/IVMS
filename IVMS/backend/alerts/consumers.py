from channels.generic.websocket import AsyncWebsocketConsumer
import json

class AlertConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        user_id = self.scope['url_route']['kwargs'].get('user_id')
        self.group_name = f"alerts_{user_id}" if user_id else "alerts_admin"

        # Join group
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        # Leave group
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    # Receive alert from group
    async def send_alert(self, event):
        await self.send(text_data=json.dumps(event['alert']))
