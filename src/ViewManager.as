package  
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	/**
	 * ...
	 * @author jaiko
	 */
	public class ViewManager extends Sprite 
	{
		[Embed(source = "../data/8761314509_511b73cdef_o.jpg")]
		private var classImage:Class;
		//
		private var scale:Number = 1;
		private var radius:Number = 0;
		
		private var touchList:Object;
		private var center:Sprite;
		
		private var container:Sprite;
		private var bm:Bitmap;
		
		private var isTouch:Boolean = false;
		//debug
		private var tf:TextField;
		public function ViewManager() 
		{
			super();
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//
			layout();
		}
		
		private function layout():void 
		{
			var g:Graphics;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			container = new Sprite();
			addChild(container);
			
			bm = new classImage();
			container.addChild(bm);
			
		
			var sprite:Sprite = new Sprite();
			container.addChild(sprite);
			g = sprite.graphics;
			g.beginFill(0x00FFFF);
			g.drawCircle(0, 0, 15);
			container.x = stage.stageWidth * 0.5;
			container.y = stage.stageHeight * 0.5;
			bm.x = -1 * (bm.width * 0.5 );
			bm.y = -1 * (bm.height * 0.5 );

			
			//Multitouch.inputMode = MultitouchInputMode.GESTURE;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT; 
			
			
			var layer:Sprite = new Sprite();
			addChild(layer);
			center = new Sprite();
			layer.addChild(center);
			g = center.graphics;
			g.beginFill(0xFF0000 , 1);
			g.drawCircle(0, 0, 10);
			center.x = stage.stageWidth * 0.5 ;
			center.y = stage.stageHeight * 0.5;
			
			touchList = {};
			
			//container.addEventListener(TransformGestureEvent.GESTURE_ZOOM, gestureZooomEventHandler);
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
			stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler)
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			tf = new TextField();
			addChild(tf);
			tf.border = true;
			tf.background = true;
			tf.width = 300;
			tf.height = 100;
			addChild(tf);
			tf.x = 10;
			tf.y = 10;
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			var point:Point;
			var dx:Number;
			var dy:Number;
			var n:uint;
			var key:String;
			var _radius:Number;
			var value:Number = 0;
			var centerPreX:Number;
			var centerPreY:Number;
			//center 
			centerPreX = center.x;
			centerPreY = center.y;
			setCenter();
			
			//scale
			n = 0;
			for (key in touchList)
			{
				n++;
				point = touchList[key];
				value += Math.sqrt(Math.pow(center.x - point.x , 2) + Math.pow(center.y - point.y, 2));
			}
			if (n > 1 && radius >0)
			{
				_radius = value / n;
				scale *= _radius / radius;
				if (scale > 3)
				{
					scale = 3;
				}
				else if (scale < 1 / 3)
				{
					scale = 1 / 3;
				}
				radius = _radius;
				
				container.x = center.x;
				container.y = center.y;
				
				container.scaleX = scale;
				container.scaleY = scale;
			}
			//移動
			var globalPoint:Point;
			var localPoint:Point
			var globalX:Number;
			var globalY:Number;
			dx = center.x - centerPreX;
			dy = center.y - centerPreY;
			container.x += dx;
			container.y += dy;
			//移動制限
			if (   container.x + (bm.x * scale) > 0)
			{
				center.x  = -1 * (bm.x * scale);
				container.x = center.x;
			}
			else if (   container.x + ( ( bm.width + bm.x) * scale) < stage.stageWidth)
			{
				center.x = stage.stageWidth - (( bm.width + bm.x) * scale);
				container.x = center.x;
			}
			
			if (   container.y + (bm.y * scale) > 0)
			{
				center.y  = -1 * (bm.y * scale);
				container.y = center.y;
			}
			else if (   container.y + ( ( bm.height + bm.y) * scale) < stage.stageHeight)
			{
				center.y = stage.stageHeight - (( bm.height + bm.y) * scale);
				container.y = center.y;
			}
			
			
		}
		
		private function touchEndHandler(e:TouchEvent):void 
		{
			var touchID:int = e.touchPointID;
			touchList[touchID] = null;
			delete touchList[touchID];
			//
			var preX:Number = center.x;
			var preY:Number = center.y;
			setCenter();
			var dx:Number = center.x - preX;
			var dy:Number = center.y - preY;
			container.x = center.x;
			container.y = center.y;
			bm.x += -1 * dx / scale;
			bm.y += -1 * dy / scale;
			//
			//
			var key:String;
			var point:Point;
			var value:Number = 0;
			var n:uint = 0;
			for (key in touchList)
			{
				n++;
				point = touchList[key];
				value += Math.sqrt(Math.pow(center.x - point.x , 2) + Math.pow(center.y - point.y, 2));
			}
			if (n > 0)
			{
				isTouch = true;
				radius = value / n;
			}
			else
			{
				isTouch = false;
			}
			
		}
		
		private function touchBeginHandler(e:TouchEvent):void 
		{
			var touchID:int = e.touchPointID;
			touchList[touchID] = new Point(e.stageX, e.stageY);
			//
			var preX:Number = center.x;
			var preY:Number = center.y;
			setCenter();
			var dx:Number = center.x - preX;
			var dy:Number = center.y - preY;
			container.x = center.x;
			container.y = center.y;
			bm.x += -1 * dx / scale;
			bm.y += -1 * dy / scale;
			//
			var key:String;
			var point:Point;
			var value:Number = 0;
			var n:uint = 0;
			for (key in touchList)
			{
				n++;
				point = touchList[key];
				value += Math.sqrt(Math.pow(center.x - point.x , 2) + Math.pow(center.y - point.y, 2));
			}
			if (n > 0)
			{
				isTouch = true;
				radius = value / n;
			}
			else
			{
				isTouch = false;
			}

		}
		
		private function touchMoveHandler(e:TouchEvent):void 
		{
			var _radius:Number = 0;
			var touchID:int = e.touchPointID;
			touchList[touchID] = new Point(e.stageX, e.stageY);
			
		}
		
		private function setCenter():void
		{
			var key:String;
			var point:Point;
			var value:Number;
			var n:uint = 0;
			var _x:Number = 0;
			var _y:Number = 0;
			
			for (key in touchList)
			{
				n++;
				point = touchList[key];
				_x += point.x;
				_y += point.y;
				
			}
			if (n > 0)
			{
				_x *= 1 / n;
				_y *= 1 / n;
				center.x = _x;
				center.y = _y;
			}
		}
		
	}

}