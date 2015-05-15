package {
	import starling.display.Shape;
	import flash.geom.Point;
	
	public class Renderer extends Shape {		
		public function drawGround(blocks:Vector.<JellyBlock>):void {
			for (var i:int = 0; i < blocks.length; i++) {
				graphics.beginFill(blocks[i].color);
				graphics.lineStyle(1, blocks[i].color);
				
				var p0:Point = blocks[i].points[0].pos;
				var p1:Point = blocks[i].points[blocks[i].points.length-1].pos;
				graphics.moveTo((p0.x + p1.x) * .5, (p0.y + p1.y) * .5);
				for (var j:int = 0; j < blocks[i].points.length; j++) {
					p0 = blocks[i].points[j >= blocks[i].points.length ? j - blocks[i].points.length : j].pos;
					p1 = blocks[i].points[j + 1 >= blocks[i].points.length ? j + 1 - blocks[i].points.length : j + 1].pos;
					graphics.curveTo(p0.x, p0.y, (p0.x + p1.x) * .5, (p0.y + p1.y) * .5);
				}

				graphics.endFill();
			}
		}

		public function drawPoints(blocks:Vector.<JellyBlock>):void {
			for (var i:int = 0; i < blocks.length; i++) {
				graphics.lineStyle(1, 0x00CCFF);
				graphics.beginFill(0x00CCFF);
				for (var j:int = 0; j < blocks[i].points.length; j++) {
					graphics.drawCircle(blocks[i].points[j].pos.x, blocks[i].points[j].pos.y, 4);
				}
				graphics.endFill();
			}
		}
		
		public function drawPlayer(player:Player):void {
			graphics.lineStyle(1, 1);
			graphics.beginFill(0xffffff);
			graphics.drawCircle(player.pos.x, player.pos.y, player.radius);
			graphics.endFill();
		}
		
		public function drawGrid(state:GameState):void {
			graphics.lineStyle(1, 0xffffff);
			for (var i:Number = -(state.wScale / 2); i < 1280; i += (state.wScale)) {
				graphics.moveTo(0, i);
				graphics.lineTo(1280, i);
				graphics.moveTo(i, 0);
				graphics.lineTo(i, 768);
			}
		}
		
		public function drawQuadrants(level:int):void {
			graphics.clear();
			if (level >= 3 && level < 6) {
				graphics.lineStyle(1, 0xFF0000, 0.0);
				graphics.beginFill(0x00000, 0.5);
				graphics.drawRect(0, 0, 640, 768);
				graphics.beginFill(0xB0B0B0, 0.8);
				graphics.drawRect(640, 0, 640, 768);
			} else if (level == 6) {
				graphics.lineStyle(1, 0xFF0000, 0.0);
				graphics.beginFill(0x00000, 0.5);
				graphics.drawRect(0, 0, 426, 768);
				graphics.beginFill(0xB0B0B0, 0.8);
				graphics.drawRect(426, 0, 426, 768);
				graphics.drawRect(852, 0, 428, 384);
				graphics.beginFill(0x00000, 0.5);
				graphics.drawRect(852, 384, 428, 384);
			}
			
			graphics.lineStyle(3, 0xFF00CC);
			graphics.beginFill(1, 0);
			if (level == 1) graphics.drawCircle(660, 225, 10);
			else if (level == 2) graphics.drawCircle(1030, 480, 10);
			else if (level == 3) graphics.drawCircle(1135, 130, 10);
			else if (level == 4) graphics.drawCircle(110, 545, 10);
			else if (level == 5) graphics.drawCircle(70, 608, 10);
			else if (level == 6) graphics.drawCircle(1220, 410, 10);
		}
	}
}