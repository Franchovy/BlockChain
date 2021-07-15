package;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class FastObstacle extends Obstacle
{
	var _elapsedSinceSpawn:Int = 0;
	var CHARGE_SPEED = 5.0;
	var speedMultiplier:Float = 1.0;

	public function new()
	{
		super(500, FlxColor.ORANGE);
		kill();

		rechargeSound = FlxG.sound.load("assets/sounds/gold_recharge.wav");
	}

	override public function spawn()
	{
		super.spawn();
		_elapsedSinceSpawn++;
		// Peak out to warn the player of the incoming obstacle
		if (_isVertical)
			velocity.set(0, y > 0 ? -CHARGE_SPEED : CHARGE_SPEED);
		else
			velocity.set(x > 0 ? -CHARGE_SPEED : CHARGE_SPEED, 0);

		rechargeSound.play();
	}

	override public function setSpeedMultiplier(multiplier:Float)
	{
		speedMultiplier = multiplier;
		super.setSpeedMultiplier(multiplier);
	}

	var rechargeSound:FlxSound;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_elapsedSinceSpawn > 0 && ++_elapsedSinceSpawn > 100)
		{
			rechargeSound.stop();
			FlxG.sound.play("assets/sounds/gold_launch.wav");
			go();
			_elapsedSinceSpawn = 0;
		}
	}
}
