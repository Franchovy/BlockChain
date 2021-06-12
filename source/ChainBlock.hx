package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class ChainBlock extends FlxSprite
{
	static inline var TILE_SIZE = 20;

	public function new(X:Float, Y:Float)
	{
		super(X, Y);

		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.GRAY);
	}
}
