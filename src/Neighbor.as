package {
	public class Neighbor {
		public var jp:JellyPoint;
		
		/* Direction -> clockwise or counter-clockwise
		 * 0 - clockwise
		 * 1 - counter-clockwise
		 */
		public var dir:int;
		
		public function Neighbor(jpIn:JellyPoint, d:int) {
			jp = jpIn;
			dir = d;
		}
	}
}