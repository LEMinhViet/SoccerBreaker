package systems 
{
	import com.ktm.genome.core.data.component.IComponent;
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.core.logic.system.System;
	import com.ktm.genome.render.component.Transform;
	import com.ktm.genome.resource.component.TextureResource;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import com.ktm.genome.core.data.component.IComponentMapper;
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import com.ktm.genome.core.entity.family.matcher.noneOfGenes;
	import com.ktm.genome.core.entity.family.matcher.allOfFlags;
	import com.ktm.genome.core.entity.family.matcher.noneOfFlags;
	
	import components.Controlable;
	import components.Velocity;
	import components.Obstacle;
	import components.Uncontrolable;
	
	/**
	 * ...
	 * @author Vietlm
	 */
	public class ControlableMovingSystem extends System 
	{
		private var pressed:Object;
		
		private var controlableEntities:Family;
		private var backgroundEntity:Family;
		
		// Les variables contiennent les information du controlable objet
		private var transformMapper:IComponentMapper;
		private var controlableMapper:IComponentMapper;
		private var velocityMapper:IComponentMapper;
		private var textureResourceMapper:IComponentMapper;
		
		// Les variables contiennent les information du background
		private var bg:IEntity;
		private var bgTransform:Transform;
		private var bgTexture:TextureResource;
		
		private var moved:Boolean = false;
		
		public function ControlableMovingSystem(stage:Stage) 
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,   keyUpHandler);
			
			pressed = new Object();
		}
		
		
		/**
		 * Cet ecouteur est appele lorsqu'une touche est pressee (down)
		 * Mise en cache de l'etat de pression de cette touche
		 */
		private function keyDownHandler(event:KeyboardEvent):void 
		{
			//trace("Keycode " + event.keyCode + " " + String.fromCharCode(event.keyCode));
			pressed[event.keyCode] = true;
		}
		
		/**
		 * Cet ecouteur est appele lorsqu'une touche est relachee (up)
		 * Mise en cache de l'etat de pression de cette touche
		 */
		private function keyUpHandler(event:KeyboardEvent):void 
		{
			pressed[event.keyCode] = false;
		}
		
		/**
		 * Cette fonction est appele lorsque le system est contruit (une seuls fois)
		 */
		override protected function onConstructed():void
		{
			super.onConstructed();
			// Construction de la famille : C'est ici que l'on indique de quoi se compose la famille
			// que l'on souhaite gerer dans ce system. Dans notre cas nous choisissons de contruire
			// une famille qui regroupe toutes les entites qui contiennent un composant Transform ET
			// un composant Controlable
			controlableEntities = entityManager.getFamily(allOfGenes(Transform, Controlable, Velocity));
						
			// Instanciation des mapper (c'est ici que l'on choisi quel composant chaque mapper va etre
			// capable de recuperer).
			transformMapper = geneManager.getComponentMapper(Transform);
			controlableMapper = geneManager.getComponentMapper(Controlable);
			velocityMapper = geneManager.getComponentMapper(Velocity);
			textureResourceMapper = geneManager.getComponentMapper(TextureResource);
			
			backgroundEntity = entityManager.getFamily(allOfGenes(Transform, TextureResource));
		}
		
		/**
		 * Cette fonction est appelle a chaque pas de simulation
		 * @param	delta : Le parametre delta nous indique combien de temps c'est passe depuis le dernier appel
		 */
		override protected function onProcess(delta:Number):void
		{
			moved = false;
			// Trouver le background - obtenir ses composants
			if (backgroundEntity.members.length > 0 && bgTexture == null)
			{
				for (var i:int = 0; i < backgroundEntity.members.length; i++)
				{
					bg = backgroundEntity.members[i];
					bgTransform = transformMapper.getComponent(bg);
					bgTexture = textureResourceMapper.getComponent(bg);
					
					if (bgTexture != null && bgTexture.source == "assets/pictures/field_one.png")
					{
						break;
					}
				}
			}
			
			// Controler les controlable
			if (bgTexture != null && bgTexture.bitmapData != null)
			{
				// parcours de la famille
				for (i = 0; i < controlableEntities.members.length; i++)
				{	
					var e:IEntity = controlableEntities.members[i]; // recuperation de la ieme entite de la famille
					// recuperation du composant Transform contenu dans l'entite
					var transform:Transform = transformMapper.getComponent(e);
					// recuperation du composant Controlable contenu dans l'entite
					var controlable:Controlable = controlableMapper.getComponent(e);
					// recuperation du composant TextureResource contenu dans l'entite
					var textureResource:TextureResource = textureResourceMapper.getComponent(e);
					// recuperation du composant Velocity contenu dans l'entite
					var velocity:Velocity = velocityMapper.getComponent(e);
					
					// modification du Transform - position du objet est seulement dans le secteur du background
					if (pressed[controlable.left.toUpperCase().charCodeAt(0)])
					{
						// Si la direction est change, acceleration retourne a 0;
						if (velocity.acceleration > 0)
						{
							velocity.acceleration = 0;
						}
						
						// On verifie si le brique est passé la limite de l'ecran du jeu ou non
						if (transform.x - velocity.speed + velocity.acceleration >= bgTransform.x)
						{
							transform.x -= velocity.speed - velocity.acceleration; 
							// Le brick vais de plus en plus vite
							velocity.acceleration -= velocity.accelerationStep;
						}
						else 
						{
							transform.x = bgTransform.x;
							velocity.acceleration = 0;
						}
						
						moved = true;
					}
										
					if (pressed[controlable.right.toUpperCase().charCodeAt(0)]) 
					{
						// Si la direction est change, acceleration retourne a 0;
						if (velocity.acceleration < 0)
						{
							velocity.acceleration = 0;
						}
						
						// On verifie si le brique est passé la limite de l'ecran du jeu ou non
						if (transform.x + textureResource.bitmapData.width * transform.scaleX + velocity.speed + velocity.acceleration <= bgTransform.x + bgTexture.bitmapData.width)
						{
							transform.x += velocity.speed + velocity.acceleration;	
							// Le brick vais de plus en plus vite
							velocity.acceleration += velocity.accelerationStep;
						}
						else 
						{
							transform.x = bgTransform.x + bgTexture.bitmapData.width - textureResource.bitmapData.width * transform.scaleX;
							velocity.acceleration = 0;
						}
						
						moved = true;
					}
					
					if (!moved)
					{
						// Si le brick n'a pas deplace, acceleration retourne a 0;
						velocity.acceleration = 0;
					}
				}
			}
		}
	}

}