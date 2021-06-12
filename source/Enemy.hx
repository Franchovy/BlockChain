package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.util.FlxColor;

class Enemy extends FlxSprite
{
	public static inline var TILE_SIZE:Int = 30;
	static var actions:FlxActionManager;

	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);

		// Make the player graphic.
		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.RED);
	}
}
