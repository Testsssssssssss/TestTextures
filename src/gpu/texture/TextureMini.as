package gpu.texture 
{
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;

	public class TextureMini 
	{
		
		public static const FORMAT_RGBA:String = "rgba";
		public static const FORMAT_COMPRESSED:String = "dxt1";
		public static const FORMAT_COMPRESSED_ALPHA:String = "dxt5";
		
		public var gpuData:Texture;
		
		public var width:int;
		public var height:int;
		public var format:String;
		
		public function TextureMini(texture:Texture, width:int, height:int, format:String = FORMAT_RGBA) 
		{
			this.format = format;
			this.height = height;
			this.width = width;
			this.gpuData = texture;
		}
		
		static public function atfFormatToTextureformat(format:String):String 
		{
			if (format == Context3DTextureFormat.BGRA)
				return FORMAT_RGBA;
			else if (format == Context3DTextureFormat.COMPRESSED)
				return FORMAT_COMPRESSED;
			else if (format == Context3DTextureFormat.COMPRESSED_ALPHA)
				return FORMAT_COMPRESSED_ALPHA;
			return null;
		}
		
		public function toString():String 
		{
			return "[TextureMini format=" + format + 
						"]";
		}
	}
}