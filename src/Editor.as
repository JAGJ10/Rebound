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
	import GameState;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	public class Editor extends Sprite {
		private var state:GameState;
		public var editorMode:Boolean = false;
		public var create:Boolean = false;
		public var level:Array;
		
		private static var size:int = 60;
		
		public function Editor(gs:GameState) {
			state = gs;
			//editorMode = true;
			
			level = new Array();
			for (var i:int = 0; i < size; i++) {
				level[i] = new Array(size);
				for (var j:int = 0; j < size; j++) {
					level[i][j] = 0;
				}
			}
		}
		
		public function mouseClick(e:TouchEvent):void {
			if (editorMode) {
				var touch:Touch = e.getTouch(state, TouchPhase.MOVED);
				if (touch) {
					var loc:Point = touch.getLocation(this);
					if (level[int((loc.y / state.hScale))][int((loc.x / state.wScale))] == 0 && create) {
						level[int((loc.y / state.hScale))][int((loc.x / state.wScale))] = 1;
					} else if (level[int((loc.y / state.hScale))][int((loc.x / state.wScale))] == 1 && !create) {
						level[int((loc.y / state.hScale))][int((loc.x / state.wScale))] = 0;
					}
					
					parseLevel();
				}
			}
		}
		
		public function parseLevel():void {
			state.blocks.length = 0;
			
			var walls:Array = new Array(size);
			for (var i:int = 0; i < size - 1; i++) {
				walls[i] = new Array(size);
				for (var j:int = 0; j < size - 1; j++) {
					var x:int;
					if (level[i][j] != level[i][j + 1]) {
						x = 2;
					} else {
						x = 0;
					}
					
					if (level[i][j] != level[i + 1][j]) {
						x++;
					}
					
					walls[i][j] = x;
					walls[i][j] = x;
				}
			}
			
			for (var r:int = 0; r < size - 1; r++) {
				for (var c:int = 0; c < size - 1; c++) {
					if (walls[r][c] & 1) {
						i = r + 1;
						j = c;
						var cycle:Array = [];
						cycle.push(new Point(i, j));
						while (true) {
							if (i > 0 && walls[i - 1][j - 1] & 2) {
								walls[i - 1][j - 1] -= 2;
								i--;
							} else if (j > 0 && walls[i - 1][j - 1] & 1) {
								walls[i - 1][j - 1] -= 1;
								j--;
							} else if (i < size - 1 && walls[i][j - 1] & 2) {
								walls[i][j - 1] -= 2;
								i++;
							} else if (j < size - 1 && walls[i - 1][j] & 1) {
								walls[i - 1][j] -= 1;
								j++;
							} else {
								break;
							}
							
							cycle.push(new Point(i, j));
						}
						
						cycle.pop();
						addCycle(cycle);
					}
				}
			}
		}
		
		public function addCycle(cycle:Array):void {
			var points:Array = [];
			for (var i:int = 0; i < cycle.length; i++) {
				var p:Point = new Point(cycle[i].y * state.hScale - (state.hScale / 2), cycle[i].x * state.wScale - (state.wScale / 2));
				points.push(p);
			}
			
			var jb:JellyBlock = new JellyBlock(points);
			state.blocks.push(jb);
		}
		
		public function loadLevel(num:int):void {
			state.curLevel = num;
			var string:String = "Rebound/levels/" + num + ".txt";
			var file:File = File.desktopDirectory.resolvePath(string);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			for (var i:int = 0; i < size; i++) {
				for (var j:int = 0; j < size; j++) {
					level[i][j] = fileStream.readUTFBytes(1);
				}
			}
			fileStream.close();
			
			parseLevel();
			state.resetPlayer();
		}
		
		public function printLevel():void {
			var file:File = File.desktopDirectory.resolvePath("Rebound/levels/4.txt");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			for (var i:int = 0; i < size; i++) {
				for (var j:int = 0; j < size; j++) {
					fileStream.writeUTFBytes(level[i][j]);
				}
				//fileStream.writeUTFBytes("\n");
			}
			fileStream.close();
		}
	}
}