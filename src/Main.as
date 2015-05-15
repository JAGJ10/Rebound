package  {
	import flash.display.Sprite;
	import starling.core.Starling;

	[SWF(width="1280", height="768", frameRate="120", backgroundColor="#000000")]
	public class Main extends Sprite {
		private var _starling:Starling;

		public function Main() {
			_starling = new Starling(GameState, stage);
			_starling.start();
			_starling.showStats = true;			
		}
	}
}