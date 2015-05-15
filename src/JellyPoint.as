package {
	import flash.geom.Point;

	public class JellyPoint {
		public var pos:Point;
		public var initialPos:Point;
		public var velocity:Point;
		public var neighbors:Array;
		public var acrossNeighbors:Array;
		
		public var index:int;
		
		private static var decay:Number = 0.97;
		private var anchorPower:Number = 0.1;
		private static var pull:Number = 0.25;
		
		public function JellyPoint(x:Number, y:Number, index:int) {
			this.pos = new Point(x, y);
			this.initialPos = new Point(x, y);
			this.velocity = new Point(0, 0);
			this.neighbors = [];
			this.acrossNeighbors = [];
			this.index = index;
		}
		
		public function addNeighbor(n:JellyPoint, d:int):void {
			neighbors.push(new Neighbor(n, d));
		}
		
		public function addAcross(n:JellyPoint):void {
			acrossNeighbors.push(n);
		}
		
		public function setAnchorPower():void {
			if (acrossNeighbors.length == 0) {
				anchorPower = 0.045;
			}
		}
		
		public function update():void {
			if (velocity.y > 25) velocity.y = 25;
			if (velocity.y < -25) velocity.y = -25;
			if (velocity.x > 25) velocity.x = 25;
			if (velocity.x < -25) velocity.x = -25;
			
			velocity.x *= decay;
			velocity.y *= decay;
			
			velocity.x -= (pos.x - initialPos.x) * anchorPower;
			velocity.y -= (pos.y - initialPos.y) * anchorPower;
			
			var xd:Number, yd:Number, d:Number;
			for (var i:int = 0; i < neighbors.length; i++) {
				xd = neighbors[i].jp.pos.x - pos.x;
				yd = neighbors[i].jp.pos.y - pos.y;
				d = xd * xd + yd * yd;
				if (d > 1000) {
					d = Math.sqrt(d);
					velocity.x += pull * xd / d;
					velocity.y += pull * yd / d;
					neighbors[i].jp.velocity.x -= pull * xd / d;
					neighbors[i].jp.velocity.y -= pull * yd / d;
				}
			}
			
			pos.x += velocity.x;
			pos.y += velocity.y;
			
			for (i = 0; i < acrossNeighbors.length; i++) {
				if (int(acrossNeighbors[i].initialPos.x) == int(initialPos.x)) {
					if (initialPos.y > acrossNeighbors[i].initialPos.y) {
						if (pos.y < acrossNeighbors[i].pos.y + 10) {
							velocity.y = 0;
							pos.y = acrossNeighbors[i].pos.y + 10;
						}
					} else {
						if (pos.y > acrossNeighbors[i].pos.y - 10) {
							velocity.y = 0;
							pos.y = acrossNeighbors[i].pos.y - 10;
						}
					}
				} else {
					if (initialPos.x > acrossNeighbors[i].initialPos.x) {
						if (pos.x < acrossNeighbors[i].pos.x + 10) {
							velocity.x = 0;
							pos.x = acrossNeighbors[i].pos.x + 10;
						}
					} else {
						if (pos.x > acrossNeighbors[i].pos.x - 10) {
							velocity.x = 0;
							pos.x = acrossNeighbors[i].pos.x - 10;
						}
					}
				}
			}
		}
	}
}