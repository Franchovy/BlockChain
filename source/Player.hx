package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	static inline var TILE_SIZE:Int = 32;
	static inline var SPEED:Float = 300;
	static inline var MAX_SPEED:Float = 250;
	static inline var ACCELERATION:Float = 900;
	static inline var BRAKE_MULTIPLIER:Float = 10;

	static inline var DIAGONAL_MULTIPLER:Float = 0.707;

	var shouldMultiplyDiagonal = false;

	var up:FlxActionDigital;
	var down:FlxActionDigital;
	var left:FlxActionDigital;
	var right:FlxActionDigital;

	var targetVelX:Float = 0;
	var targetVelY:Float = 0;

	static var actions:FlxActionManager;

	public function new(X:Int, Y:Int)
	{
		// X,Y: Starting coordinates
		super(X, Y);

		// Make the player graphic.
		makeGraphic(TILE_SIZE, TILE_SIZE, FlxColor.WHITE);

		maxVelocity.x = MAX_SPEED;
		maxVelocity.y = MAX_SPEED;

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

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([up, down, left, right]);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		acceleration.x = 0;
		acceleration.y = 0;

		updateDigital();
	}

	function updateDigital():Void
	{
		shouldMultiplyDiagonal = (down.triggered != up.triggered) && (left.triggered != right.triggered);

		var currentAcceleration = ACCELERATION * (shouldMultiplyDiagonal ? DIAGONAL_MULTIPLER : 1.0);

		if (down.triggered != up.triggered)
		{
			if (down.triggered)
			{
				acceleration.y = currentAcceleration;
			}
			else if (up.triggered)
			{
				acceleration.y = -currentAcceleration;
			}
		}
		else if (!down.triggered && !up.triggered)
		{
			acceleration.y = -velocity.y * BRAKE_MULTIPLIER;
		}

		if (left.triggered != right.triggered)
		{
			if (left.triggered)
			{
				acceleration.x = -currentAcceleration;
			}
			else if (right.triggered && !left.triggered)
			{
				acceleration.x = currentAcceleration;
			}
		}
		else if (!right.triggered && !left.triggered)
		{
			acceleration.x = -velocity.x * BRAKE_MULTIPLIER;
		}
	}
}
