package;

import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	static inline var TILE_SIZE:Int = 32;
	static inline var MOVEMENT_SPEED:Int = 2;

	var up:FlxActionDigital;
	var down:FlxActionDigital;
	var left:FlxActionDigital;
	var right:FlxActionDigital;

	var moveX:Float = 0;
	var moveY:Float = 0;

	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);

		// Make the player graphic.
		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.WHITE);

		addInputs();
	}

	function addInputs():Void
	{
		// Add keyboard inputs

		up = new FlxActionDigital();
		down = new FlxActionDigital();
		left = new FlxActionDigital();
		right = new FlxActionDigital();

		up.addKey(W, PRESSED);
		down.addKey(S, PRESSED);
		left.addKey(A, PRESSED);
		right.addKey(D, PRESSED);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		velocity.x = 0;
		velocity.y = 0;

		y += moveY * MOVEMENT_SPEED;
		x += moveX * MOVEMENT_SPEED;

		moveX = 0;
		moveY = 0;

		updateDigital();
	}

	function updateDigital():Void
	{
		if (down.triggered)
		{
			moveY = 1;
		}
		else if (up.triggered)
		{
			moveY = -1;
		}

		if (left.triggered)
		{
			moveX = -1;
		}
		else if (right.triggered)
		{
			moveX = 1;
		}

		if (moveX != 0 && moveY != 0)
		{
			moveY *= .707;
			moveX *= .707;
		}
	}
}
