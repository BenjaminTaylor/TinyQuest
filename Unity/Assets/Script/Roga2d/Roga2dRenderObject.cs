using UnityEngine;
public class Roga2dRenderObject {
	public Rect srcRect;
	public Vector2 pixelSize;
	public Vector2 pixelCenter;
	private GameObject gameObject;
	private Texture texture;
	
	private static float BasePixelSize = 64.0f;
	public Roga2dRenderObject(Texture texture, Vector2 pixelSize, Vector2 pixelCenter, Rect srcRect)
	{
		this.gameObject = null;
		this.pixelSize = pixelSize;
		this.pixelCenter = pixelCenter;
		this.srcRect = srcRect;
		this.texture = texture;
	}
	
	public void Destroy() {
		if (this.gameObject != null) {
			Object.Destroy(this.gameObject);
			this.gameObject = null;
		}
	}
	
	public void Pop() {
		this.gameObject = new GameObject("RenderObject");
		
		// Setup Renderer
		this.gameObject.AddComponent("MeshFilter");
		this.gameObject.AddComponent("MeshRenderer");
		
		float[] uvs;
		
		if (this.texture == null) {
			uvs = new float[4] {0.0f, 0.0f, 1.0f, 1.0f};
		} else {
			uvs = new float[4] {
				this.srcRect.xMin / this.texture.width, 
				1 - this.srcRect.yMax / this.texture.height, 
				this.srcRect.xMax / this.texture.width, 
				1 - this.srcRect.yMin / this.texture.height
			};
		}
		
		(this.gameObject.GetComponent("MeshFilter") as MeshFilter).mesh = GeneratePlane(this.pixelSize.x / BasePixelSize, this.pixelSize.y / BasePixelSize, uvs);
		
		MeshRenderer renderer = this.gameObject.GetComponent("MeshRenderer") as MeshRenderer;
		renderer.material = new Material (Shader.Find("Transparent/VertexLit"));
		// Setup Texture
		if (texture != null) {
			renderer.material.mainTexture = this.texture;
		}
		
	}
	
	public GameObject GameObject {
		get {
			return this.gameObject;
		}
	}

	private Mesh GeneratePlane(float sizeX, float sizeY, float[] uvs) {
		Mesh mesh = new Mesh();
		mesh.vertices = new Vector3[4] {
			new Vector3(-sizeX, -sizeY, 0.01f), 
			new Vector3(sizeX, -sizeY, 0.01f), 
			new Vector3(sizeX, sizeY, 0.01f), 
			new Vector3(-sizeX, sizeY, 0.01f)
		};
		mesh.uv = new Vector2[4] {
			new Vector2(uvs[0], uvs[1]), 
			new Vector2 (uvs[0], uvs[3]), 
			new Vector2(uvs[2], uvs[3]), 
			new Vector2 (uvs[2], uvs[1])
		};
		mesh.triangles = new int[6] {0, 1, 2, 0, 2, 3};
		mesh.RecalculateNormals();
		
		return mesh;
	}
	
	public void SetAlpha(float alpha) {
		MeshRenderer renderer = this.GameObject.GetComponent("MeshRenderer") as MeshRenderer;
		Color color = new Color(1.0f, 1.0f, 1.0f, alpha);
		renderer.material.SetColor("_Color", color);
	}

	public Vector2 PixelSize {
		get {
			return this.pixelSize;	
		}
	}
	
	public Vector2 PixelCenter {
		get {
			return this.pixelCenter;	
		}
	}
	
	public Vector2 Anchor {
		get {
			float centerX = (this.pixelCenter.x) / this.pixelSize.x;
			float centerY = (this.pixelCenter.y) / this.pixelSize.y;
			return new Vector2(centerX, centerY);
		}
	}

	public Rect SrcRect {
		get {
			return this.srcRect;	
		}
	}
}