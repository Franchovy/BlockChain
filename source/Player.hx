package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	public static inline var TILE_SIZE:Int = 32;
	static inline var SPEED:Float = 300;
	static inline var MAX_SPEED:Float = 300;
	static inline var ACCELERATION:Float = 900;
	static inline var BRAKE_MULTIPLIER:Float = 10;

	static inline var DIAGONAL_MULTIPLER:Float = 0.707;

	var shouldMultiplyDiagonal = false;

	var up:FlxActionDigital;
	var down:FlxActionDigital;
	var left:FlxActionDigital;
	var right:FlxActionDigital;

	var hold_up:FlxActionDigital;
	var hold_down:FlxActionDigital;
	var hold_left:FlxActionDigital;
	var hold_right:FlxActionDigital;

	var targetVelX:Float = 0;
	var targetVelY:Float = 0;

	static var actions:FlxActionManager;

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

		hold_up = new FlxActionDigital();
		hold_down = new FlxActionDigital();
		hold_left = new FlxActionDigital();
		hold_right = new FlxActionDigital();

		up.addKey(W, JUST_PRESSED);
		down.addKey(S, JUST_PRESSED);
		left.addKey(A, JUST_PRESSED);
		right.addKey(D, JUST_PRESSED);

		hold_up.addKey(W, PRESSED);
		hold_down.addKey(S, PRESSED);
		hold_left.addKey(A, PRESSED);
		hold_right.addKey(D, PRESSED);

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([up, down, left, right, hold_up, hold_down, hold_right, hold_left]);
	}

	static inline var ACC_DRAG = 0.9;
	static inline var VEL_DRAG = 0.9;
	static inline var DIAGONAL_MOD = 0.707;

	var isMovingDiagonal = false;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		acceleration.x = -acceleration.x * ACC_DRAG;
		acceleration.y = -acceleration.y * ACC_DRAG;

		velocity.x = velocity.x * VEL_DRAG;
		velocity.y = velocity.y * VEL_DRAG;

		updateDigital();

		cooldown_elapsed += elapsed;

		if (cooldown_elapsed > BOOST_COOLDOWN)
		{
			if (hold_up.triggered && !hold_down.triggered)
			{
				acceleration.y = -AUTO_BOOST_SPEED;
				cooldown_elapsed = 0.0;
			}
			else if (hold_down.triggered && !hold_up.triggered)
			{
				acceleration.y = AUTO_BOOST_SPEED;
				cooldown_elapsed = 0.0;
			}

			if (hold_left.triggered && !hold_right.triggered)
			{
				acceleration.x = -AUTO_BOOST_SPEED;
				cooldown_elapsed = 0.0;
			}
			else if (hold_right.triggered && !hold_left.triggered)
			{
				acceleration.x = AUTO_BOOST_SPEED;
				cooldown_elapsed = 0.0;
			}
		}

		if (acceleration.x != 0 && acceleration.y != 0)
		{
			acceleration.x *= DIAGONAL_MOD;
			acceleration.y *= DIAGONAL_MOD;
		}
	}

	static inline var BOOST_SPEED = 40000;
	static inline var AUTO_BOOST_SPEED = 60000;

	static inline var BOOST_COOLDOWN = 0.3;

	var cooldown_elapsed = 0.0;

	function updateDigital()
	{
		if (up.triggered && !down.triggered)
		{
			acceleration.y = -BOOST_SPEED;
		}
		else if (down.triggered && !up.triggered)
		{
			acceleration.y = BOOST_SPEED;
		}
		else if (right.triggered && !left.triggered)
		{
			acceleration.x = BOOST_SPEED;
		}
		else if (left.triggered && !right.triggered)
		{
			acceleration.x = -BOOST_SPEED;
		}
	}
}
