package gpu 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import gpu.texture.TextureMini;
	
	public class MeshMini 
	{
		private var vertices:Vector.<Number> = new <Number>[-1, -1, 
															 1, -1,
															 1,  1, 
															-1,  1];
															
		private var uv:Vector.<Number> = new <Number>[0, 0, 
													  1, 0, 
													  1, 1, 
													  0, 1];
															
		private var indices:Vector.<uint> = new <uint>[0, 1, 2, 
													   2, 3, 0];
		
		internal var indexBuffer:IndexBuffer3D;
		internal var vertexBuffer:VertexBuffer3D;
		internal var uvBuffer:VertexBuffer3D;
		
		internal var texture:TextureMini;
		
		public var width:Number;
		public var height:Number;
		
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		
		public var x:Number = 0;
		public var y:Number = 0;
		
		public function MeshMini(texture:TextureMini) 
		{
			this.texture = texture;
			this.width = texture.width;
			this.height = texture.height;
		}
		
		public function create(context3D:Context3D):void
		{
			indexBuffer = context3D.createIndexBuffer(6);
			indexBuffer.uploadFromVector(indices, 0, 6);
			
			vertexBuffer = context3D.createVertexBuffer(4, 2);
			vertexBuffer.uploadFromVector(vertices, 0, 4);
			
			uvBuffer = context3D.createVertexBuffer(4, 2);
			uvBuffer.uploadFromVector(uv, 0, 4);
		}
		
		public function toString():String 
		{
			return "[MeshMini texture=" + texture + " width=" + width + " height=" + height + " scaleX=" + scaleX + 
						" scaleY=" + scaleY + " x=" + x + " y=" + y + "]";
		}
	}
}