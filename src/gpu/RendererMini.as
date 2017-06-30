package gpu 
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DMipFilter;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Context3DWrapMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import gpu.MeshMini;
	import gpu.shading.ShaderMini;
	import gpu.texture.TextureUploader;

	[Event(name="complete", type="flash.events.Event")]
	public class RendererMini extends EventDispatcher
	{
		private var stage:Stage;
		private var shader:gpu.shading.ShaderMini;
		
		private var stage3D:Stage3D;
		private var context3D:Context3D;
		private var meshesToDisplay:Vector.<gpu.MeshMini> = new Vector.<gpu.MeshMini>();
		
		public var textureUploader:gpu.texture.TextureUploader;
		
		public function RendererMini(stage:Stage) 
		{
			this.stage = stage;
		}
		
		public function initialize():void
		{
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextReady);
			stage.stage3Ds[0].requestContext3D();
		}
		
		public function addChild(mesh:gpu.MeshMini):void
		{
			meshesToDisplay.push(mesh);
			mesh.create(context3D);
		}
		
		private function onContextReady(e:Event):void 
		{
			setupContext3D();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function setupContext3D():void 
		{
			stage3D = stage.stage3Ds[0];
			context3D = stage3D.context3D;
			
			textureUploader = new gpu.texture.TextureUploader(context3D);
			
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 4, false, false, false);
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context3D.setCulling(Context3DTriangleFace.NONE);
			context3D.enableErrorChecking = true;
			
			shader = new gpu.shading.ShaderMini();
			shader.create(context3D);
		}
		
		private function drawContent():void 
		{
			context3D.setSamplerStateAt(0, Context3DWrapMode.REPEAT, Context3DTextureFilter.LINEAR, Context3DMipFilter.MIPNONE);
			
			
			var aspectX:Number = 1 / stage.stageWidth;
			var aspectY:Number = -1 / stage.stageHeight;
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, new <Number>[aspectX, aspectY, stage.stageWidth, stage.stageHeight], 1);
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, new <Number>[aspectX * 2, aspectY * 2, stage.stageWidth, stage.stageHeight], 1);
			
			for (var i:int = 0; i < meshesToDisplay.length; i++)
			{
				var mesh:gpu.MeshMini = meshesToDisplay[i];
				shader.setToContext(context3D, mesh.texture);
				
				context3D.setTextureAt(0, mesh.texture.gpuData);
				context3D.setVertexBufferAt(0, mesh.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				context3D.setVertexBufferAt(1, mesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1, new <Number>[mesh.width, mesh.height, 0, 0, mesh.scaleX, mesh.scaleY, mesh.x, mesh.y], 2);
				context3D.drawTriangles(mesh.indexBuffer, 0, 2);
			}
		}
		
		public function render():void
		{
			textureUploader.update();
			
			context3D.clear(0.4, 0.2, 0.2);
			
			drawContent();
			
			context3D.present();
		}
		
	}

}