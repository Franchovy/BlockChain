package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class ChainBlock extends FlxSprite
{
	public static inline var TILE_SIZE = 20;

	public function new()
	{
		super();

		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.GRAY);
	}

	public function setupStart()
	{
		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.GRAY);
	}

	public function disable()
	{
		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.fromRGB(150, 70, 70));
	}
}
