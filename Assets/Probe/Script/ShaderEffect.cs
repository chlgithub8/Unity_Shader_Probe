using UnityEngine;
using UnityStandardAssets.ImageEffects;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/Demon/ShaderEffect")]
public class ShaderEffect : PostEffectsBase
{
	public Shader _shader;
	private Material _material;

	public override bool CheckResources ()
	{
		CheckSupport (false);

		_material = CheckShaderAndCreateMaterial (_shader, _material);

		if (!isSupported)
			ReportAutoDisable ();
		return isSupported;
	}

	public void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		if (CheckResources () == false) {
			Graphics.Blit (src, dest);
			return;
		}

		if (_material != null) {
			Graphics.Blit (src, dest, _material);			
		}
	}
}

