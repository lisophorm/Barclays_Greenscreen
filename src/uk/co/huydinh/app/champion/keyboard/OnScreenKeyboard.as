package uk.co.huydinh.app.champion.keyboard
{
	import com.greensock.TweenMax;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.ui.Keyboard;
	
	import spark.components.TextInput;
	

	

	public class OnScreenKeyboard extends Sprite
	{
		protected static const PADDING:int = 20;
		protected static const CORNER:int = 30;
		
		public var horizontalGap:Number = 3;
		public var verticalGap:Number = 3;
		
		protected var _width:Number = 820;
		protected var _keys:Object = {};
		protected var _keyWidth:Number = 50;
		protected var _caps:Boolean;
		protected var _shift:Boolean;
		protected var _alt:Boolean;
		
		protected var _focus:InteractiveObject;
		public function get focus():InteractiveObject { return _focus };
		public function set focus(value:InteractiveObject):void
		{
			if (value is TextInput) {
				var tlf:TextInput = value as TextInput;
				var len:int = tlf.text.length;
				tlf.selectRange(len, len);
				tlf.setFocus();
				trace("selected:"+tlf.id);
				//tlf.setSelection(len, len);
				//tlf.textFlow.interactionManager.setFocus();
				_focus = value;
			} else {
				stage.focus = null;
				_focus = null;
			}
		};
		
		public function OnScreenKeyboard()
		{
			super();
			
			/*var fonts : Array = Font.enumerateFonts();
			for each(var f : Font in fonts)
			{
				trace("Font :: " + f + " :: " + f.fontName);
			}*/
		}
		
		public function set keyData(value:XML):void {
			var yPos:Number = PADDING;
			for each (var row:XML in value.row) {
				var xPos:Number = PADDING;
				var keys:Array = [];
				var totalWidth:Number = 0;
				var numFixedWidth:int = 0;
				for each (var key:XML in row.key) {
					var code:int = int(key.@code.toString());
					var width:Number = Number(key.@width.toString()) * _keyWidth;
					if (width) {
						numFixedWidth++;
					}
					keys.push({code:code, width:width, char:key.toString()});
					totalWidth += width;
					
				}
				var remainingWidth:Number = _width - (totalWidth + (horizontalGap * (numFixedWidth + 1)));
				var w:Number = remainingWidth / (keys.length - numFixedWidth);
				for each (var k:Object in keys) {
					var char:String;
					var shift:String;
					var alt:String;
					switch (k.code) {
						case -1:
						case Keyboard.ALTERNATE:
						case Keyboard.BACKSPACE:
						case Keyboard.ENTER:
						case Keyboard.SHIFT:
						case Keyboard.TAB:
						case Keyboard.CAPS_LOCK:
						case Keyboard.SPACE:
							char = k.char;
							shift = k.char;
							alt = k.char;
							break;
						default:
							char = k.char.charAt(0);
							if (k.char.length > 1) {
								shift = k.char.charAt(1);
								if (k.char.length > 2) {
									alt = k.char.charAt(2);
								}
							}
							if(k.char.length==1)
							{
								shift = k.char.charAt(0);
								alt = k.char.charAt(0);
							}
					}
					var btn:KeyButton = new KeyButton(k.width ? k.width : w, 35, char, k.code, shift, k.code, alt, k.code);
					if (k.code) {
						btn.addEventListener(MouseEvent.CLICK, handleKeyClick);
					} else {
						btn.visible = false;
					}
					btn.x = xPos;
					btn.y = yPos;
					addChild(btn);
					_keys[k.code] = btn;
					xPos += btn.width + horizontalGap;
				}
				yPos += btn.height + verticalGap;
			}
			
			graphics.clear();
			graphics.beginFill(0xffffff);
			graphics.lineStyle(5);
			graphics.drawRoundRect(0, 0, _width + PADDING + PADDING + PADDING, height + PADDING + PADDING, CORNER);
			graphics.endFill();
		}
		
		protected function handleKeyClick(event:MouseEvent):void
		{
			var char:String = "";
			var tlf:TextInput;
			var text:String;
			var cursorPos:int;
			switch (event.target.code) {
				case -1:
					hide();
					return;
				case Keyboard.BACKSPACE:
					if (focus) {
						if (focus is TextInput) {
							tlf = focus as TextInput;
							text = tlf.text;
							cursorPos = tlf.selectionAnchorPosition - 1;
							tlf.text = text.substring(0, cursorPos) + text.substring(tlf.selectionActivePosition);
							tlf.selectRange(cursorPos, cursorPos);
							tlf.setFocus();
						}
					}
					return;
				case Keyboard.TAB:
					break;
				case Keyboard.ENTER:
					break;
				case Keyboard.SHIFT:
					_shift = !_shift;
					_keys[Keyboard.SHIFT].selected = _shift;
					toggleCaps();
					break;
				case Keyboard.ALTERNATE:
					break;
				case Keyboard.CAPS_LOCK:
					if (_shift) {
						_shift = false;
						_keys[Keyboard.SHIFT].selected = false;
						_keys[Keyboard.CAPS_LOCK].selected = true;
					} else {
						toggleCaps();
						_keys[Keyboard.CAPS_LOCK].selected = _caps;
					}
					break;
				case 32:
					char = " ";
					break;
				default:
					char = _caps ? event.target.shift : event.target.char;
					if (_shift) {
						_shift = false;
						_keys[Keyboard.SHIFT].selected = false;
						toggleCaps();
					}
			}
			
			if (focus) {
				if (focus is TextInput) {
					trace("dispatching event");
					tlf = focus as TextInput;
					
					var e:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, 42);
					tlf.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,char.charCodeAt(0)));
					/*trace("current position:"+tlf.selectionActivePosition);
					
					text = tlf.text;
					cursorPos = tlf.selectionActivePosition + 1;
					trace("cursorpos:"+cursorPos);
					tlf.text = text.substring(0, tlf.selectionActivePosition) + char + text.substring(tlf.selectionActivePosition);*/
					//tlf.selectRange(cursorPos, cursorPos);
					//tlf.textFlow.interactionManager.setFocus();
				}
			}
		}
		
		protected function toggleCaps():void
		{
			_caps = !_caps;
			
			var state:int = _caps ? KeyButton.SHIFT : KeyButton.NORMAL;
			for each (var btn:KeyButton in _keys) {
				btn.state = state;
			}
		}
		
		
		
		/**
		 * Shows the keyboard
		 */
		public function show():void
		{
			
			var o:Object = {autoAlpha:1};
			if (focus) {
				var p:Point = parent.globalToLocal(focus.parent.localToGlobal(new Point(focus.x, focus.y)));
				o.x = (stage.width - width) * .5;
				//
				o.y = (p.y-height ) - 60;
			}
			TweenMax.to(this, .5, o);
			
		}
		
		
		/**
		 * Hides the keyboard
		 */
		public function hide():void
		{
			TweenMax.to(this, .5, {
				autoAlpha:0
			});
		}

	}
}