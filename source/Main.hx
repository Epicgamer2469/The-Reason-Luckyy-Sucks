package;

import states.MenuState;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.utils.Assets;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, MenuState));
		#if debug
			var bitmapData = Assets.getBitmapData("assets/images/watermark.png");
			var watermark = new Sprite();
			watermark.addChild(new Bitmap(bitmapData));
			watermark.alpha = 0.4;
			addChild(watermark);
		#end
	}
}
