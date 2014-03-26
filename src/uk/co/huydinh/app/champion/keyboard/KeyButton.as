package uk.co.huydinh.app.champion.keyboard
{
	import com.greensock.TweenMax;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class KeyButton extends Sprite
	{
		public static const NORMAL:int = 0;
		public static const SHIFT:int = 1;
		public static const ALT:int = 2;
		
		public var normal:String;
		public var normalCode:int;
		public var shift:String;
		public var shiftCode:int;
		public var alt:String;
		public var altCode:int;
		
		protected var _code:int;
		protected var _state:int;
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _mouseDown:Boolean;
		protected var _selected:Boolean;
		
		protected var _face:Shape;
		protected var _tf:TextField;
		
		public function KeyButton(width:Number, height:Number, normal:String, normalCode:int, shift:String = null, shiftCode:int = 0, alt:String = null, altCode:int = 0)
		{
			super();
			
			_width = width;
			_height = height;
			this.normal = normal;
			this.normalCode = normalCode;
			this.shift = shift;
			this.shiftCode = shiftCode;
			this.alt = alt;
			this.altCode = altCode;
			
						
			buttonMode = true;
			mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			_face = new Shape();
			addChild(_face);
			
			var format:TextFormat = new TextFormat("StandardRegularAllCaseNoCFF", 24);
			
			_tf = new TextField();
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.embedFonts = true;
			_tf.defaultTextFormat = format;
			addChild(_tf);
			
			redraw();
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
		}
		
		protected function handleAddedToStage(event:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, handleStageMouseUp);
		}
		
		protected function handleRemovedFromStage(event:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageMouseUp);
		}
		
		public function set state(value:int):void
		{
			_state = value;
			redraw();
		}
		
		public function get char():String {return _tf.text;}
		public function get code():int { return _code };
		
		override public function set width(value:Number):void
		{
			_width = value;
			redraw();
		}
		
		override public function set height(value:Number):void
		{
			_height = value;
			redraw();
		}
		
		protected function redraw():void
		{
			if (_width && _height) {
				switch (_state) {
					case SHIFT:
						_tf.text = shift;
						_code = shiftCode;
						break;
					case ALT:
						_tf.text = alt;
						_code = altCode;
						break;
					default:
						_tf.text = normal;
						_code = normalCode;
				}
				_tf.width = _width;
				_tf.x = (_width - _tf.width) * .5;
				_tf.y = (_height - _tf.height) * .5;
				_face.graphics.clear();
				_face.graphics.beginFill(0xcccccc);
				_face.graphics.lineStyle(1, 0);
				_face.graphics.drawRoundRect(0, 0, _width, _height, 10, 10);
				_face.graphics.endFill();
			}
		}
		
		public function get selected():Boolean { return _selected };
		public function set selected(value:Boolean):void
		{
			if (_selected == value) return;
			
			_selected = value;
			if (value) {
				highlight();
			} else {
				unhighlight();
			}
		}
		
		protected function highlight():void
		{
			TweenMax.to(_face, .1, {
				tint:0x00A0F0
			});
		}
		
		protected function unhighlight():void
		{
			TweenMax.to(_face, .3, {
				removeTint:true
			});
		}
		
		protected function handleMouseDown(event:MouseEvent):void
		{
			_mouseDown = true;
			highlight();
		}
		
		protected function handleStageMouseUp(event:MouseEvent):void
		{
			if (_mouseDown && !_selected) {
				_mouseDown = false;
				unhighlight();
			}
		}
	}
}