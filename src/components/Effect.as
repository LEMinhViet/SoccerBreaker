package components 
{
	import com.ktm.genome.core.data.component.Component;
	
	/**
	 * Cette classe est pour les entites "effect" dans ce jeu
	 * - type : le type de l'effet
	 * - time : combien frame que l'effet va être montré
	 * @author VietLM
	 */
	public class Effect extends Component
	{
		public var type:String = "";
		public var time:Number = 0;		
	}

}