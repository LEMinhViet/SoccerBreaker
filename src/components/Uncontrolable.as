package components 
{
	import com.ktm.genome.core.data.component.Component;
	
	/**
	 * Cette classe contient tous les variables du Uncontrolable Component
	 * - angle : angle de movement actuel du objet
	 * - x_global et y_global : parce que le objet qui a le component Uncontrolable est le ball, 
	 * et pour le tourner, il faut place le ball sur un autre layer et tourner layer => le position
	 * du ball dans le Transform component est pour le layer (local) => on utilise ces variables pour 
	 * les positions pour le systeme (global).
	 * @author Vietlm
	 */
	public class Uncontrolable extends Component 
	{
		public var angle:Number;
		
		public var x_global:Number = 0;
		public var y_global:Number = 0;
		
		public var withPhysic:Boolean = true;
	}

}