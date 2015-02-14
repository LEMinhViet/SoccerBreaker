package components 
{
	import com.ktm.genome.core.data.component.Component;
	
	/**
	 * Cette classe contient tous les variables pour les movements d'un objet
	 * @author Vietlm
	 */
	public class Velocity extends Component 
	{
		// La vitesse
		public var speed:Number = 0;
		
		// L'accélération actuelle
		public var acceleration:Number = 0;
		
		// L'accélération est ajouté chaque frame
		public var accelerationStep:Number = 0;
	}

}