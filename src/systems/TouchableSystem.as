package systems 
{
	import com.ktm.genome.core.data.component.IComponent;
	import com.ktm.genome.core.data.component.IComponentMapper;
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import com.ktm.genome.core.entity.family.matcher.noneOfGenes;
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.core.logic.system.System;
	import com.ktm.genome.render.component.Transform;
	import com.ktm.genome.resource.component.TextureResource;
	import com.ktm.genome.core.data.gene.Gene;
	import com.ktm.genome.resource.component.EntityBundle;
	
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.desktop.NativeApplication;
	import com.ktm.genome.render.system.RenderSystem;
	
	import components.Touchable;
	import components.Pause;
	import components.InGameButton;
	
	/**
	 * ...
	 * @author Vietlm
	 */
	
	 /**
	  * TouchableSystem : Controler les objet qui contient le component Touchable :
		  * - Button 
		  * - Niveau ( dans l'ecran Menu )
	  */
	public class TouchableSystem extends System 
	{
		private var stage:Stage;
		
		private var touchableEntities:Family;
		private var pauseEntities:Family;
		private var gameEntities:Family;
		
		private var allEntities:Family
		
		private var touchableMapper:IComponentMapper;
		private var transformMapper:IComponentMapper;
		private var textureMapper:IComponentMapper;
		
		/**
		 * Constructor de la classe, implementer d'ecouter 2 evenement : Mouse_Down et Mouse_Up
		 * @param	stage 
		 */
		public function TouchableSystem(stage:Stage) 
		{
			this.stage = stage;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		override protected function onConstructed():void
		{
			super.onConstructed();
			
			touchableEntities = entityManager.getFamily(allOfGenes(Touchable, Transform, TextureResource));
			pauseEntities = entityManager.getFamily(allOfGenes(Pause));
			gameEntities = entityManager.getFamily(allOfGenes(InGameButton));
			
			allEntities = entityManager.getFamily(allOfGenes(Transform));
			
			touchableMapper = geneManager.getComponentMapper(Touchable);
			transformMapper = geneManager.getComponentMapper(Transform);
			textureMapper = geneManager.getComponentMapper(TextureResource);
		}
		
		/**
		 * Executer quand il y a un evenement Mouse_Down
		 * @param	e : informations sur le souris
		 */
		private function onMouseDown(e:MouseEvent):void
		{
			for (var i:int = 0; i < touchableEntities.members.length; i++)
			{
				var ie:IEntity = touchableEntities.members[i];
				var touchable:Touchable = touchableMapper.getComponent(ie);
				var transform:Transform = transformMapper.getComponent(ie);
				var texture:TextureResource = textureMapper.getComponent(ie);
				
				if (contain(transform, texture, e))
				{
					doMouseDownFunction(touchable, transform, texture);
				}
			}
		}
		
		/**
		 * Creer quelque effet quand il y a un evenement Mouse_Down :
		 * @param	touchable : Touchable component du objet de Touchable
		 * @param	transform : Transform component du objet de Touchable
		 */
		private function doMouseDownFunction(touchable:Touchable, transform:Transform, texture:TextureResource):void
		{
			if (touchable.enabled)
			{
				if (touchable.intent == "GAME_PAUSE")
				{
					transform.alpha = 1;
				}
				else if (touchable.intent == "GAME_RESUME")
				{
					transform.alpha = 1;
				}
				else if (touchable.intent == "GAME_RESET")
				{
					transform.alpha = 1;
				}
				else if (touchable.intent == "GAME_BACK")
				{
					transform.alpha = 1;
				}
				else if (touchable.intent == "MENU_START")
				{
					transform.alpha = 0.5;
				}
				else if (touchable.intent == "MENU_HIGHSCORE")
				{
					transform.alpha = 0.5;
				}
				else if (touchable.intent == "MENU_EXIT")
				{
					transform.alpha = 0.5;
				}		
				else if (touchable.intent == "LEVEL_SELECT")
				{
					transform.alpha = 0.5;
				}
				else if (touchable.intent == "LEVEL_BACK")
				{
					transform.alpha = 0.5;
				}
			}
		}
		
		/**
		 * Executer quand il y a un evenement Mouse_Up
		 * @param	e : informations sur le souris
		 */
		private function onMouseUp(e:MouseEvent):void
		{
			for (var i:int = 0; i < touchableEntities.members.length; i++)
			{
				var ie:IEntity = touchableEntities.members[i];
				var touchable:Touchable = touchableMapper.getComponent(ie);
				var transform:Transform = transformMapper.getComponent(ie);
				var texture:TextureResource = textureMapper.getComponent(ie);
				
				if (contain(transform, texture, e))
				{
					doMouseUpFunction(ie, touchable, transform, texture);
				}
			}
		}
		
		/**
		 * Creer quelque effet quand il y a un evenement Mouse_Up
		 * Pour chaque intent du bouton que le jouer a appuyé, on a des effets differents pour le systeme
		 * @param	touchable : Touchable component du objet de Touchable
		 * @param	transform : Transform component du objet de Touchable
		 */
		private function doMouseUpFunction(ie:IEntity, touchable:Touchable, transform:Transform, texture:TextureResource):void
		{
			var j:int;
			var pe:IEntity;
			var pTransform:Transform;
			var pTouchable:Touchable;
			
			if (touchable.enabled)
			{
				if (touchable.intent == "GAME_PAUSE")
				{
					Main.pause();
				
					for (j = 0; j < pauseEntities.members.length; j++)
					{
						pe = pauseEntities.members[j];
						pTransform = transformMapper.getComponent(pe);
						pTouchable = touchableMapper.getComponent(pe);
						
						if (pTransform != null)
						{
							pTransform.alpha = 0.8;
						}
						
						if (pTouchable != null)
						{
							pTouchable.enabled = true;
						}
					}
					
					// desactiver la button PAUSE
					for (j = 0; j < gameEntities.members.length; j++)
					{
						pe = gameEntities.members[j];
						pTransform = transformMapper.getComponent(pe);
						pTouchable = touchableMapper.getComponent(pe);
						
						if (pTransform != null)
						{
							pTransform.alpha = 0.8;
						}
						
						if (pTouchable != null)
						{
							pTouchable.enabled = false;
						}
					}
				}
				else if (touchable.intent == "GAME_RESUME")
				{
					Main.resume();
						
					for (j = 0; j < pauseEntities.members.length; j++)
					{
						pe = pauseEntities.members[j];
						pTransform = transformMapper.getComponent(pe);
						pTouchable = touchableMapper.getComponent(pe);
						
						if (pTransform != null)
						{
							pTransform.alpha = 0;
						}
						
						if (pTouchable != null)
						{
							pTouchable.enabled = false;
						}
					}					
					
					for (j = 0; j < gameEntities.members.length; j++)
					{
						pe = gameEntities.members[j];
						pTransform = transformMapper.getComponent(pe);
						pTouchable = touchableMapper.getComponent(pe);
						
						if (pTransform != null)
						{
							pTransform.alpha = 0.8;
						}
						
						if (pTouchable != null)
						{
							pTouchable.enabled = true;
						}						
					}
				}
				else if (touchable.intent == "GAME_RESET")
				{
					transform.alpha = 0.8;

					Main.resume();
					removeAllEntities();
					Main.reset();
				}
				else if (touchable.intent == "GAME_BACK")
				{
					transform.alpha = 0.8;
					
					Main.resume();
					removeAllEntities();
					Main.createLevelSelect();
				}
				else if (touchable.intent == "GAME_NEXT")
				{
					transform.alpha = 0.8;
					
					Main.resume();
					removeAllEntities();
					if (CreateLevelSystem.curLvl != Main.NUM_LEVEL)
					{
						Main.next();
					}
					else 
					{
						ScoreSystem.updateHighScore();
						Main.createHighscore();
					}
				}
				else if (touchable.intent == "MENU_START")
				{
					transform.alpha = 1;
					
					removeAllEntities();
					Main.createLevelSelect();
				}
				else if (touchable.intent == "MENU_HIGHSCORE")
				{
					transform.alpha = 1;
					
					removeAllEntities();
					Main.createHighscore();
				}
				else if (touchable.intent == "MENU_EXIT")
				{
					transform.alpha = 1;
					
					NativeApplication.nativeApplication.exit();
				}		
				else if (touchable.intent == "MENU_SOUND")
				{
					
				}
				else if (touchable.intent == "LEVEL_SELECT")
				{
					transform.alpha = 1;
					
					removeAllEntities();
					Main.createGame(touchable.parameter);
				}
				else if (touchable.intent == "LEVEL_BACK")
				{
					transform.alpha = 1;
					
					removeAllEntities();
					Main.createMenu();
				}
			}
		}
		
		/**
		 * Verifier si un objet contient une pointe
		 * @param	transform - Transform Component du objet
		 * @param	texture - TextureResourece Component du objet
		 * @param	e - informations de la pointe
		 * @return : true si contient - false si non
		 */
		private function contain(transform:Transform, texture:TextureResource, e:MouseEvent):Boolean
		{
			return(e.localX >= transform.x && e.localX <= transform.x + texture.bitmapData.width 
				&& e.localY >= transform.y && e.localY <= transform.y + texture.bitmapData.height);
		}
		
		/**
		 * Supprimer tous les objets sur l'ecran
		 */
		public function removeAllEntities():void
		{
			for (var i:int = 0; i < allEntities.members.length; i++)
			{
				entityManager.killEntity(allEntities.members[i]);
			}
		}
	}

}