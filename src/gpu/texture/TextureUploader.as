package gpu.texture 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.sampler.getSize;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import gpu.texture.TextureMini;
	
	public class TextureUploader 
	{
		private var context3D:Context3D;
		
		public var texturesList:Vector.<TextureUploaderData> = new Vector.<TextureUploaderData>
		
		public function TextureUploader(context3D:Context3D) 
		{
			this.context3D = context3D;
		}
		
		public function update():void
		{
			var texturesListLength:int = texturesList.length;
			for (var i:int = 0; i < texturesListLength; i++)
			{
				var currentTexture:TextureUploaderData = texturesList[i];
				
				if (currentTexture.currentMipLevel == -1)
				{
					texturesList.splice(i, 1);
					texturesListLength--;
					i--;
					continue;
				}
				else
					MipmapGenerator.generateMipMaps(currentTexture.textureSource as BitmapData, currentTexture.texture, currentTexture.isUseAlpha, -1, currentTexture.currentMipLevel, 1);
					
				currentTexture.currentMipLevel--;
			}
		}
		
		public function uploadTexture(textureSource:BitmapData, level:Number = -1):gpu.texture.TextureMini 
		{
			/*var mipLevel:int = FastMath.log(textureSource.width, 2);
			if (level != -1)
				mipLevel = level;
				
			var texture:Texture = context3D.createTexture(textureSource.width, textureSource.height, textureSource.transparent? Context3DTextureFormat.BGRA:Context3DTextureFormat.BGRA, false, mipLevel);
			
			var textureUploadData:TextureUploaderData = new TextureUploaderData();
			textureUploadData.currentMipLevel = mipLevel;
			textureUploadData.maxMipLevel = mipLevel;
			//textureUploadData.isUseAlpha = false;
			textureUploadData.isUseAlpha = textureSource.transparent;
			textureUploadData.texture = texture;
			textureUploadData.textureSource = textureSource;
			
			texturesList.push(textureUploadData);*/
			
			
			var texture:Texture = context3D.createTexture(textureSource.width, textureSource.height, Context3DTextureFormat.BGRA, false, 0);
			var t:Number = getTimer();
			texture.uploadFromBitmapData(textureSource, 0);
			trace("uploadFromBitmapData:", (getTimer() - t) + "ms", getSize(texture));
			
			return new gpu.texture.TextureMini(texture, textureSource.width, textureSource.height);
		}
		
		public function uploadCompressedTexture(textureData:ByteArray):gpu.texture.TextureMini
		{
			var atfData:ATFData = new ATFData(textureData);
			var texture:Texture = context3D.createTexture(atfData.width, atfData.height, atfData.format, false, 0);
			
			var t:Number = getTimer();
			texture.uploadCompressedTextureFromByteArray(textureData, 0, false);
			trace("uploadCompressedTextureFromByteArray:", (getTimer() - t) + "ms", getSize(texture));
			
			return new gpu.texture.TextureMini(texture, atfData.width, atfData.height, gpu.texture.TextureMini.atfFormatToTextureformat(atfData.format));
		}
		
		public function uploadPackedTextureBinary(textureSource:ByteArray):gpu.texture.TextureMini 
		{
			textureSource.position = 0;
			
			var width:Number = textureSource.readInt();
			var height:Number = textureSource.readInt();
			var alpha:Boolean = textureSource.readBoolean();
			
			var texture:Texture = context3D.createTexture(width, height, alpha? Context3DTextureFormat.BGRA_PACKED:Context3DTextureFormat.BGR_PACKED, false, 0);
			
			var t:Number = getTimer();
			texture.uploadFromByteArray(textureSource, textureSource.position);
			trace("uploadFromByteArray:", (getTimer() - t) + "ms", getSize(texture));
			
			return new gpu.texture.TextureMini(texture, width, height);
		}
		
		public function getTexture(data:Object):gpu.texture.TextureMini 
		{
			if (data is BitmapData)
			{
				return uploadTexture(data as BitmapData, 0);
			}
			else if (data is ByteArray)
			{
				if (ATFData.isAtf(data as ByteArray))
					return uploadCompressedTexture(data as ByteArray);
				else
					return uploadPackedTextureBinary(data as ByteArray);
			}
			
			return null;
		}
		
		
		
	}

}