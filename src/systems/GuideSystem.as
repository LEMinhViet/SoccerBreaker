package systems 
{
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.render.component.Transform;
	import com.ktm.genome.resource.component.TextureResource;
	import com.ktm.genome.core.data.component.IComponentMapper;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.logic.system.System;
	
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
	
	import components.Guide;
	
	/**
	 * Cette classe affiche les entite pour guider le joueur dans ce jeu
	 * @author Vietlm
	 */
	public class GuideSystem extends System 
	{
		private var guideEntities:Family;
		
		private var transformMapper:IComponentMapper;
		private var textureResourceMapper:IComponentMapper;
		
		public function GuideSystem(stage:Stage) 
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		}
		
		override protected function onConstructed():void
		{
			super.onConstructed();
			
			guideEntities = entityManager.getFamily(allOfGenes(Guide));
						
			transformMapper = geneManager.getComponentMapper(Transform);
			textureResourceMapper = geneManager.getComponentMapper(TextureResource);
		}
	
		override protected function onProcess(delta:Number):void
		{
			
		}
		
		/**
		 * Le joueur doit presse SPACE pour commence le jeu
		 * @param	e
		 */
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.charCode == 32) // SPACE BUTTON
			{
				for (var i:int = 0; i < guideEntities.members.length; i++)
				{
					entityManager.killEntity(guideEntities.members[i]);
				}
			}
		}
		
		/**
		 * Creer les images pour guider le joueur
		 * @param	level - le niveau courant
		 */
		public function createGuideInterface(level:int):void
		{
			EntityFactory.createGuideEntity(entityManager, 200, 250, "assets/pictures/levelTitle.png", "levelTitle");
			EntityFactory.createGuideEntity(entityManager, 500, 250, "assets/pictures/lvls/lvl" + level + ".png", "level" + level);
			EntityFactory.createGuideEntity(entityManager, 50, 350, "assets/pictures/pressToStart.png", "pressToStart");
		}
	}

}