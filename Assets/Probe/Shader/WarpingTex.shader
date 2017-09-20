Shader "Demon/WarpingTex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "white" {}
		_WarpSpeed ("WarpSpeed", Range(0, 2.0)) = 1.0
	}
	SubShader
	{
		Cull Off ZWrite Off 

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
				float2 noise_uv : TEXCOORD1;				
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex, _NoiseTex;
			float4 _MainTex_ST, _NoiseTex_ST;
			fixed _WarpSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.noise_uv, _NoiseTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 offset = tex2D(_NoiseTex, i.uv.zw - _Time.xy * _WarpSpeed);
				fixed4 col = tex2D(_MainTex, i.uv.xy + offset.xy * 0.01);
				return col;
			}
			ENDCG
		}
	}
}
