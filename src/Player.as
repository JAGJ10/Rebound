package {
	import starling.display.Shape;
	import flash.geom.Point;
	
	public class Player extends Shape {
		public var moveRight:Boolean;
		public var moveLeft:Boolean;
		public var grounded:Boolean;
		public var jumping:Boolean;
		public var pushDown:Boolean;
		/* Directions
		 * 0 -> floor
		 * 1 -> ceiling
		 * 2 -> right wall
		 * 3 -> left wall
		 */
		public var direction:int;
		public var radius:Number;
		public var pos:Point;
		public var velocity:Point;
		
		//Index of the current jelly island
		public var blockIndex:int;

		public function Player(x:Number, y:Number, r:Number) {
			moveRight = false;
			moveLeft = false;
			grounded = false;
			jumping = false;
			direction = 0;
			
			radius = r;
			
			blockIndex = -1;

			pos = new Point(x, y);
			velocity = new Point(0, 0);
		}
	}
}