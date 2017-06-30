package gpu.texture 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.sampler.getSize;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author gNikro
	 */
	public class TextureUtils 
	{
		public static const FORMAT_8BIT:int = 0;
		public static const FORMAT_6BIT:int = 2;
		public static const FORMAT_565:int = 1;
		
		private static const PIXEL:Color = new Color();
		
		public static function createPACKED_DATA(imageData:BitmapData, format:int = 0):ByteArray
		{
			var alpha:Boolean = imageData.transparent;
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			data.writeInt(imageData.width);
			data.writeInt(imageData.height);
			data.writeBoolean(alpha);
			
			var t:Number = getTimer();
			
			//быстрее было бы через BitmapData.pallete, но не сильно быстрее
			for (var i:int = 0; i < imageData.width; i++)
			{
				for (var j:int = 0; j < imageData.height; j++)
				{
					var sourcePixel:int = imageData.getPixel32(j, i);
					PIXEL.setFromColor(sourcePixel);
					
					var color:int;
					
					if (format == FORMAT_8BIT)
						color = PIXEL.to8BitRepresent16Bit(alpha);
					else if (format == FORMAT_565)
						color = PIXEL.to565(alpha);
					else if (format == FORMAT_6BIT)
						color = PIXEL.to6BitRepresent16Bit(alpha);
					else
						throw "unsupported PACKED format";
					
					data.writeShort(color);
				}
			}
			
			t = getTimer() - t;
			checkCompression(imageData, data, format);
			trace("Pack time: " + (t) + "ms.");
			trace("\n");
			
			return data;
		}
		
		[Inline]
		private static function checkCompression(imageData:BitmapData, data:ByteArray, type:int):void
		{
			data.position = 0;
			
			var originalDataSize:Number = getSize(imageData) / 1000;
			var packedDataSize:Number = getSize(data) / 1000;
			var packedBytesSize:Number = data.length / 1000;
			
			var t:Number = getTimer();
			data.compress();
			var compressLine:String = ("Compress time: " + (getTimer() - t) + "ms.");
			data.position = 0;
			
			//var b:ByteArray = new ByteArray();
			//b.writeBytes(data, 0, data.length);
			
			
			var compressedDataSize:Number = getSize(data) / 1000;
			
			var sType:String;
			
			if (type == FORMAT_565)
				sType = "FORMAT_565";
			else if (type == FORMAT_6BIT)
				sType = "FORMAT_6BIT";
			else if (type == FORMAT_8BIT)
				sType = "FORMAT_8BIT";
			else
				sType = "unknown format";
				
			if(imageData.transparent)
				sType += "_ALPHA";
			
			trace("-=Texture size report=-", sType)
			trace("Original: " + originalDataSize);
			trace("Packed: " + packedDataSize + '/' + packedBytesSize);
			trace("Compressed: " + compressedDataSize + "/" + (data.length / 1000));
			
			t = getTimer();
			data.uncompress();
			trace(compressLine);
			trace("Uncompress time: " + (getTimer() - t) + "ms.");
			data.position = 0;
		}
	}

}