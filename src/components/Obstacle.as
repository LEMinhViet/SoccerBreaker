package components 
{
	import com.ktm.genome.core.data.component.Component;
	
	/**
	 * Cette classe define les objet qui est l'obstacle avec le uncontrolable objet (ball)
	 * @author VietLM
	 */
	public class Obstacle extends Component 
	{
		// la taille du obstacle pour faciliter la calculation
		public var oWidth:int = 0;
		public var oHeight:int = 0;
		
		// un obstacle distructible seront disparus apres la collision
		public var destructible:Boolean = true;
		
		// le brick controlable aura l'interaction avec le ball qui est different avec les autres obstacles 
		public var specialPhysic:Boolean = false;
		
		// Pour eviter le collision "stick" de cet objet et controlable objet a cause de la vitesse de controlabel > cela de cet objet
		public var justCollided:int = 0;
	}

}