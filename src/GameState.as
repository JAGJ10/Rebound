package {
	import flash.automation.KeyboardAutomationAction;
	import starling.core.Starling;
	import starling.display.*;
	import starling.events.EnterFrameEvent;
	import starling.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class GameState extends Sprite {
		private var controller:InputController;
		public var player:Player;
		private var renderer:Renderer;
		public var editor:Editor;
		public var blocks:Vector.<JellyBlock>;
		public var curLevel:int;
		public var startSpots:Array;
		public var goals:Array;
		private var reverse:Boolean;

		private static var gravity:Number = 1;
		
		public var wScale:Number = 1280 / 40;
		public var hScale:Number = 1280 / 40;
		public var maxDist:Number = wScale / 5;
		
		public var gridEnabled:Boolean = false;
		public var pointsEnabled:Boolean = false;
		
		public function GameState() {
			goals = new Array(new Point(660, 225), new Point(1030, 480), new Point(1135, 130), new Point(110, 545), new Point(70, 608), new Point(1220, 410));
			startSpots = new Array(new Point(350, 0), new Point(200, 0), new Point(250, 0), new Point(1100, 768), new Point(1100, 768), new Point(75, 0));
			controller = new InputController(this);
			player = new Player(350, 0, 10);
			renderer = new Renderer();
			blocks = new Vector.<JellyBlock>();
			editor = new Editor(this);
			reverse = false;
			
			addChild(renderer);
			editor.loadLevel(1);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			addEventListener(KeyboardEvent.KEY_DOWN, controller.keyDown);
			addEventListener(KeyboardEvent.KEY_UP, controller.keyUp);
			addEventListener(TouchEvent.TOUCH, editor.mouseClick);
		}
		
		public function update(e:EnterFrameEvent):void {
			renderer.drawQuadrants(curLevel);
			renderer.drawGround(blocks);
			if (pointsEnabled) renderer.drawPoints(blocks);
			renderer.drawPlayer(player);
			if (gridEnabled) renderer.drawGrid(this);
			
			if (editor.editorMode == false) {
				checkCollisions();
				updatePhysics();
				victoryCheck();
			}
		}
		
		public function checkCollisions():void {
			if (!player.grounded) {
				for (var i:int = 0; i < blocks.length; i++) {
					if (withinBoundingBox(player.pos, blocks[i])) {
						if (pointInPolygon(player.pos, blocks[i])) {
							player.grounded = true;
							player.blockIndex = i;
							return;
						} else {
							player.grounded = false;
							player.blockIndex = -1;
						}
						
					} else {
						player.grounded = false;
						player.blockIndex = -1;
					}
				}
			}
		}
		
		public function withinBoundingBox(p:Point, block:JellyBlock):Boolean {
			if (p.x >= block.boundingBox[0].x && p.x <= block.boundingBox[1].x && p.y >= block.boundingBox[0].y && p.y <= block.boundingBox[3].y) {
				return true;
			}
			
			return false;
		}
		
		public function pointInPolygon(p:Point, block:JellyBlock):Boolean {
			var i:int, j:int, c:Boolean = false;
			for (i = 0, j = block.points.length - 1; i < block.points.length; j = i++) {
				if (((block.points[i].pos.y >= p.y) != (block.points[j].pos.y >= p.y)) && (p.x <= (block.points[j].pos.x - block.points[i].pos.x) * (p.y - block.points[i].pos.y) / (block.points[j].pos.y - block.points[i].pos.y) + block.points[i].pos.x)) {
					c = !c;
				}
			}
			
			return c;
		}
		
		public function updatePhysics():void {
			//Update player velocity if not touching jelly
			if (!player.grounded) {
				if (reverse && player.moveRight) player.velocity.x -= 1;
				if (reverse && player.moveLeft) player.velocity.x += 1;
				if (!reverse && player.moveRight) player.velocity.x += 1;
				if (!reverse && player.moveLeft) player.velocity.x -= 1;
			}
			//Update jelly points
			for (var i:int = 0; i < blocks.length; i++) {
				for (var j:int = 0; j < blocks[i].points.length; j++) {
					blocks[i].points[j].update();
				}
			}
			
			var bi:int = player.blockIndex;
			
			//Colliding with a jelly island
			if (bi >= 0) {
				//Aliased variable for current jelly island's points
				var curPoints:Vector.<JellyPoint> = blocks[bi].points;
				
				//Find closest point
				var d:Number = Point.distance(curPoints[0].pos, player.pos);
				var p1:int = 0;
				for (i = 1; i < curPoints.length; i++) {
					var d1:Number = Point.distance(curPoints[i].pos, player.pos);
					if (d > d1) {
						d = d1;
						p1 = i;
					}
				}
				
				//Aliased variables for the three closest jelly points
				var jp1:JellyPoint = curPoints[p1];
				var jp2:JellyPoint;
				
				var clockwise:int;
				if (jp1.neighbors[0].dir == 0) clockwise = 0;
				else clockwise = 1;
				
				var jp2Index:int;
				//Player is inbetween neighbor0 and jp1 in terms of x position
				if ((int(player.pos.x) < int(jp1.pos.x) && jp1.initialPos.x > jp1.neighbors[0].jp.initialPos.x) || (int(player.pos.x) > int(jp1.pos.x) && jp1.initialPos.x < jp1.neighbors[0].jp.initialPos.x)) {
					jp2 = jp1.neighbors[0].jp;
					jp2Index = 0;
				} else if ((int(player.pos.x) < int(jp1.pos.x) && jp1.initialPos.x < jp1.neighbors[0].jp.initialPos.x) || (int(player.pos.x) > int(jp1.pos.x) && jp1.initialPos.x > jp1.neighbors[0].jp.initialPos.x)) {
					jp2 = jp1.neighbors[1].jp;
					jp2Index = 1;
				//Player is inbetween neighbor1 and jp1 in terms of x position
				} else if ((int(player.pos.x) < int(jp1.pos.x) && jp1.initialPos.x > jp1.neighbors[1].jp.initialPos.x) || (int(player.pos.x) > int(jp1.pos.x) && jp1.initialPos.x < jp1.neighbors[1].jp.initialPos.x)) {
					jp2 = jp1.neighbors[1].jp;
					jp2Index = 1;
				} else if ((int(player.pos.x) < int(jp1.pos.x) && jp1.initialPos.x < jp1.neighbors[1].jp.initialPos.x) || (int(player.pos.x) > int(jp1.pos.x) && jp1.initialPos.x > jp1.neighbors[1].jp.initialPos.x)) {
					jp2 = jp1.neighbors[0].jp;
					jp2Index = 0;
				//Player is inbetween neighbor0 and jp1 in terms of y position
				} else if ((int(player.pos.y) < int(jp1.pos.y) && jp1.initialPos.y > jp1.neighbors[0].jp.initialPos.y) || (int(player.pos.y) > int(jp1.pos.y) && jp1.initialPos.y < jp1.neighbors[0].jp.initialPos.y)) {
					jp2 = jp1.neighbors[0].jp;
					jp2Index = 0;
				} else if ((int(player.pos.y) < int(jp1.pos.y) && jp1.initialPos.y < jp1.neighbors[0].jp.initialPos.y) || (int(player.pos.y) > int(jp1.pos.y) && jp1.initialPos.y > jp1.neighbors[0].jp.initialPos.y)) {
					jp2 = jp1.neighbors[1].jp;
					jp2Index = 1;
				//Player is inbetween neighbor1 and jp1 in terms of y position
				} else if ((int(player.pos.y) < int(jp1.pos.y) && jp1.initialPos.y > jp1.neighbors[1].jp.initialPos.y) || (int(player.pos.y) > int(jp1.pos.y) && jp1.initialPos.y < jp1.neighbors[1].jp.initialPos.y)) {
					jp2 = jp1.neighbors[1].jp;
					jp2Index = 1;
				} else if ((int(player.pos.y) < int(jp1.pos.y) && jp1.initialPos.y < jp1.neighbors[1].jp.initialPos.y) || (int(player.pos.y) > int(jp1.pos.y) && jp1.initialPos.y > jp1.neighbors[1].jp.initialPos.y)) {
					jp2 = jp1.neighbors[0].jp;
					jp2Index = 0;
				//None of the above
				} else {
					if (clockwise == 0) {
						jp2 = jp1.neighbors[0].jp;
						jp2Index = 0;
					} else {
						jp2 = jp1.neighbors[1].jp;
						jp2Index = 1;
					}
				}
				
				player.direction = findDirection(jp1, jp2, player.pos.x, player.pos.y);
				
				//Update jelly point positions and velocities
				if (player.velocity.y != 0) {
					jp1.velocity.y += player.velocity.y;
					
					//separate method in jelly point - or part of jelly point update method?
					for (i = 0; i < jp1.neighbors.length; i++) {
						jp1.neighbors[i].jp.velocity.y += (player.velocity.y * .55);
					}
					
					player.velocity.y = 0;
				}
				
				if (player.velocity.x != 0) {
					jp1.velocity.x += player.velocity.x;
					
					for (i = 0; i < jp1.neighbors.length; i++) {
						jp1.neighbors[i].jp.velocity.x += (player.velocity.x * .55);
					}
					
					player.velocity.x = 0;
				}

				if (player.direction == 0 || player.direction == 1) jp1.velocity.y += 0.25;
				else jp1.velocity.x += 0.25;

				//Equation of current line segment
				var u:Point;
				
				//If moving, move the max distance
				var newPos:Point;
				var diffX:Number;
				var diffY:Number;
				var remainder:Number;
				
				if (player.moveLeft) {
					if (clockwise == 0 && jp2Index == 0) {
						u = jp2.pos.subtract(jp1.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					} else if (clockwise == 0 && jp2Index == 1) {
						u = jp1.pos.subtract(jp2.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					} else if (clockwise == 1 && jp2Index == 0) {
						u = jp1.pos.subtract(jp2.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					} else {
						u = jp2.pos.subtract(jp1.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					}
					newPos = player.pos.add(u);

				} else if (player.moveRight) {
					if (clockwise == 0 && jp2Index == 0) {
						u = jp1.pos.subtract(jp2.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					} else if (clockwise == 0 && jp2Index == 1) {
						u = jp2.pos.subtract(jp1.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					} else if (clockwise == 1 && jp2Index == 0) {
						u = jp2.pos.subtract(jp1.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					} else {
						u = jp1.pos.subtract(jp2.pos);
						u.normalize(1);
						u.x = u.x * maxDist; u.y = u.y * maxDist;
					}
					newPos = player.pos.add(u);
				} else {
					if (player.direction == 0 || player.direction == 1) {
						diffX = Math.abs(jp2.pos.x - player.pos.x) / Math.abs(jp1.pos.x - jp2.pos.x);
						
						newPos = Point.interpolate(jp1.pos, jp2.pos, diffX);
					} else {
						diffY = Math.abs(jp2.pos.y - player.pos.y) / Math.abs(jp1.pos.y - jp2.pos.y);
						newPos = Point.interpolate(jp1.pos, jp2.pos, diffY);
					}
				}
				
				if (player.direction == 0 || player.direction == 1) {
					diffX = Math.abs(jp2.pos.x - player.pos.x) / Math.abs(jp1.pos.x - jp2.pos.x);
					newPos.y = Point.interpolate(jp1.pos, jp2.pos, clamp(diffX, 0, 1)).y;
				} else {
					diffY = Math.abs(jp2.pos.y - player.pos.y) / Math.abs(jp1.pos.y - jp2.pos.y);
					newPos.x = Point.interpolate(jp1.pos, jp2.pos, clamp(diffY, 0, 1)).x;
				}
				
				player.pos = newPos;
				
				if (player.jumping) {
					switch(player.direction) {
					case 0:
						player.velocity.y = -5 - (Math.pow(Math.abs(jp1.velocity.y), 1.20));
						jp1.velocity.y += 0.5;
						break;
					case 1:
						player.velocity.y = 5 + (Math.pow(Math.abs(jp1.velocity.y), 1.20));
						jp1.velocity.y -= 0.5;
						break;
					case 2:
						player.velocity.x = 5 + (Math.pow(Math.abs(jp1.velocity.x), 1.20));
						jp1.velocity.x -= 0.5;
						break;
					case 3:
						player.velocity.x = -5 - (Math.pow(Math.abs(jp1.velocity.x), 1.20));
						jp1.velocity.x += 0.5;
						break;
					}

					player.grounded = false;
					player.blockIndex = -1;
				}
			}
			
			if (!player.grounded) {
				if (curLevel >= 3 && curLevel < 6) {
					if (player.pos.x < 640) {
						player.velocity.y += gravity;
						reverse = false;
						if (player.pos.y > 1000) resetPlayer();
					} else if (player.pos.x > 640) {
						player.velocity.y -= gravity;
						reverse = true;
						if (player.pos.y < -200) resetPlayer();
					}
				} else if (curLevel == 6) {
					if (player.pos.x < 426) {
						player.velocity.y += gravity;
						reverse = false;
						if (player.pos.y > 1000) resetPlayer();
					} else if (player.pos.x > 426 && player.pos.x < 852) {
						player.velocity.y -= gravity;
						reverse = true;
						if (player.pos.y < -200) resetPlayer();
					} else if (player.pos.x > 852 && player.pos.y < 384) {
						player.velocity.y -= gravity;
						reverse = true;
						if (player.pos.y < -200) resetPlayer();
					} else {
						player.velocity.y += gravity;
						reverse = false;
						if (player.pos.y > 1500) resetPlayer();
					}
				} else {
					player.velocity.y += gravity;
					if (player.pos.y > 1000) resetPlayer();
				}
			}
			
			player.velocity.x *= .9;

			if (player.velocity.y > 25) player.velocity.y = 25;
			if (player.velocity.y < -25) player.velocity.y = -25;
			if (player.velocity.x > 25) player.velocity.x = 25;
			if (player.velocity.x < -25) player.velocity.x = -25;
			if (!player.grounded) {
				player.pos.y += player.velocity.y;
				player.pos.x += player.velocity.x;
			}
		}
		
		public function findDirection(jp1:JellyPoint, jp2:JellyPoint, x:Number, y:Number):int {
			var xLoc:int = (((jp1.initialPos.x + jp2.initialPos.x) / 2) / wScale);
			var yLoc:int = (((jp1.initialPos.y + jp2.initialPos.y) / 2) / hScale) + 0.5;
			if (int(jp1.initialPos.y) == int(jp2.initialPos.y)) {
				//horizontal segment
				if (editor.level[yLoc - 1][xLoc] == 0) return 0;
				return 1;
			} else {
				//vertical segment
				if (editor.level[yLoc][xLoc + 1] == 0) return 2;
				return 3;
			}
		}
		
		public function clamp(val:Number, min:Number, max:Number):Number {
			return Math.max(min, Math.min(max, val))
		}
		
		public function resetPlayer():void {
			player.pos.setTo(startSpots[curLevel - 1].x, startSpots[curLevel - 1].y);
			player.velocity.setTo(0, 0);
			player.blockIndex = -1;
			player.grounded = false;
		}
		
		public function victoryCheck():void {
			if (curLevel == 1) {
				if (Point.distance(player.pos, goals[0]) < 15) editor.loadLevel(2);
			} else if (curLevel == 2) {
				if (Point.distance(player.pos, goals[1]) < 15) editor.loadLevel(3);
			} else if (curLevel == 3) {
				if (Point.distance(player.pos, goals[2]) < 15) editor.loadLevel(4);
			} else if (curLevel == 4) {
				if (Point.distance(player.pos, goals[3]) < 15) editor.loadLevel(5);
			} else if (curLevel == 5) {
				if (Point.distance(player.pos, goals[4]) < 15) editor.loadLevel(6);
			} else if (curLevel == 6) {
				if (Point.distance(player.pos, goals[5]) < 15) editor.loadLevel(1);
			}
		}
	}
}