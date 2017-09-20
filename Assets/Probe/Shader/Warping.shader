Shader "Demon/Warping"
{
	Properties
	{
		_NoiseTex ("Noise", 2D) = "white" {}
		_WarpSpeed ("WarpSpeed", Range(0, 2.0)) = 1.0
	}
	SubShader
	{
		Cull Off ZWrite Off 

		GrabPass
		{
			"_GrabTex"
		}

		Pass
		{
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 grabPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _NoiseTex, _GrabTex;
			float4 _NoiseTex_ST, _GrabTex_ST;
			fixed _WarpSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 offset = tex2D(_NoiseTex, i.uv - _Time.xy * _WarpSpeed);
				i.grabPos.xy += offset.xy * 0.01;
				fixed4 col = tex2Dproj(_GrabTex, i.grabPos);
				return col;
			}
			ENDCG
		}
	}
}
