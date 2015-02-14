package systems 
{
	import com.ktm.genome.core.logic.system.System;
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.core.data.component.IComponentMapper;
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import com.ktm.genome.render.component.Transform;
	import com.ktm.genome.resource.component.TextureResource;
	import com.ktm.genome.render.component.Layer;
	import components.Touchable;
	import flash.display.BitmapData;
	import flash.display.Stage;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import components.Uncontrolable;
	import components.Controlable;
	import components.Obstacle;
	import components.Velocity;
	import components.LevelCompleted;
	import components.GameOver;
	
	/**
	 * ...
	 * @author Vietlm
	 */
	public class UncontrolableMovingSystem extends System 
	{
		private static const MAX_HEIGHT:Number = 800;
		private static const SPEEDSTEP:Number = 5;
		// 2 State pour l'entite uncontrolable
		private static const STATE_READY:Number = 0;
		private static const STATE_MOVING:Number = 1;
		// Numero de parties d'un brique qui va être presente dans l'ecran quand le brique est brisé
		private static const NB_BREAK_PART:Number = 6;
		
		// Les familles
		private var uncontrolableEntities:Family;
		private var controlableEntities:Family;
		private var obstacleEntities:Family;
		private var layerEntities:Family;
		private var gameOverEntities:Family;
		private var levelCompletedEntities:Family;
		
		// Les mappers
		private var transformMapper:IComponentMapper;
		private var uncontrolableMapper:IComponentMapper;
		private var velocityMapper:IComponentMapper; 
		private var textureResourceMapper:IComponentMapper;
		private var obstacleMapper:IComponentMapper;
		private var layerMapper:IComponentMapper;
		private var touchableMapper:IComponentMapper;
		
		// Les valeur pour la vitesse, on va stocker la vitesse dans les variables speedX, speedY
		// Et quand on verifie les collisions, on divise la vitesse à processSpeedX, processSpeedY pour que la collision sera plus precis
		private var speedStep:Number;
		private var processSpeedX:Number = 0;
		private var processSpeedY:Number = 0;
		private var speedX:Number;
		private var speedY:Number;
		
		private var oWidth:int;
		private var oHeight:int;
		
		private static var state:Number;
		private static var layerTransform:Transform;
		
		public function UncontrolableMovingSystem(stage:Stage) 
		{
			state = STATE_READY;
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		}
				
		override protected function onConstructed():void
		{
			super.onConstructed();
			
			uncontrolableEntities = entityManager.getFamily(allOfGenes(Transform, TextureResource, Uncontrolable, Velocity));
			controlableEntities = entityManager.getFamily(allOfGenes(Transform, TextureResource, Controlable));
			obstacleEntities = entityManager.getFamily(allOfGenes(Transform, Obstacle));
			gameOverEntities = entityManager.getFamily(allOfGenes(GameOver));
			levelCompletedEntities = entityManager.getFamily(allOfGenes(LevelCompleted));
			
			layerEntities = entityManager.getFamily(allOfGenes(Layer));
			
			transformMapper = geneManager.getComponentMapper(Transform);
			uncontrolableMapper = geneManager.getComponentMapper(Uncontrolable);
			velocityMapper = geneManager.getComponentMapper(Velocity);
			textureResourceMapper = geneManager.getComponentMapper(TextureResource);
			obstacleMapper = geneManager.getComponentMapper(Obstacle);
			layerMapper = geneManager.getComponentMapper(Layer);
			touchableMapper = geneManager.getComponentMapper(Touchable);
		}
		
		/**
		 * Affect new position de cet objet et verifier la collision
		 * @param	delta
		 */
		override protected function onProcess(delta:Number):void
		{
			for (var i:int = 0; i < uncontrolableEntities.members.length; i++)
			{	
				var e:IEntity = uncontrolableEntities.members[i]; 
				
				var transform:Transform = transformMapper.getComponent(e);
				var uncontrolable:Uncontrolable = uncontrolableMapper.getComponent(e);
				var velocity:Velocity = velocityMapper.getComponent(e);
				var texture:TextureResource = textureResourceMapper.getComponent(e);	
				
				if (uncontrolable.withPhysic)
				{
					transform.x = -texture.bitmapData.width * transform.scaleX / 2;
					transform.y = -texture.bitmapData.height * transform.scaleY / 2;
					
					// l'entite uncontrolable va rester avec le layer "ballLayer" donc il peut tourner
					if (layerTransform == null)
					{
						for (var j:int = 0; j < layerEntities.members.length; j++)
						{
							var eLayer:IEntity = layerEntities.members[j];
							var layer:Layer = layerMapper.getComponent(eLayer);
							
							if (layer.id == "ballLayer") 
							{
								layerTransform = transformMapper.getComponent(eLayer);
							}
						}
					}
					else 
					{
						// State_Moving - deplace l'entite
						if (state == STATE_MOVING)
						{
							if (velocity.speed == 0)
							{
								velocity.speed = 15;
							}
						}
						// State_Ready - attente le joueur presse le bouton SPACE pour commencer
						else if (state == STATE_READY) 
						{
							velocity.speed = 0;
							if (controlableEntities.members.length > 0)
							{
								var ce:IEntity = controlableEntities.members[0];
								var cTransform:Transform = transformMapper.getComponent(ce);
								var cTexture:TextureResource = textureResourceMapper.getComponent(ce);
								
								resetUncontrolableObject(cTransform, cTexture, texture, transform);
							}
							
						}
				
						// Tourner l'entite
						if (uncontrolable.angle <= 180)
						{
							layerTransform.addRotation(10);
						} 
						else 
						{
							layerTransform.addRotation(-10);
						}
							
						// Applique la nouvelle position et verifie les collision
						uncontrolable.x_global = transform.x + layerTransform.x;
						uncontrolable.y_global = transform.y + layerTransform.y;
						
						for (var k:int = 0; k < SPEEDSTEP; k++)
						{
							speedX = velocity.speed * Math.sin(uncontrolable.angle * Math.PI / 180);
							speedY = velocity.speed * Math.cos(uncontrolable.angle * Math.PI / 180);
							
							processSpeedX = speedX / SPEEDSTEP;
							processSpeedY = speedY / SPEEDSTEP;
							
							uncontrolable.x_global += processSpeedX;
							uncontrolable.y_global += processSpeedY;
							
							layerTransform.x += processSpeedX;
							layerTransform.y += processSpeedY;
							
							if (checkCollision(transform, uncontrolable, velocity, texture, layerTransform))
							{
								break;
							}
						}
					}
					
					// Si il passe a la plus bas de l'ecran => perdu 1 vie
					// L'entite retourne à STATE_READY
					if (layerTransform.y >= MAX_HEIGHT)
					{
						if (ScoreSystem(world.getSystemManager().getSystem(ScoreSystem)).getLive() > 0 && state == STATE_MOVING)
						{
							state = STATE_READY;
							ScoreSystem(world.getSystemManager().getSystem(ScoreSystem)).decreaseLive();
						}
						else if (ScoreSystem(world.getSystemManager().getSystem(ScoreSystem)).getLive() == 0)
						{
							state = STATE_READY;
							gameOver();
						}
					}
				}
				else 	// sans Physique
				{
					transform.x += velocity.speed * Math.sin(uncontrolable.angle * Math.PI / 180);
					transform.y += velocity.speed * Math.cos(uncontrolable.angle * Math.PI / 180);
				}
			}
			
			// CHECK LEVEL COMPLETED
			if (obstacleEntities.members.length == 3 + 1) // 3 BORDERs + 1 CONTROLABLE BRICK
			{
				state = STATE_READY;
				levelCompleted();
			}
		}
		
		/**
		 * Chercher tous les obstacles et appelle autre fonction pour verifier la collision avec chaque obstacle
		 * @param	transform : Transform component de cet objet
		 * @param	uncontrolable : Uncontrolabel component de cet objet
		 * @param	velocity : Velocity component de cet objet
		 * @param	texture : textureResource component de cet objet
		 * @param	layerTransform : transform component du layer qui contient cet objet
		 * @return
		 */
		private function checkCollision(transform:Transform, uncontrolable:Uncontrolable, 
									velocity:Velocity, texture:TextureResource, layerTransform:Transform):Boolean
		{
			var collided:Boolean = false;
			//Check collision with every obstacle
			for (var i:int = 0; i < obstacleEntities.members.length; i++)
			{
				var e:IEntity = obstacleEntities.members[i]; 
				
				var oTransform:Transform = transformMapper.getComponent(e);
				var oObstacle:Obstacle = obstacleMapper.getComponent(e);
				var oTexture:TextureResource = textureResourceMapper.getComponent(e);			
						
				if (checkCollisionEachObstacle(transform, texture, uncontrolable, oTransform, oTexture, oObstacle, layerTransform))
				{
					if (oObstacle.destructible) 
					{
						entityManager.killEntity(e);
						
						Main.playBreakSound();
						
						var enemyID:String = getId(CreateLevelSystem.curLvl);
						
						// Creer BREAK EFFECT
						for (var p:int = 0; p < NB_BREAK_PART; p++)
						{
							EntityFactory.createBreakEffectEntity(entityManager, 
																	oTransform.x, oTransform.y, 
																	"assets/pictures/break/break_" + enemyID + ".png", "break_" + enemyID, 
																	Math.random() * 1000 % 10 + 10, Math.random() * 10000 % 360,
																	"NONE", 30);
						}
						
						ScoreSystem(world.getSystemManager().getSystem(ScoreSystem)).addScore(15);						
					}
					collided = true;
					
				}
			}
			return collided;
		}
		
		/**
		 * Avec chaque obstacle :
			 * - Si il y a la collision 
			 * 		- Si il est un objet normal => change l'angle de cet objet par la reflection
			 * 		- Si il est un controlable objet => change l'angle par une calculation differente
			 * 			- Pour eviter le collision "stick" de cet objet et controlable objet a cause de la vitesse de controlabel > cela de cet objet
			 * 			  Si il y a deja une collision, la collision prochaine sera ete ignore'
			 * (on utilise la position du layer qui contient ce objet pour tester la collision)
		 * @param	transform1 : transform component de cet objet
		 * @param	texture1 : textureResource component de cet objet
		 * @param	uncontrolable1 : Uncontrolable component de cet objet
		 * @param	transform2 : transform component de l'obstacle
		 * @param	texture2 : textureResource component de l'obstacle
		 * @param	obstacle2 : Obstacle component de l'obstacle
		 * @param	layerTransform : transform component du layer qui contient cet objet
		 * @return
		 */
		private function checkCollisionEachObstacle(transform1:Transform, texture1:TextureResource, uncontrolable1:Uncontrolable,
										transform2:Transform, texture2:TextureResource, obstacle2:Obstacle,
										layerTransform:Transform):Boolean
		{
			var centerX:int = uncontrolable1.x_global + texture1.bitmapData.width * transform1.scaleX / 2;
			var centerY:int = uncontrolable1.y_global + texture1.bitmapData.height * transform1.scaleY / 2;
			
			var shortestX:int = centerX;
			var shortestY:int = centerY;
			
			var radius:int = texture1.bitmapData.width * transform1.scaleX / 2;
			
			if (texture2 != null && texture2.bitmapData != null) 
			{
				oWidth = texture2.bitmapData.width * transform2.scaleX;
				oHeight = texture2.bitmapData.height * transform2.scaleY;
			}
			else 
			{
				oWidth = obstacle2.oWidth;
				oHeight = obstacle2.oHeight;
			}
			
			if (centerX < transform2.x)
			{
				shortestX = transform2.x;
			}
			else if (centerX > transform2.x + oWidth)
			{
				shortestX = transform2.x + oWidth;
			}
			
			if (centerY < transform2.y)
			{
				shortestY = transform2.y;
			}
			else if (centerY > transform2.y + oHeight)
			{
				shortestY = transform2.y + oHeight;
			}
			
			var dx:int = centerX - shortestX;
			var dy:int = centerY - shortestY;
			
			if (radius * radius >= dx * dx + dy * dy) // => collision
			{
				//trace ("dx = " + dx + " dy = " + dy);
				if (obstacle2.justCollided == 0)
				{ 
					// Creer un round_zoom_out effect pour la collision
					EntityFactory.createEffectEntity(entityManager, shortestX, shortestY, "assets/pictures/collisionEffect_wall.png", 
																						"round", "ZOOM_OUT", 20);
					
					uncontrolable1.x_global -= processSpeedX;
					uncontrolable1.y_global -= processSpeedY;
				
					layerTransform.x -= processSpeedX;
					layerTransform.y -= processSpeedY;
					
					if (!obstacle2.specialPhysic)
					{
						//if (Math.abs(dx) < Math.abs(dy))
						if (dx == 0 || Math.abs(dy) - Math.abs(dx) >= 3)
						{
							if (uncontrolable1.angle <= 180)
							{
								uncontrolable1.angle = 180 - uncontrolable1.angle;
							}
							else 
							{
								uncontrolable1.angle = 360 - uncontrolable1.angle + 180;
							}
						}
						//else if (Math.abs(dx) > Math.abs(dy))
						else if (dy == 0 || Math.abs(dx) - Math.abs(dy) >= 3)
						{
							uncontrolable1.angle = 360 - uncontrolable1.angle;
						}
						else
						{
							//trace ("dx = dy " + dx + " " + dy + " angle " + uncontrolable1.angle);
							if (uncontrolable1.angle <= 90)
							{
								uncontrolable1.angle = 270 - uncontrolable1.angle;
							}
							else if (uncontrolable1.angle <= 180)
							{
								uncontrolable1.angle = 90 + 360 - uncontrolable1.angle;
							}
							else if (uncontrolable1.angle <= 270)
							{
								uncontrolable1.angle = 270 - uncontrolable1.angle;
							}
							else 
							{
								uncontrolable1.angle = 90 + 360 - uncontrolable1.angle;
							}
							//trace ("dx = dy aft " + dx + " " + dy + " angle " + uncontrolable1.angle
						}
					}
					else 
					{
						dx = centerX - transform2.x;
						dy = centerY - transform2.y;
						
						if (dx <= oWidth / 2)
						{
							if (dy <= 0) 
							{
								uncontrolable1.angle = 180 + (60 - 60 * dx / (oWidth / 2));
							}
							else 
							{
								uncontrolable1.angle = 360 - (60 - 60 * dx / (oWidth / 2));
							}
						}
						else 
						{
							if (dy <= 0) 
							{
								uncontrolable1.angle = 180 - 60 * (dx - oWidth / 2) / (oWidth / 2);
							}
							else 
							{
								uncontrolable1.angle = 60 * (dx - oWidth / 2) / (oWidth / 2);
							}
						}
						
						obstacle2.justCollided++;
					}
					return true;
				}
				else 
				{
					obstacle2.justCollided = (obstacle2.justCollided + 1) % 20;
				}
			}
			else 
			{
				obstacle2.justCollided = 0;
			}
			return false;
		}
		
		public static function resetUncontrolableMovingSystem():void
		{
			layerTransform = null;
			
			state = STATE_READY;
		}
		
		// On commence le jeu quand le joueur presse SPACE
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.charCode == 32) // SPACE BUTTON
			{
				if (uncontrolableEntities.members.length > 0 && !Main.isPause)
				{
					state = STATE_MOVING;
				}
			}
		}
		
		/*
		 * Reset la position de l'objet uncontrolable ( quand le joueur perde une vie )
		 */
		public static function resetUncontrolableObject(controlableTransform:Transform, controlableTexutre:TextureResource,
														texutre:TextureResource, transform:Transform):void
		{
			if (layerTransform != null)
			{
				layerTransform.x = controlableTransform.x + controlableTexutre.bitmapData.width * controlableTransform.scaleX / 2;
				layerTransform.y = controlableTransform.y - texutre.bitmapData.height * transform.scaleY / 2;
			}
		}
		
		/**
		 * Quand le jeu est fini ( le jouer est perdu ) 
		 * - mis à jour l'haut-score si necessaire
		 * - afficher le ecran de l'haut-score
		 */
		public function gameOver():void
		{
			Main.pause();
			
			if (!ScoreSystem.updateHighScore())
			{
				for (var g:int = 0; g < gameOverEntities.members.length; g++)
				{
					var ge:IEntity = gameOverEntities.members[g];
					var gTransform:Transform = transformMapper.getComponent(ge);
					var gTouchable:Touchable = touchableMapper.getComponent(ge);
									
					if (gTransform != null)
					{
						gTransform.alpha = 0.8;
					}
					
					if (gTouchable != null)
					{
						gTouchable.enabled = true;
					}
				}
			}
			else 
			{
				Main.resume();
				TouchableSystem(world.getSystemManager().getSystem(TouchableSystem)).removeAllEntities();
				Main.createHighscore();
			}
		}
		
		/**
		 * Le joueur complete un niveau, on affiche le bouton pour passer le niveau suivant
		 */
		public function levelCompleted():void
		{
			Main.pause();
			
			for (var l:int = 0; l < levelCompletedEntities.members.length; l++)
			{
				var le:IEntity =  levelCompletedEntities.members[l];
				var lTransform:Transform = transformMapper.getComponent(le);
				var lTouchable:Touchable = touchableMapper.getComponent(le);
								
				if (lTransform != null)
				{
					lTransform.alpha = 0.8;
				}
				
				if (lTouchable != null)
				{
					lTouchable.enabled = true;
				}
			}
		}
		
		/**
		 * Ce fonction retourne le nom du image pour creer les effets "break"
		 * @param	curLvl - le niveau courant
		 * @return
		 */
		private function getId(curLvl:int): String
		{
			switch (curLvl)
			{
				case 1: return "finland";
				case 2:	return "mexico";
				case 3: return "denmark";
				case 4: return "cameroon";
				case 5: return "portugal";
				case 6: return "netherlands";
				case 7: return "germany";
				case 8: return "england";
				case 9: return "spain";
				case 10: return "brazil";
				default: return "vietnam";
			}
		}
	}

}