package 
{
	/**
	 * ...
	 * @author gNikro
	 */
	public class Color 
	{
		private static const MAX_2:int = 3;
		private static const MAX_3:int = 7;
		private static const MAX_4:int = 15;
		private static const MAX_5:int = 31;
		private static const MAX_6:int = 63;
		private static const MAX_8:int = 255;
		
		public var r:int = 0;
		public var g:int = 0;
		public var b:int = 0;
		public var a:int = 0;
		
		public function Color(r:int = 0, g:int = 0, b:int = 0) 
		{
			this.r = r;
			this.g = g;
			this.b = b;
		}
		
		/**
		 * Represent color as 16 bit color with contains 5 bit to RED channel 6 bit to GREEN channel and 5 bit to BLUE channel
		 * @return
		 */
		[Inline]
		public final function to565(alpha:Boolean):int
		{
			var r:int;
			var g:int;
			var b:int;
			var a:int;
			
			var color:int;
			
			if (alpha)
			{
				r = this.r / MAX_8 * MAX_4;
				g = this.g / MAX_8 * MAX_4;
				b = this.b / MAX_8 * MAX_4;
				a = this.a / MAX_8 * MAX_4;
			
				color = combineColor4444(a, r, g, b);
			}
			else
			{
				r = this.r / MAX_8 * MAX_5;
				g = this.g / MAX_8 * MAX_6;
				b = this.b / MAX_8 * MAX_5;
			
				color = combineColor565(r, g, b);
			}
			
			return color;
		}
		
		[Inline]
		public final function to6BitRepresent16Bit(alpha:Boolean):int
		{
			var r:int;
			var g:int;
			var b:int;
			var a:int;
			
			var color:int;
			
			if (alpha)
			{
				r = this.r / MAX_8 * MAX_2;
				g = this.g / MAX_8 * MAX_2;
				b = this.b / MAX_8 * MAX_2;
				a = this.a / MAX_8 * MAX_4;
				
				r = r / MAX_2 * MAX_4;
				g = g / MAX_2 * MAX_4;
				b = b / MAX_2 * MAX_4;
				
				color = combineColor4444(a, r, g, b);
			}
			else
			{
				r = this.r / MAX_8 * MAX_2;
				g = this.g / MAX_8 * MAX_2;
				b = this.b / MAX_8 * MAX_2;
				
				r = r / MAX_2 * MAX_5;
				g = g / MAX_2 * MAX_6;
				b = b / MAX_2 * MAX_5;
				
				color = combineColor565(r, g, b);
			}
			
			return color;
		}
		
		[Inline]
		public final function to8BitRepresent16Bit(alpha:Boolean):int
		{
			var r:int;
			var g:int;
			var b:int;
			var a:int;
			
			var color:int;
			
			if (alpha)
			{
				r = this.r / MAX_8 * MAX_3;
				g = this.g / MAX_8 * MAX_3;
				b = this.b / MAX_8 * MAX_2;
				a = this.a / MAX_8 * MAX_4;
				
				r = r / MAX_3 * MAX_4;
				g = g / MAX_3 * MAX_4;
				b = b / MAX_2 * MAX_4;
				
				color = combineColor4444(a, r, g, b);
			}
			else
			{
				r = this.r / MAX_8 * MAX_3;
				g = this.g / MAX_8 * MAX_3;
				b = this.b / MAX_8 * MAX_2;
				
				r = r / MAX_3 * MAX_5;
				g = g / MAX_3 * MAX_6;
				b = b / MAX_2 * MAX_5;
				
				color = combineColor565(r, g, b);
			}
			
			return color;
		}
		
		[Inline]
		public final function combineColor565(r:int, g:int, b:int):int
		{
			return ((r << 11) | (g << 5) | b); //order to little endian BGR
		} 
		
		[Inline]
		public final function combineColor4444(a:int, r:int, g:int, b:int):int
		{
			return ((a << 12) | (r << 8) | (g << 4) | b);
		}
		
		public function setFromColor(color:uint):void 
		{
			a = (color >> 24) & 0xFF;
			r = (color >> 16 ) & 0xFF;
			g = (color >> 8) & 0xFF;
			b = (color & 0xFF);
		}
		
	}

}