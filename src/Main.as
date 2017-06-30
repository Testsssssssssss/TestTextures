package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DMipFilter;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DWrapMode;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.sampler.getSize;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import gpu.MeshMini;
	import gpu.RendererMini;
	import gpu.texture.TextureUtils;
	
	/**
	 * ...
	 * @author gNikro
	 */
	public class Main extends Sprite 
	{
		[Embed(source = "../bin/leaf.png")]
		private var imageSource:Class;
		
		[Embed(source = "../bin/leaf_bgra.atf", mimeType = "application/octet-stream")]
		private var leafAtfBgraSource:Class
		
		[Embed(source = "../bin/leafCompressedAlpha.atf", mimeType = "application/octet-stream")]
		private var leafCompressedAlpha:Class
		
		[Embed(source = "../bin/leafCompressedAlphaDXT.atf", mimeType = "application/octet-stream")]
		private var leafCompressedAlphaDXT:Class
		
		[Embed(source = "../bin/leafCompressedAlphaETC.atf", mimeType = "application/octet-stream")]
		private var leafCompressedAlphaETC:Class
		
		private var sceneData:Vector.<Object>;
		private var renderer:gpu.RendererMini;
		
		public function Main() 
		{
			renderer = new gpu.RendererMini(stage);
			renderer.addEventListener(Event.COMPLETE, init);
			renderer.initialize();
		}
		
		private function init(e:Event = null):void 
		{
			renderer.removeEventListener(Event.COMPLETE, init);
			// entry point
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest("leaf.png"));
			loader.addEventListener(Event.COMPLETE, onLoaded);
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest("leafCompressedAlphaDXT.atf"));
			loader.addEventListener(Event.COMPLETE, onLoaded);
			
			var contentLoader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPngDecoded);
			contentLoader.load(new URLRequest("leaf.png"), context);
			
			
			addEventListener(Event.ENTER_FRAME, onUpdate);
		}
		
		private function onPngDecoded(e:Event):void 
		{
			var png:BitmapData = ((e.target as LoaderInfo).content as Bitmap).bitmapData;
			
			trace("PNG SIZE", getSize(png) / 1000);
			trace("");
			
			sceneData = new Vector.<Object>();
			
			sceneData.push({textureSource:png, info:"bitmap texture BGRA"}); //384KB base texture
			
			sceneData.push({textureSource:gpu.texture.TextureUtils.createPACKED_DATA(png, gpu.texture.TextureUtils.FORMAT_565), info:"BGRA_PACKED 565"});  //192KB base texture
			sceneData.push({textureSource:gpu.texture.TextureUtils.createPACKED_DATA(png, gpu.texture.TextureUtils.FORMAT_6BIT), info:"BGRA_PACKED 6BIT"});  //192KB base texture
			sceneData.push({textureSource:gpu.texture.TextureUtils.createPACKED_DATA(png, gpu.texture.TextureUtils.FORMAT_8BIT), info:"BGRA_PACKED 8BIT"});//192KB base texture
			
			sceneData.push({textureSource:new leafAtfBgraSource(), info:"atf BGRA"}); //384KB base texture
			sceneData.push({textureSource:new leafCompressedAlphaDXT(), info:"atf DXT"}); //96KB packed texture
			sceneData.push({textureSource:new leafCompressedAlphaETC(), info:"atf ETC"}); //96KB
			
			setupScene();
		}
		
		private function onLoaded(e:Event):void 
		{
			trace("=====test native loaded data=====");
			var imagePngBytes:ByteArray = (e.target as URLLoader).data;
			
			trace(getSize(imagePngBytes) / 1000, imagePngBytes.length / 1000);
			imagePngBytes.compress();
			imagePngBytes.position = 0;
			trace(getSize(imagePngBytes) / 1000, imagePngBytes.length / 1000);
		}
		
		private function setupScene():void 
		{
			var _x:Number = 0;
			var _y:Number = 0;
			var lastMeshHeight:int = 0;
			
			for (var i:int = 0; i < sceneData.length; i++)
			{
				var data:Object = sceneData[i];
				var textureSource:Object = data.textureSource;
				var info:String = data.info;
				
				var mesh:gpu.MeshMini = new gpu.MeshMini(renderer.textureUploader.getTexture(textureSource));
				renderer.addChild(mesh);
				
				var infoBlock:TextField = new TextField();
				infoBlock.defaultTextFormat = new TextFormat("FixedSys", 15, 0xFFFFFF, true);
				infoBlock.text = info;
				infoBlock.autoSize = TextFieldAutoSize.LEFT;
				
				addChild(infoBlock);
				
				if (mesh.width + _x > stage.stageWidth)
				{
					_x = 0;
					_y = lastMeshHeight;
				}
				
				infoBlock.y = _y;
				
				mesh.x = _x;
				mesh.y = infoBlock.y + infoBlock.height + 1;
				
				infoBlock.x = mesh.x + (mesh.width - infoBlock.width) / 2;
				
				_x += mesh.width;
				lastMeshHeight = mesh.height + mesh.y;
			}
		}
		
		private function onUpdate(e:Event):void 
		{
			renderer.render();
		}
	}
}