package systems 
{
	import com.ktm.genome.core.logic.system.System;
	import com.ktm.genome.core.entity.IEntityManager;
	import com.ktm.genome.core.data.component.IComponentMapper;
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.render.component.Transform;
	
	import flash.display.Stage;
	import components.BrickMap;
		
	/**
	 * Ce systeme utilise le valeur dans l'entite BrickMap et cree les entites pour chaque niveau
	 * @author VietLM
	 */
	public class CreateLevelSystem extends System 
	{
		// Les espaces entre les entites
		private const MAP_HOR_SPACE:Number = 55;
		private const MAP_VER_SPACE:Number = 40;
		private const BRICK_WIDTH:Number = 40;
		private const BRICK_HEIGHT:Number = 25;
		private const SPACE_BETWEEN_HOR:Number = 5;
		private const SPACE_BETWEEN_VER:Number = 5;
		
		private var brickMapEntities:Family;
		private var brickMapMapper:IComponentMapper;
		
		// Le variable qui indique le map est deja cree ou non
		private static var created:Boolean = false;
		
		// le niveau courant
		public static var curLvl:Number = 0;
		
		override protected function onConstructed():void
		{
			super.onConstructed();
			
			brickMapEntities = entityManager.getFamily(allOfGenes(BrickMap));			
			
			brickMapMapper = geneManager.getComponentMapper(BrickMap);
		}
		
		/**
		 * Creer le map des briques pour chaque level
		 * @param	delta
		 */
		override protected function onProcess(delta:Number):void
		{
			if (!created && curLvl != 0)
			{
				for (var i:int = 0; i < brickMapEntities.members.length; i++)
				{
					var e:IEntity = brickMapEntities.members[i];
					var brickmap:BrickMap = brickMapMapper.getComponent(e);
					if (brickmap.lvl == curLvl)
					{
						var row:int = 0;
						var col:int = 0;
						
						for (var j:int = 0; j < brickmap.map.length; j++)
						{
							// Si la valeur dans l'entite brickmap est 1, on cree un nouveau entite "BRICK"
							if (brickmap.map.charAt(j) == '1')
							{
								EntityFactory.createBrickEntity(entityManager, MAP_HOR_SPACE + (BRICK_WIDTH + SPACE_BETWEEN_HOR) * col, 
																			MAP_VER_SPACE + (BRICK_HEIGHT + SPACE_BETWEEN_VER) * row, getBrickSource(curLvl), getId(curLvl));
								col++;
								created = true;
							}
							// Si la valeur est 0, on passe a la colonne suivante
							else if (brickmap.map.charAt(j) == '0')
							{
								col++;
							}
							// Si la valeur est " ", on passe à la rangée suivante
							else 
							{
								col = 0; 
								row++;
							}
						}
					}
				}
				
				// Apres la creation des entites "brick", on cree les entites pour guider les joueur à commencer le jeu
				GuideSystem(world.getSystemManager().getSystem(GuideSystem)).createGuideInterface(curLvl);
			}
		}
		
		/**
		 * Ce fonction retourne l'adresse de l'image pour les briques dans chaque niveau 
		 * @param	curLvl - le niveau courant
		 * @return
		 */
		private function getBrickSource(curLvl:int): String
		{
			switch (curLvl)
			{
				case 1: return "assets/pictures/nations/finland.png";
				case 2:	return "assets/pictures/nations/mexico.png";
				case 3: return "assets/pictures/nations/denmark.png";
				case 4: return "assets/pictures/nations/cameroon.png";
				case 5: return "assets/pictures/nations/portugal.png";
				case 6: return "assets/pictures/nations/netherlands.png";
				case 7: return "assets/pictures/nations/germany.png";
				case 8: return "assets/pictures/nations/england.png";
				case 9: return "assets/pictures/nations/spain.png";
				case 10: return "assets/pictures/nations/brazil.png";
				default: return "assets/pictures/nations/vietnam.png";
			}
		}
		
		/**
		 * Ce fonction retourne le nom de l'image pour les briques dans chaque niveau 
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
		
		/**
		 * Re-creer le map ( dans le cas "reset" du jeu )
		 */
		public static function recreate(): void
		{
			created = false;
			
			UncontrolableMovingSystem.resetUncontrolableMovingSystem();
		}
		
		/**
		 * Creer le map du niveau suivant ( dans le cas le joueur complete un niveau )
		 */
		public static function nextLevel():void
		{
			curLvl++;
			recreate();
		}
		
		/**
		 * Creer le map
		 */
		public static function createLevel(lvl:Number):void
		{
			curLvl = lvl;
			recreate();
		}
	}
}