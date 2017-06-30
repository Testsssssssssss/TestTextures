package gpu.shading 
{
	import adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import gpu.texture.TextureMini;
	/**
	 * ...
	 * @author gNikro
	 */
	public class ShaderMini 
	{
		private static const AGAL_ASSEMLBER:AGALMiniAssembler = new AGALMiniAssembler();
		
		private var vertexShader:String =     "mov vt0 va0\n" //geometry
											+ "mov vt1 vc0\n" //aspect, screenSize
											+ "mov vt2 vc1\n" //textureSize
											+ "mov vt3 vc2\n" //scale, xy
											
											+ "mul vt0.xy vt0.xy vt1.xy\n" //to screen sapce
											+ "mul vt0.xy vt0.xy vt2.xy\n"
											
											+ "mul vt4.xy vt1.zw vt1.xy\n" //to left top coordinate system of screen
											+ "sub vt0.xy vt0.xy vt4.xy\n"
											
											+ "mul vt4.xy vt2.xy vt1.xy\n" //to left top coordinate system of texture
											+ "add vt0.xy vt0.xy vt4.xy\n"
											
											+ "mul vt4.xy vt3.zw vc5.xy\n" //add x,y 
											+ "add vt0.xy vt0.xy vt4.xy\n"
											
											+ "mov v0 va1\n"
											+ "mov op vt0";
											
		/*private var basePixelShader:String = 	
											  "tex ft0, v0, fs0 <2d,%format%,ignoresampler,0>\n"
											+ "mov ft1, v0 \n"
											+ "mul ft0, ft0, fc0 \n"
											+ "add ft1, ft1, ft0 \n"
											//+ "tex ft3, ft1, fs0 <2d,%format%,ignoresampler,0>\nmax oc ft3 ft0";
											+ "tex ft3, ft1, fs0 <2d,%format%,ignoresampler,0>\nadd oc ft3 ft0";*/
		private var basePixelShader:String = "tex oc, v0, fs0 <2d,%format%,ignoresampler,0>";
											
		private var programs:Object = {};
		
		public function ShaderMini() 
		{
			
		}
		
		public function create(context3D:Context3D):void
		{
			var rgbProgram:Program3D = context3D.createProgram();
			var compressedProgram:Program3D = context3D.createProgram();
			var rgbCompressedProgram:Program3D = context3D.createProgram();
			
			var vertexAsm:ByteArray = AGAL_ASSEMLBER.assemble(Context3DProgramType.VERTEX, vertexShader);
			var pixelRgbAsm:ByteArray = AGAL_ASSEMLBER.assemble(Context3DProgramType.FRAGMENT, basePixelShader.replace(/%format%/g, gpu.texture.TextureMini.FORMAT_RGBA));
			
			var pixelRgbCompressed:ByteArray = AGAL_ASSEMLBER.assemble(Context3DProgramType.FRAGMENT, basePixelShader.replace(/%format%/g, gpu.texture.TextureMini.FORMAT_COMPRESSED));
			var pixelRgbCompressedAlpha:ByteArray = AGAL_ASSEMLBER.assemble(Context3DProgramType.FRAGMENT, basePixelShader.replace(/%format%/g, gpu.texture.TextureMini.FORMAT_COMPRESSED_ALPHA));
			
			rgbProgram.upload(vertexAsm, pixelRgbAsm);
			compressedProgram.upload(vertexAsm, pixelRgbCompressed);
			rgbCompressedProgram.upload(vertexAsm, pixelRgbCompressedAlpha);
			
			programs[gpu.texture.TextureMini.FORMAT_RGBA] = rgbProgram;
			programs[gpu.texture.TextureMini.FORMAT_COMPRESSED] = compressedProgram;
			programs[gpu.texture.TextureMini.FORMAT_COMPRESSED_ALPHA] = rgbCompressedProgram;
		}
		
		private var angle:Number = 0;
		public function setToContext(context3D:Context3D, texture:gpu.texture.TextureMini):void
		{
			angle += Math.PI / 3600;
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, new <Number>[Math.cos(angle), Math.sin(angle), 0.1, 0.1], 1);
			context3D.setProgram(programs[texture.format]);
		}
		
	}

}