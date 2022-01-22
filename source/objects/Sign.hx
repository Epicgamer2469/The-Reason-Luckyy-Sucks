package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Sign extends FlxSpriteGroup
{
	public var message:String;

	public var sign:FlxSprite;

	var textBox:FlxSprite;
	var dialogue:FlxTypeText;
	var typing:Bool = false;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		sign = new FlxSprite().loadGraphic('assets/images/decals/tile_0086.png');
		textBox = new FlxSprite().loadGraphic('assets/images/box.png');
		textBox.x = (sign.width / 2) - (textBox.width / 2);
		textBox.y -= textBox.height + 25;
		textBox.origin.y = textBox.height;
		textBox.scale.set(1.5, .5);
		textBox.alpha = 0;
		dialogue = new FlxTypeText(textBox.x + 6, textBox.y + textBox.height - 10, Std.int(textBox.width - 6), '', 30);
		dialogue.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		dialogue.alpha = 0;

		add(sign);
		add(textBox);
		add(dialogue);
	}

	public function read()
	{
		if (!typing)
		{
			typing = true;
			dialogue.resetText(message);
			dialogue.start(.075);
			FlxTween.tween(textBox, {alpha: 1, 'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.cubeOut});
			FlxTween.tween(dialogue, {alpha: 1, y: textBox.y + 6}, 1, {ease: FlxEase.cubeOut});
		}
	}
}
