package {
	import flash.geom.Point;
	import starling.display.Shape;
	
	public class JellyBlock extends Shape {
		private static var MAX_DIST:int = 500;
		
		public var points:Vector.<JellyPoint>;
		public var boundingBox:Array;
		public var color:uint;

		public function JellyBlock(pointsIn:Array) {
			//Set random color
			color = Math.random() * 0xffffff;
			
			var i:int = 0;
			var j:int = 0;

			this.points = new Vector.<JellyPoint>();
			for (i = 0; i < pointsIn.length; i++) {
				points.push(new JellyPoint(pointsIn[i].x, pointsIn[i].y, i));
			}
			
			var clockwise:Boolean = signedArea(pointsIn);

			var length:Number = points.length;
			
			if (clockwise) {
				points[0].addNeighbor(points[length - 1], 1);
				points[0].addNeighbor(points[1], 0);
			
				points[length - 1].addNeighbor(this.points[0], 0);
				points[length - 1].addNeighbor(this.points[length - 2], 1);
			} else {
				points[0].addNeighbor(points[length - 1], 0);
				points[0].addNeighbor(points[1], 1);
			
				points[length - 1].addNeighbor(this.points[0], 1);
				points[length - 1].addNeighbor(this.points[length - 2], 0);
			}
			
			for (j = 1; j < length - 1; j++) {
				var jp:JellyPoint = points[j];
				if (clockwise) {
					jp.addNeighbor(points[j - 1], 1);
					jp.addNeighbor(points[j + 1], 0);
				} else {
					jp.addNeighbor(points[j - 1], 0);
					jp.addNeighbor(points[j + 1], 1);
				}
			}
			
			for (i = 0; i < length; i++) {
				jp = points[i];
				for (j = 0; j < length; j++) {
					if (i != j) {
						var dist:Number = Point.distance(jp.initialPos, points[j].initialPos);
						if (dist < MAX_DIST && (int(jp.initialPos.x) == int(points[j].initialPos.x) || int(jp.initialPos.y) == int(points[j].initialPos.y))) {
							jp.addAcross(points[j]);
						}
					}
				}
			}
			
			for (i = 0; i < length; i++) {
				jp = points[i];
				jp.setAnchorPower();
			}
			
			//get bounding box around entire jelly block
			var temp:Array = [];
			boundingBox = [];
			temp.push(pointsIn[0].x, pointsIn[0].x, pointsIn[0].y, pointsIn[0].y);
			for (var k:int = 1; k < points.length; k++) {
				if (pointsIn[k].x < temp[0]) temp[0] = pointsIn[k].x;
				if (pointsIn[k].x > temp[1]) temp[1] = pointsIn[k].x;
				if (pointsIn[k].y < temp[2]) temp[2] = pointsIn[k].y;
				if (pointsIn[k].y > temp[3]) temp[3] = pointsIn[k].y;
			}
			
			boundingBox.push(new Point(temp[0] - 30, temp[2] - 30), new Point(temp[1] + 30, temp[2] - 30), new Point(temp[1] + 30, temp[3] + 30), new Point(temp[0] - 30, temp[3] + 30));
		}
		
		public function signedArea(pointsIn:Array):Boolean {
			var signedArea:int = 0;
			for (var i:int = 0; i < pointsIn.length - 1; i++) {
				var p1:Point = pointsIn[i];
				var p2:Point = pointsIn[i + 1];
				signedArea += ((p1.x * p2.y) - (p2.x * p1.y));
			}
			
			if (signedArea < 0) return true;
			else return false;
		}
	}
}