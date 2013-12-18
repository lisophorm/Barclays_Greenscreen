package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import events.RegistrationEvent;

	public class Registration extends EventDispatcher
	{
		import be.aboutme.airserver.AIRServer;
		import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
		import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;
		import be.aboutme.airserver.events.AIRServerEvent;
		import be.aboutme.airserver.events.MessageReceivedEvent;
		import be.aboutme.airserver.messages.Message;
		import by.blooddy.crypto.serialization.JSON;
		
		import com.utils.Console;
		
		private var server:AIRServer;
		private var msg:String ="";
		
		public function Registration()
		{
			
		}
		
		public function startSocket():void
		{	
			
			if (server==null)
			{
				server = new AIRServer();
				server.addEndPoint(new SocketEndPoint(1235, new WebSocketClientHandlerFactory()));
				server.addEventListener(AIRServerEvent.CLIENT_ADDED, this.clientAddedHandler, false, 0, true);
				server.addEventListener(AIRServerEvent.CLIENT_REMOVED, this.clientRemovedHandler, false, 0, true);
				server.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, this.messageReceivedHandler, false, 0, true);
				
			}
			//start the server
			try {
				Console.log("startSocket "+server, this);
				server.start();
						
			} catch (e:Error)
			{
				
				this.dispatchEvent( new RegistrationEvent( RegistrationEvent.ERROR, -1, e.message  ) );
			}
		}
		
		private function clientAddedHandler(event:AIRServerEvent):void
		{
			Console.log("Client added: " + event.client.id + "\n", this);
			delayedIdleSocket();
		}
		
		private function clientRemovedHandler(event:AIRServerEvent):void
		{
			Console.log("Client removed: " + event.client.id + "\n", this);
		}
		
		public function stopSocket(e:Event = null):void
		{
			if (server!=null)
				server.stop();
		}
		public function registerUser( uid:String ):void
		{
			this.sendMessage( 'register '+uid );
		}
		protected function idleSocket():void
		{
			var idMsg:Message = identifyMessage;
			Console.log("sending message "+idMsg.data, this)
			
			server.sendMessageToAllClients(idMsg);
		}
		
		protected function get identifyMessage():Message
		{
			var m:Message = new Message();
			m.data = 'identify';// {'command': 'MESSAGE', 'data': 'identify'};
			return m;
		}
		public function sendMessage(msg:String):void
		{
			var message:Message=new Message();
			message.data=msg;
			Console.log("sending message: "+message.data, this);
			server.sendMessageToAllClients(message);
		}
			
		
		protected function delayedIdleSocket():void
		{
			var t:Timer = new Timer(1000);
			t.addEventListener(TimerEvent.TIMER, this.startIdleSocket);
			t.start();
		}
		protected function startIdleSocket( e:TimerEvent ):void
		{
			
			var t:Timer = Timer(e.target);
			t.removeEventListener(TimerEvent.TIMER, startIdleSocket);
			t.stop();
			t = null;				
			this.idleSocket();
		}
		
	
		protected function handleCode( data:Object=null ):void
		{
			if (data!=null)
			{
				Console.log( data["code"],this);
				switch ( data["code"] )
				{
					case 101: 
						//- Place finger on scanner
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_STEP_1, -1, data["msg"]  ) );
					break;
					case 102:
						//- Lift finger and place a second time
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_STEP_2, -1, data["msg"]  ) );
					break;
					case 103:
						//- Lift finger and place a last time
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_STEP_3, -1, data["msg"]  ) );
					break;
					case 104:
						//- Scan successful
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_COMPLETED, -1, data["msg"]  ) );
					break;
					case 105:
						//- Low quality scan - try again
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_AGAIN, -1, data["msg"]  ) );
					break;
					case 106:
						//- Error
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.ERROR, -1, data["msg"]  ) );
					break;
					case 107:
						//- Error - start all three scan again
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_RESTART, -1, data["msg"]  ) );
					break;
					case 108:
						// Send 'cancel' to reset.
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_CANCELLED, -1, data["msg"]  ) );
					break;
					case 201:
						//- Registration successful
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.USER_REGISTERED, data["msg"]  ) );
					break;
					case 202:
						//- Registration Error
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.ERROR, -1, data["msg"]  ) );
					break;
					case 203:
						//- Customer is already in the DB
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.USER_ALREADY_REGISTERED, data["msg"]  ) );
	
					break;
					case 301:
						//- Identify Scan finger
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.SCAN_READY, -1, data["msg"]  ) );
					break;
					case 302:
						//- (Success, returns user ID)
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.USER_FOUND, -1, data["msg"]  ) );
					break;
					case 303 :
						//- Customer not found
						
						this.dispatchEvent( new RegistrationEvent( RegistrationEvent.USER_NOT_FOUND, data["msg"] ) );
					break;
				}
			}
		}
		private function messageReceivedHandler(event:MessageReceivedEvent):void
		{
			
			try {
				var dataOut:Object = by.blooddy.crypto.serialization.JSON.decode(event.message.data.toString());
				for (var m:String in dataOut)
				{
					Console.log(m+": "+dataOut[m], this);
				}
				handleCode( dataOut )
				//
			} catch (e:Error)
			{
				Console.log("Error: "+e.message, this)
			}
			
			
			
			Console.log(event.message.data, this);
			
			/*
			//outputArea.appendText("<client" + event.message.senderId + "> " + event.message.data + "\n");
			//trace("<client" + event.message.senderId + "> " + event.message.data + "\n");
			switch(event.message.command)
			{
				case "PORT":
				case "ADDR":
					//don't forward PORT or ADDR commands from UDP
					break;
				default:
					//forward the message to all connected clients
					server.sendMessageToAllClients(event.message);
			}*/
		}
	}
}