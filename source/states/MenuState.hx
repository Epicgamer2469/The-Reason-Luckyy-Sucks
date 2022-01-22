package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var buttons:Array<String> = ['play', 'options', 'credits', 'boom'];
	var butGroup:FlxGroup;

	override public function create()
	{
		super.create();

		var bg = new FlxSprite().makeGraphic(1280, 720, 0xFFa7a9a8);
		add(bg);
		var checker = new FlxBackdrop('assets/images/menu/checkers.png');
		checker.velocity.set(50, 50);
		add(checker);

		var logo = new FlxSprite(0, 15).loadGraphic('assets/images/menu/logo.png');
		logo.scale.set(.65, .65);
		logo.antialiasing = true;
		logo.updateHitbox();
		logo.screenCenter(X);
		logo.angle = -7;
		FlxTween.tween(logo, {angle: 7}, 1.5, {ease: FlxEase.quadInOut, type: PINGPONG});
		add(logo);

		butGroup = new FlxGroup();

		for (i in 0...buttons.length)
		{
			var button = new FlxSprite(0, logo.height + 25 + (85 * (i > 1 ? 1 : 0))).loadGraphic('assets/images/menu/${buttons[i]}.png');
			button.scale.set(.75, .75);
			button.antialiasing = true;
			button.updateHitbox();
			button.screenCenter(X);
			if (i % 2 == 0)
				button.x -= button.width / 2;
			else
				button.x += button.width / 2;
			button.ID = i;
			FlxMouseEventManager.add(button, buttonClick, buttonUp, buttonOver, buttonOut);
			butGroup.add(button);
		}

		add(butGroup);
	}

	function buttonClick(button:FlxSprite)
	{
		switch (button.ID)
		{
			case 0:
				FlxG.camera.fade(FlxColor.BLACK, .65, false, () ->
				{
					FlxG.switchState(new PlayState());
				});
			case 3:
				FlxG.sound.play('assets/sounds/boom.ogg');
		}
	}

	function buttonUp(button:FlxSprite) {}

	function buttonOver(button:FlxSprite)
	{
		button.color = 0xC4C4C4;
	}

	function buttonOut(button:FlxSprite)
	{
		button.color = 0xffffff;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
