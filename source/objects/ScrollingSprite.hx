package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * Custom class for sprites scrolling to the left of the screen because FlxBackdrop NEVER works correctly for me with a non-fixed camera
 */
class ScrollingSprite extends FlxSpriteGroup
{
	var img1:FlxSprite;
	var img2:FlxSprite;

	public function new(x:Float, y:Float, graphic:String, velocityX:Float, xOffset:Float)
	{
		super(x, y);

		img1 = new FlxSprite(xOffset).loadGraphic(graphic);
		img1.scale.set(1.5, 1.5);
		img1.updateHitbox();
		img1.velocity.x = velocityX;
		add(img1);

		img2 = new FlxSprite().loadGraphic(graphic);
		img2.scale.set(1.5, 1.5);
		img2.updateHitbox();
		img2.x = img1.x + img2.width;
		img2.velocity.x = velocityX;
		add(img2);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (img1.x < (img1.width + img1.width / 4) * -1)
			img1.x = img2.x + img1.width;
		if (img2.x < (img2.width + img2.width / 4) * -1)
			img2.x = img1.x + img2.width;
	}
}
