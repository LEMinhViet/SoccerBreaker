package systems 
{
	import com.ktm.genome.core.data.component.IComponent;
	import com.ktm.genome.core.data.component.IComponentMapper;
	import com.ktm.genome.core.entity.family.Family;
	import com.ktm.genome.core.entity.family.matcher.allOfGenes;
	import com.ktm.genome.core.entity.IEntity;
	import com.ktm.genome.core.logic.system.System;
		
	import com.ktm.genome.render.component.Transform;
	import com.ktm.genome.resource.component.TextureResource;
	import com.ktm.genome.render.component.Layer;
	
	import components.Effect;
	
	/**
	 * Cette classe controle les entites effets dans le jeu, il 
	 * - cherche les entites effets dans le frame courant
	 * - appliquer l'effet
	 * - supprimer l'effet si le temp est fini
	 * @author VietLM
	 */
	public class EffectSystem extends System 
	{
		private var effectEntities:Family;
		
		private var transformMapper:IComponentMapper;
		private var textureMapper:IComponentMapper;
		private var effectMapper:IComponentMapper;
		
		override protected function onConstructed():void
		{
			super.onConstructed();
			
			effectEntities = entityManager.getFamily(allOfGenes(Effect));			
			
			transformMapper = geneManager.getComponentMapper(Transform);
			textureMapper = geneManager.getComponentMapper(TextureResource);
			effectMapper = geneManager.getComponentMapper(Effect);
		}
		
		override protected function onProcess(delta:Number):void
		{
			for (var i:int = 0; i < effectEntities.members.length; i++)
			{
				var e:IEntity = effectEntities.members[i];
				var transform:Transform = transformMapper.getComponent(e);
				var texture:TextureResource = textureMapper.getComponent(e);
				var effect:Effect = effectMapper.getComponent(e);
				
				if (effect.time == 0)
				{
					entityManager.killEntity(e);
				}
				else 
				{
					effect.time--;
					
					// Si l'effet est "ZOOM_OUT", le scale de l'entite va augementer
					if (effect.type == "ZOOM_OUT") 
					{
						if (texture.bitmapData != null)
						{
							transform.x += texture.bitmapData.width * transform.scaleX / 2;
							transform.y += texture.bitmapData.height * transform.scaleY / 2;
							
							transform.scaleX = (transform.scaleX + 0.01) % 1;
							transform.scaleY = (transform.scaleY + 0.01) % 1;
							
							transform.x -= texture.bitmapData.width * transform.scaleX / 2;
							transform.y -= texture.bitmapData.height * transform.scaleY / 2;
						}
					}
					else if (effect.type == "NONE")
					{
						// Do nothing
					}
				}
			}
		}
	}

}