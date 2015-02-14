package components 
{
	import com.ktm.genome.core.data.component.Component;
	
	/**
	 * La taille du brick est 40x20 (width*height)
	 * Le map sera 15x10 (column*row)
	 * - lvl : le niveau du map
	 * - map : le valeur du map (contien "0" "1" et " ")
	 * @author VietLM
	 */
	public class BrickMap extends Component 
	{
		public var lvl:Number;
		public var map:String;
	}

}