package 
{
	
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.IWorld;
	import com.ktm.genome.core.logic.process.ProcessManager;
	import com.ktm.genome.core.logic.system.ISystemManager;
	import com.ktm.genome.render.system.RenderSystem;
	import com.ktm.genome.core.BigBang;
	import com.ktm.genome.resource.manager.ResourceManager;
	import com.ktm.genome.core.logic.process.ProcessPhase;
	import com.ktm.genome.resource.component.EntityBundle;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	import systems.GuideSystem;
	import systems.EffectSystem;
	import systems.ScoreSystem;
	import systems.TouchableSystem;
	import systems.ControlableMovingSystem;
	import systems.CreateLevelSystem;
	import systems.UncontrolableMovingSystem;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Vietlm
	 */
	public class Main extends Sprite 
	{
		private static const gameURL:String = 'assets/xml/gameBricks.entityBundle.xml';
		private static const levelURL:String = 'assets/xml/level.entityBundle.xml';		
		private static const levelSelectURL:String = 'assets/xml/levelSelect.entityBundle.xml';
		private static const mainMenuURL:String = 'assets/xml/mainMenu.entityBundle.xml';
		private static const highscoreURL:String = 'assets/xml/highscore.entityBundle.xml';
		
		private static const NUM_COL:Number = 5;
		private static const NUM_ROW:Number = 2;
		private static const SPACE_HOR:Number = 10;
		private static const SPACE_VER:Number = 10;
		private static const OFFSET_HOR:Number = 130;
		private static const OFFSET_VER:Number = 200;
		private static const SIZE_LVL_IMG:Number = 100;
		
		public static const NUM_LEVEL:Number = 10;
		
		public static const IN_MAINMENU:Number = 0;
		public static const IN_SELECTLEVEL:Number = 1;
		public static const IN_HIGHSCORE:Number = 2;
		public static const IN_GAME:Number = 3;
		
		private static var world:IWorld;
		private static var sm:ISystemManager;
		private static var pm:ProcessManager;
		
		private static var breakSound:Sound;
		
		public static var isPause:Boolean = false;
		public static var isSavedScore:Boolean = false;
		public static var inState:Number = 0;
		
		public function Main():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, start);
		}
		
		public function start(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, start);
			
			// Creation du monde, c'est la premiere chose a faire
			world = BigBang.createWorld(stage);
			
			// Recuperation du gestionnaire de systeme
			sm = world.getSystemManager();
			
			pm = world.getProcessManager();
			
			// Grace au gestionnaire de systeme, on va pouvoir definir les systeme a executer
			
			// ici on lance le ResourceManager de Genome qui permet de gerer l'ensemble des resources
			sm.setSystem(ResourceManager).setProcess(ProcessPhase.TICK, int.MAX_VALUE);
			// puis le RenderSystem qui travaille sur les familles (Layer) et (Transform et un type de Resource
			// (SceneResource, SymbolResource, TextureResource, DisplayInstance, DisplaySymbol))
			sm.setSystem(new RenderSystem(this)).setProcess(ProcessPhase.FRAME);
			
			// On lance aussi les systemes propres a notre projet
			sm.setSystem(new ControlableMovingSystem(this.stage)).setProcess();	
			sm.setSystem(new UncontrolableMovingSystem(this.stage)).setProcess();
			sm.setSystem(new TouchableSystem(this.stage)).setProcess();
			sm.setSystem(new EffectSystem()).setProcess();
			sm.setSystem(new CreateLevelSystem()).setProcess();
			sm.setSystem(new ScoreSystem()).setProcess();
			sm.setSystem(new GuideSystem(this.stage)).setProcess();
			
			// Creer ce ressource pour sauvegarder les donnees du brique de chaque niveau
			// Creer seulement 1 fois car on ne suprimera pas
			EntityFactory.createResourcedEntity(world.getEntityManager(), levelURL, "level", EntityBundle);
			
			loadSound();
			createMenu();
		}
		
		/**
		 * Charger un fichier de son dans un variable du systeme
		 */
		public function loadSound():void
		{
			breakSound = new Sound();
			breakSound.load(new URLRequest("assets/sounds/BrickBreak.mp3")); 
		}
		
		/**
		 * Jouer le jichier de son
		 */
		public static function playBreakSound():void
		{
			breakSound.play();
		}  
		
		/**
		 * Creer l'ecran Menu pour le jeu 
		 */
		public static function createMenu():void
		{
			EntityFactory.createResourcedEntity(world.getEntityManager(), mainMenuURL, "menu", EntityBundle);
			
			// Le state du jeu est IN_MAINMENU maintenant.
			inState = IN_MAINMENU;
		}
		
		/**
		 * Creer l'ecran Menu de la selection des niveaux pour le jeu
		 */
		public static function createLevelSelect():void
		{
			EntityFactory.createResourcedEntity(world.getEntityManager(), levelSelectURL, "levelSelect", EntityBundle);
			
			for (var i:int = 0; i < NUM_LEVEL; i++)
			{
				pm.callLater(pm.callLater, EntityFactory.createLevelButtonEntity, world.getEntityManager(), 
													OFFSET_HOR + (SIZE_LVL_IMG + SPACE_HOR) * (i % NUM_COL),
													(OFFSET_VER + (SIZE_LVL_IMG + SPACE_VER) * (int)(i / NUM_COL)), 
													i + 1);
			}
			
			// Le state du jeu est IN_SELECTLEVE maintenant.
			inState = IN_SELECTLEVEL;
		}
		
		/**
		 * Creer l'ecran GAME - l'ecran principal pour le jeu
		 * - level : le niveau courant
		 */
		public static function createGame(level:Number):void
		{
			// Creer le map du brique pour ce niveau
			CreateLevelSystem.createLevel(level);
			
			// on fini enfin par charger les xml afin de creer automatiquement les entites composants le projet
			EntityFactory.createResourcedEntity(world.getEntityManager(), gameURL, "game", EntityBundle);
			
			// Le state du jeu est IN_GAME maintenant.
			inState = IN_GAME;
		}
		
		/**
		 * Creer l'ecran Haut-Score pour le jeu
		 */
		public static function createHighscore():void
		{
			EntityFactory.createResourcedEntity(world.getEntityManager(), highscoreURL, "highscore", EntityBundle);
			
			// Le state du jeu est IN_HIGHSCORE maintenant.
			inState = IN_HIGHSCORE;
		}
		
		/**
		 * Passer au niveau suivant
		 */
		public static function next():void
		{
			// sauvegarder le score du joueur
			isSavedScore = true;
			
			CreateLevelSystem.nextLevel();
			
			// on fini enfin par charger les xml afin de creer automatiquement les entites composants le projet
			EntityFactory.createResourcedEntity(world.getEntityManager(), gameURL, "game", EntityBundle);
			
			inState = IN_GAME;
		}
		
		/**
		 * Re-initialiser le niveau courant
		 */
		public static function reset():void 
		{
			world.getProcessManager().callLater(EntityFactory.createResourcedEntity, world.getEntityManager(), gameURL, "game", EntityBundle);
			CreateLevelSystem.recreate();
		}
		
		/**
		 * Pause - arreter les systemes qui effectuer les motions sur l'ecran et les changements de logique du jeux
		 */
		public static function pause():void
		{
			sm.getSystem(ControlableMovingSystem).pause();
			sm.getSystem(UncontrolableMovingSystem).pause();
			sm.getSystem(CreateLevelSystem).pause();
			sm.getSystem(TouchableSystem).pause();
			sm.getSystem(EffectSystem).pause();
			sm.getSystem(ScoreSystem).pause();
			sm.getSystem(GuideSystem).pause();
			
			isPause = true;
		}
		
		/**
		 * Resume - reprendre les systemes qui effectuer les motions sur l'ecran et les changements de logique du jeux
		 */
		public static function resume():void
		{
			sm.getSystem(ControlableMovingSystem).resume();
			sm.getSystem(UncontrolableMovingSystem).resume();
			sm.getSystem(CreateLevelSystem).resume();
			sm.getSystem(TouchableSystem).resume();
			sm.getSystem(EffectSystem).resume();
			sm.getSystem(ScoreSystem).resume();
			sm.getSystem(GuideSystem).resume();
			
			isPause = false;
		}
	}
	
}