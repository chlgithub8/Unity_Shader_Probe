using UnityEngine;
using UnityStandardAssets.ImageEffects;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/Demon/NightVision")]
public class NightVision : PostEffectsBase
{
	public Color _color = new Color (0, 1, 0, 1);
	public Shader _nightVisionShader;
	private Material _nightVisionMaterial;

	public override bool CheckResources ()
	{
		CheckSupport (false);

		_nightVisionMaterial = CheckShaderAndCreateMaterial (_nightVisionShader, _nightVisionMaterial);

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

		if (_nightVisionMaterial != null) {
			_nightVisionMaterial.SetColor ("_Color", _color);
			Graphics.Blit (src, dest, _nightVisionMaterial);			
		}
	}
}
