Shader "Demon/Dissolve"
{
	Properties
	{	
		_Cutoff	("Cutoff", Range(0.0, 1.0)) = 0.2	
		_Color ("Color", Color)	= (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_DissolveMask ("Disssolve Mask", 2D) = "white" {}
		_DissolveColor ("Dissolve Color", Color) = (1.0, 0.4, 0, 1.0)
		_DissolveFactor	("Dissolve Factor", Range(0.0, 1.0)) = 0.8
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 mask_uv : TEXCOORD1;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex, _DissolveMask;
			float4 _MainTex_ST, _DissolveMask_ST;
			fixed4 _Color, _DissolveColor;
			fixed _Cutoff, _DissolveFactor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.mask_uv, _DissolveMask);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv.xy) * _Color;
				fixed4 mask = tex2D(_DissolveMask, i.uv.zw);
				clip(mask.a - _Cutoff);
				fixed edge = _Cutoff / mask.a;
				col = lerp(col, _DissolveColor, smoothstep(_DissolveFactor, 1, edge));
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
