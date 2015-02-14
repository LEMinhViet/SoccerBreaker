package components 
{
	import com.ktm.genome.core.data.component.Component;
	
	/**
	 * Les objets contiennent le component Touchable seront traites si il y a un touch sur eux.
	 * - intent : le but du touch (start, pause, exit, +/- volumne ...)
	 * - parameter : pour transporter quelque numero
	 * - enabled : joueur peut toucher ou non ce moment là
	 * @author Vietlm
	 */
	public class Touchable extends Component 
	{
		public var intent:String = "";
		public var parameter:Number = 0;
		public var enabled:Boolean = true;
	}

}