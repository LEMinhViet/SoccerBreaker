package systems 
{
	import com.ktm.genome.core.logic.process.ProcessManager;
	import com.ktm.genome.core.logic.system.System;
	import com.ktm.genome.core.entity.family.matcher.allOfFlags;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import com.ktm.genome.core.entity.family.matcher.noneOfGenes;
	import com.ktm.genome.economy.vo.Transaction;
	import com.ktm.genome.render.component.Transform;
	import com.ktm.genome.resource.component.TextureResource;
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.data.component.IComponentMapper;
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.render.component.Layered;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.errors.IOError;
	
	import components.Effect;
	import components.Numericable;
	
	/**
	 * ...
	 * @author Vietlm
	 */
	public class ScoreSystem extends System 
	{
		private static const MAX_LIVE:Number = 3;
		
		// SCORE a 5 chiffres maximaux, donc on a la position pour les 5 chiffres
		private static const POS_SCORE_1:Number = 200;
		private static const POS_SCORE_2:Number = 235;
		private static const POS_SCORE_3:Number = 270;
		private static const POS_SCORE_4:Number = 305;
		private static const POS_SCORE_5:Number = 340;
		
		// La position pour les 2 chiffres de vie de joueur
		private static const POS_LIVE_1:Number = 600;
		private static const POS_LIVE_2:Number = 635;
		
		private var scoreEntities:Family;		
		private var transformMapper:IComponentMapper;
		private var textureResourceMapper:IComponentMapper;
		
		// L'array qui contient les entites qui vont être supprimé quand le score change
		private var deleteEntityArray:Array = new Array(5);
		// Le longeur de l'array
		private var realLength:Number = 0;
		
		private var live:int;
		private var temp:int;
		
		private var pm:ProcessManager
		
		private static var score:int;
		private static var highscore:int;
		
		public function ScoreSystem() 
		{
			loadHighScore();
			//pm = world.getProcessManager();
		}
		
		override protected function onConstructed():void
		{
			super.onConstructed();
			
			scoreEntities = entityManager.getFamily(allOfGenes(Numericable));
						
			transformMapper = geneManager.getComponentMapper(Transform);
			textureResourceMapper = geneManager.getComponentMapper(TextureResource);
			
			pm = world.getProcessManager();
		}
		
		/**
		 * Pour chaque frame, on verifie que le score change ou non, si il change, on supprime les entites anciens
		 * et ajoute les nouveaux pour le nouveau score.
		 * @param	delta
		 */
		override protected function onProcess(delta:Number):void
		{
			// Si on commence un jeu, retourne le score à 0
			if (Main.inState == Main.IN_GAME && scoreEntities.members.length == 0)
			{
				resetScoreSystem();
			}
			
			// Si c'est l'ecran de haut-score, affiche le score
			if (Main.inState == Main.IN_HIGHSCORE && scoreEntities.members.length == 0)
			{
				displayHighscore();
			}
			
			if (Main.inState == Main.IN_GAME)
			{
				for (var i:Number = 0; i < scoreEntities.members.length; i++)
				{
					var e:IEntity = scoreEntities.members[i];
					var transform:Transform = transformMapper.getComponent(e);
					var texture:TextureResource = textureResourceMapper.getComponent(e);
					
					if (transform.x == POS_SCORE_1) 	 {	temp = score / 10000;		}
					else if (transform.x == POS_SCORE_2) {	temp = (score / 1000) % 10;	}
					else if (transform.x == POS_SCORE_3) {	temp = (score / 100) % 10;	}
					else if (transform.x == POS_SCORE_4) {	temp = (score / 10) % 10;	}
					else if (transform.x == POS_SCORE_5) {	temp = score % 10;			}
					
					else if (transform.x == POS_LIVE_1) {	temp = live / 10;	}
					else if (transform.x == POS_LIVE_2) {	temp = live % 10;	}
					
					if (texture.source == "assets/pictures/lvls/lvl" + temp.toString() + ".png")
					{
						continue;
					}
					else 
					{
						pm.callLater(pm.callLater, pm.callLater, EntityFactory.createNumberEntity, entityManager, transform.x, transform.y, 0.3, temp);
						
						deleteEntityArray[realLength] = e;
						realLength++;
					}
				}
				
				for (i = 0; i < realLength; i++)
				{
					if (deleteEntityArray[i] != null)
					{
						entityManager.killEntity(deleteEntityArray[i]);
					}
				}
				realLength = 0;
			}
		}
		
		/**
		 * ResetScoreSystem 
		 * Dans ce fonction on cree les nouveaux entites qui sont 0 pour commencer un nouveau jeu
		 * et aussi les entites pour les vies du joueur
		 */
		public function resetScoreSystem():void
		{
			if (Main.isSavedScore)
			{
				Main.isSavedScore = false;
			}
			else
			{
				score = 0;
			}
			live = MAX_LIVE;
			
			EntityFactory.createNumberEntity(entityManager, 200, 10, 0.3, 0);
			EntityFactory.createNumberEntity(entityManager, 235, 10, 0.3, 0);
			EntityFactory.createNumberEntity(entityManager, 270, 10, 0.3, 0);
			EntityFactory.createNumberEntity(entityManager, 305, 10, 0.3, 0);
			EntityFactory.createNumberEntity(entityManager, 340, 10, 0.3, 0);
			
			EntityFactory.createNumberEntity(entityManager, 600, 10, 0.3, 0);
			EntityFactory.createNumberEntity(entityManager, 635, 10, 0.3, 0);
		}
		
		/**
		 * Display le score dans l'ecran haut-score, les entites vont plus grands et il seront au centre de l'ecran.
		 */
		public function displayHighscore():void
		{
			world.getProcessManager().callLater(EntityFactory.createNumberEntity, entityManager, 110, 240, 1.0, highscore / 10000);
			world.getProcessManager().callLater(EntityFactory.createNumberEntity, entityManager, 230, 240, 1.0, (highscore / 1000) % 10);
			world.getProcessManager().callLater(EntityFactory.createNumberEntity, entityManager, 350, 240, 1.0, (highscore / 100) % 10);
			world.getProcessManager().callLater(EntityFactory.createNumberEntity, entityManager, 470, 240, 1.0, (highscore / 10) % 10);
			world.getProcessManager().callLater(EntityFactory.createNumberEntity, entityManager, 590, 240, 1.0, highscore % 10);
		}
		
		public function addScore(add:Number):void
		{
			score += add;
		}
		
		/**
		 * Sauvegarder le haut-score dans un fichier "highscore.txt" dans la repetoire de cet application
		 */
		public static function saveHighScore():void
		{
			var myFile:File = File.applicationStorageDirectory.resolvePath("highscore.txt");
			
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(myFile, FileMode.WRITE);      
				
				fs.writeUTFBytes(score.toString());
			} 
			catch (e:IOError) 
			{
				
			}
			
			fs.close();
		}
		
		/**
		 * Charger le haut-score dans le fichier "highscore.txt" à l'application 
		 */
		public function loadHighScore():void
		{
			var myFile:File = File.applicationStorageDirectory.resolvePath("highscore.txt");
			
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(myFile, FileMode.READ);    
				
				highscore = int(fs.readUTFBytes(fs.bytesAvailable));
			} 
			catch (e:IOError) 
			{
				highscore = 0;
			}
			
			fs.close();
		}
		
		/**
		 * Si il y a un score qui est superieur à haut-score, mis à jour le haut-score du jeu.
		 * @return : TRUE si le mis à jour est succes
		 */
		public static function updateHighScore():Boolean
		{
			if (score > highscore)
			{
				// HIGH SCORE
				highscore = score;
				saveHighScore();
				return true;
			}
			
			return false;
		}
		
		public function decreaseLive():void
		{
			live--;
		}
		
		public function getLive():Number
		{
			return live;
		}
	}

}