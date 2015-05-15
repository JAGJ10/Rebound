package {
	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class InputController {
		private var state:GameState;
		
		public function InputController(gs:GameState) {
			state = gs;
		}

		public function keyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.W && !state.player.jumping) state.player.jumping = true;
			
			if (e.keyCode == Keyboard.D || e.keyCode == Keyboard.RIGHT) state.player.moveRight = true;
			
			if (e.keyCode == Keyboard.A || e.keyCode == Keyboard.LEFT) state.player.moveLeft = true;
		}
		
		public function keyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.W && state.player.jumping) state.player.jumping = false;
			
			if (e.keyCode == Keyboard.D || e.keyCode == Keyboard.RIGHT) state.player.moveRight = false;
			
			if (e.keyCode == Keyboard.A || e.keyCode == Keyboard.LEFT) state.player.moveLeft = false;
			
			if (e.keyCode == Keyboard.M) state.editor.editorMode = !state.editor.editorMode;
			
			if (e.keyCode == Keyboard.N) state.editor.create = true;
			
			if (e.keyCode == Keyboard.B) state.editor.create = false;
			
			if (e.keyCode == Keyboard.G) state.gridEnabled = !state.gridEnabled;
			
			if (e.keyCode == Keyboard.P) state.pointsEnabled = !state.pointsEnabled;
			
			if (e.keyCode == Keyboard.ENTER && state.editor.editorMode) state.editor.printLevel();
			
			if (e.keyCode == Keyboard.NUMBER_1) state.editor.loadLevel(1);
			if (e.keyCode == Keyboard.NUMBER_2) state.editor.loadLevel(2);
			if (e.keyCode == Keyboard.NUMBER_3) state.editor.loadLevel(3);
			if (e.keyCode == Keyboard.NUMBER_4) state.editor.loadLevel(4);
		}
	}
}