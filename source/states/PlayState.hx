package states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
import objects.ScrollingSprite;
import objects.Sign;
import objects.Player;

class PlayState extends FlxState
{
	var transition:Transition;
	var player:Player;
	var map:FlxOgmo3Loader;
	var level:FlxTilemap;
	var halfmap:FlxTilemap;
	var decals:FlxGroup;

	var gameCam:FlxCamera;
	var hudCam:FlxCamera;

	var door:FlxSprite;
	var signGroup:FlxTypedGroup<Sign> = new FlxTypedGroup<Sign>();
	var triggerGroup = new FlxTypedGroup<FlxObject>();
	var triggerMap = new Map<FlxObject, {var type:String; var triggered:Bool;}>();

	var followPoint = new FlxObject();

	var pad:FlxVirtualPad;

	static var levelNum:Int = 1;

	var explosion:FlxEmitter;

	override public function create()
	{
		super.create();
		
		gameCam = new FlxCamera();
		hudCam = new FlxCamera();

		FlxG.cameras.add(gameCam);
		FlxG.cameras.add(hudCam);
		hudCam.bgColor.alpha = 0;

		FlxCamera.defaultCameras = [gameCam];

		transition = new Transition();
		transition.cameras = [hudCam];
		transition.open(() -> {});
		add(transition);

		// gameCam.pixelPerfectRender = true;
		map = new FlxOgmo3Loader('assets/data/levels.ogmo', 'assets/data/levels/house$levelNum.json');

 		var bg = new ScrollingSprite(0, -150, 'assets/images/sky.png', -56, -640);
		bg.scrollFactor.x = 0;
		add(bg);

		var clouds = new ScrollingSprite(0, -150, 'assets/images/clouds.png', -86, -640);
		clouds.scrollFactor.x = 0;
		add(clouds); 

		decals = map.loadDecals('underDecals', 'assets/images/decals');
		add(decals);

		level = map.loadTilemap('assets/images/grassTiles.png', 'level');
		level.follow(gameCam);
		add(level);

		halfmap = map.loadTilemap('assets/images/halfTiles.png', 'halftile');
		halfmap.setTileProperties(1, ANY, touchSpike);
		halfmap.follow(gameCam);
		add(halfmap);

		add(signGroup);

		player = new Player();
		add(player);

		explosion = new FlxEmitter();
		explosion.makeParticles(16, 16, FlxColor.RED, 50);
		explosion.alpha.set(.9, 1, 0, 0);
		explosion.scale.set(1, 1, 1.5, 1.5, 1, 1, 1, 1);
		explosion.lifespan.set(1, 1);
		explosion.velocity.set(-800, -800, 800, 800);
		explosion.launchMode = SQUARE;
		add(explosion);

		gameCam.follow(player, PLATFORMER, .1);
		gameCam.deadzone = FlxRect.get((1280 - (1280 / 10)) / 2, (720 - (720 / 10)) / 2 - (720 / 10) * 0.25, (1280 / 10), (720 / 10));
		gameCam.zoom = .5;

		map.loadEntities(placeEntities, "entities");

		bg.setPosition(level.x, level.y);
		// fuck
		gameCam.setScrollBoundsRect(level.x, bg.y, level.width, level.height - player.height - 20);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if !mobile
		if (FlxG.keys.justPressed.R){
			transition.close(() -> {});
		    new FlxTimer().start(1, tmr -> {
				trace('timer done??');
            	FlxG.switchState(new PlayState());
        	});
		}
		#end

		FlxG.collide(player, halfmap);
		FlxG.collide(player, level);
		if(!player.alive){
			FlxG.collide(explosion, level);
			FlxG.collide(explosion, halfmap);
		}

		for (sign in signGroup)
		{
			// stupid shit so we can check if it actually overlaps the SIGN not the GROUP
			if (FlxG.overlap(player, sign.sign))
			{
				touchSign(player, sign);
			}
		}

		for (trigger in triggerGroup) {
			if(!triggerMap[trigger].triggered)
				FlxG.overlap(player, trigger, enterTrigger);
		}
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "player":
				player.setPosition(entity.x, entity.y);
			case 'door':
				door.setPosition(entity.x, entity.y);
			case 'sign':
				var sign = new Sign(entity.x, entity.y);
				sign.message = entity.values.message;
				signGroup.add(sign);
			case 'trigger':
				var trigger = new FlxObject(entity.x, entity.y, entity.width, entity.height);
				triggerMap.set(trigger, {type: entity.values.triggerType, triggered: false});
				triggerGroup.add(trigger);
			default:
				FlxG.log.add('Unrecognized actor type ${entity.name}');
		}
	}

	function playerTouchDoor(player:Player, door:FlxSprite)
	{
		levelNum++;
		FlxG.switchState(new PlayState());
	}

	function touchSpike(tile:FlxObject, object:FlxObject)
	{
		if(!player.alive) return;
		FlxG.sound.play('assets/sounds/death.ogg');
		player.kill();
		explosion.setPosition(player.getMidpoint().x, player.getMidpoint().y);
		explosion.solid = true;
		explosion.start();
		new FlxTimer().start(.5, tmr -> transition.close(() -> {
			FlxG.switchState(new PlayState());
		}));
	}

	function touchSign(player:Player, sign:Sign)
	{
		sign.read();
	}

	function enterTrigger(player:Player, trigger:FlxObject){
		triggerMap[trigger].triggered = true;
		switch(triggerMap[trigger].type){
			case 'level1dialogue':
				player.paused = true;
				FlxTween.tween(gameCam, {zoom: 1, 'targetOffset.y': gameCam.targetOffset.y - 150, 'targetOffset.x': gameCam.targetOffset.x + 50}, 2, {ease: FlxEase.cubeInOut});
		}
	}
}
