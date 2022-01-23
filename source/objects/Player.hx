package objects;

import states.PlayState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	public var jumpCount:Int = 1;
	public var dashCount:Int = 1;
	public var jumping:Bool = false;
	public var falling:Bool = false;
	public var stunned:Bool = false;
	var walking:Bool = false;
	public var paused:Bool = false;

	var stunnedTime:Float = 0;
	var pauseTime:Float = 0;
	var jumpTimer:Float = 0;
	var walkTimer:Float = 0;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic("assets/images/luckyy.png", true, 392, 686);
		animation.add("lr", [4, 6, 7, 8, 0], 12, false);
		animation.add("idle", [0], 12, true);
		animation.add("jump", [10, 11], 12, true);
		animation.add("land", [12, 13, 14], false);
		animation.play('idle');
		setGraphicSize(200);
		updateHitbox();

		width -= 45;
		height -= 40;

		offset.x += 25;
		offset.y += 32;

		maxVelocity.set(900, 2700);
		acceleration.y = maxVelocity.y * 1.75;
		drag.x = maxVelocity.x * 6;

		FlxG.watch.add(this, 'velocity');

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
	}

	override public function update(elapsed:Float)
	{
		updateMovement(elapsed);

		super.update(elapsed);

		if (stunnedTime > 0)
		{
			stunnedTime -= elapsed;
		}
		else if (stunnedTime <= 0)
		{
			stunned = false;
			maxVelocity.set(900, 2700);
			acceleration.y = maxVelocity.y * 1.75;
		}

		walkTimer -= elapsed;

		if(walkTimer <= 0){
			if(walking) FlxG.sound.play('assets/sounds/step_${FlxG.random.int(1, 4)}.ogg', .75);
			walkTimer = .25;
		}

		oldYV = velocity.y;
	}

	var oldYV:Float = 0;

	function updateMovement(elapsed:Float)
	{
		// acceleration.x = 0;

		if(jumping && !FlxG.keys.pressed.UP) jumping = false;
		if(walking && (!FlxG.keys.anyPressed([LEFT, A, RIGHT, D]) || !isTouching(FLOOR))) walking = false;

		if (isTouching(FLOOR) && !jumping)
		{
			jumpTimer = 0;
			jumpCount = 1;
			dashCount = 1;
		}

		var turning = velocity.y > 0 ? 1.25 : 1;
		if(!paused){
			if (!stunned && FlxG.keys.anyPressed([LEFT, A]))
			{
				velocity.x += -maxVelocity.x / (4.5 * turning);
				facing = FlxObject.LEFT;
				if (isTouching(FLOOR)){
					animation.play("lr");
					walking = true;
				}
			}

			if (!stunned && FlxG.keys.anyPressed([RIGHT, D]))
			{
				/// (4.5 * turning)
				velocity.x += maxVelocity.x / (4.5 * turning);
				facing = FlxObject.RIGHT;
				if (isTouching(FLOOR)){
					animation.play("lr");
					walking = true;
				}
			}
		}

		if (!stunned && velocity.x == 0 && velocity.y == 0 && isTouching(FLOOR))
			animation.play("idle");

		if (velocity.y > 0)
		{
			falling = true;
			animation.play("jump", true);
		}

		if (falling && isTouching(FLOOR))
		{
			animation.play('land', true);
			FlxG.sound.play('assets/sounds/landing.ogg');
			falling = false;
			var stun = .15 * (oldYV / maxVelocity.y);
			if (stun > .1)
			{
				stunned = true;
				stunnedTime = stun;
			}
		}

		if(!paused){
			if (jumpTimer >= 0 && FlxG.keys.pressed.UP)
			{
				jumping = true;
				jumpTimer += elapsed;
				if(FlxG.keys.justPressed.UP) FlxG.sound.play('assets/sounds/jump.ogg');
			}
			else
				jumpTimer = -1;

			if (!stunned && jumpTimer > 0 && jumpTimer < .25)
			{
				velocity.y = -maxVelocity.y / 1.75; /// 1.5;
				animation.play("jump", true);
			}

			if (!stunned && dashCount > 0 && FlxG.keys.justPressed.X)
			{
				dashCount -= 1;
				stunned = true;
				stunnedTime = .1;
				maxVelocity.x = 900 * 3;
				acceleration.y = 0;
				velocity.y = 0;
				FlxG.sound.play('assets/sounds/dash.ogg');
				if (FlxG.keys.pressed.RIGHT)
				{
					velocity.x = maxVelocity.x;
				}
				if (FlxG.keys.pressed.LEFT)
				{
					velocity.x = -maxVelocity.x;
				}
			}
		}
	}
}
