package  
{
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.core.entity.IEntityManager;
	
	import com.ktm.genome.render.component.Transform;
	import com.ktm.genome.resource.component.TextureResource;
	import com.ktm.genome.render.component.Layered;
	
	import components.Obstacle;
	import components.Touchable;
	import components.Effect;
	import components.Numericable;
	import components.Guide;
	import components.Uncontrolable;
	import components.Velocity;
	
	/**
	 * Methode d'aide pour creer des entites dynamiquement
	 * @author Vietlm
	 */
	public class EntityFactory 
	{
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// permet de charger un xml dynamiquement
		static public function createResourcedEntity(em:IEntityManager, source:String, 
													id:String, resourceType:Class, 
													e:IEntity = null):IEntity
		{
			// Creation d'une nouvelle entite
			e = e ||= em.create();
			// Ajout d'un composant a l'entite
			em.addComponent(e, resourceType, { id: id, source: source, toBuild: true } );
			return e;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// permet de creer une brique dynamiquement
		static public function createBrickEntity(em:IEntityManager, x:int, y:int, source: String, id: String,  e:IEntity = null):IEntity
		{
			// Creation d'une nouvelle entite
			e = e ||= em.create();
			// Ajout d'un composant a l'entite
			em.addComponent(e, Transform, { x: x, y: y, scaleX: 1, scaleY: 1 } );
			em.addComponent(e, TextureResource, { source: source, id: id } );
			em.addComponent(e, Layered, { layerId: "gameLayer" } );
			em.addComponent(e, Obstacle, { });
			return e;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// permet de creer une level-button dynamiquement
		static public function createLevelButtonEntity(em:IEntityManager, x:int, y:int, level:Number, e:IEntity = null):IEntity
		{
			// Creation d'une nouvelle entite
			e = e ||= em.create();
			// Ajout d'un composant a l'entite
			em.addComponent(e, Transform, { x: x, y: y} );
			em.addComponent(e, TextureResource, { source: "assets/pictures/lvls/lvl" + level + ".png", id: "level" + level } );
			em.addComponent(e, Layered, { layerId: "foregroundLayer" } );
			em.addComponent(e, Touchable, { intent: "LEVEL_SELECT", parameter: level});
			return e;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// permet de creer un numero graphique dynamiquement
		static public function createNumberEntity(em:IEntityManager, 
													x:int, y:int, scale:Number, 
													number:int, 
													e:IEntity = null):IEntity
		{
			// Creation d'une nouvelle entite
			e = e ||= em.create();
			// Ajout d'un composant a l'entite
			em.addComponent(e, Transform, { x: x, y: y, scaleX: scale, scaleY: scale} );
			em.addComponent(e, TextureResource, { source: "assets/pictures/lvls/lvl" + number + ".png", id: "level" + number } );
			em.addComponent(e, Layered, { layerId: "foregroundLayer+1" } );
			em.addComponent(e, Numericable, { } );
			return e;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// permet de creer un effect dynamiquement
		static public function createEffectEntity(em:IEntityManager, 
													x:int, y:int, 
													source:String, id: String, 
													type:String, time:Number, 
													e:IEntity = null):IEntity
		{
			// Creation d'une nouvelle entite
			e = e ||= em.create();
			// Ajout d'un composant a l'entite
			em.addComponent(e, Transform, { x: x, y: y, scaleX: 0.01, scaleY: 0.01 } );
			em.addComponent(e, TextureResource, { source: source, id: id } );
			em.addComponent(e, Layered, { layerId: "gameLayer" } );
			em.addComponent(e, Effect, { type: type, time: time } );
			return e;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// permet de creer un effect BREAK dynamiquement
		static public function createBreakEffectEntity(em:IEntityManager, 
														x:int, y:int, 
														source:String, id:String, 
														speed: int,
														angle: int,
														type:String, time:Number, 
														e:IEntity = null):IEntity
		{
			// Creation d'une nouvelle entite
			e = e ||= em.create();
			// Ajout d'un composant a l'entite
			em.addComponent(e, Transform, { x: x, y: y, scaleX: 0.4, scaleY: 1, alpha: 1, rotation: Math.random() * 360 } );
			em.addComponent(e, TextureResource, { source: source, id: id } );
			em.addComponent(e, Layered, { layerId: "gameLayer" } );
			em.addComponent(e, Velocity, { speed: speed } );
			em.addComponent(e, Uncontrolable, { angle : angle, withPhysic: false } );
			em.addComponent(e, Effect, { type: type, time: time } );
			return e;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// permet de creer un guide pour le GUI
		static public function createGuideEntity(em:IEntityManager, 
													x:int, y:int, 
													source:String, id:String, 
													e:IEntity = null):IEntity
		{
			// Creation d'une nouvelle entite
			e = e ||= em.create();
			// Ajout d'un composant a l'entite
			em.addComponent(e, Transform, { x: x, y: y } );
			em.addComponent(e, TextureResource, { source: source, id: id } );
			em.addComponent(e, Layered, { layerId: "foregroundLayer+1" } );
			em.addComponent(e, Guide, { } );
			return e;
		}
	}
}