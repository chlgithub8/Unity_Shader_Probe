Shader "Demon/Expplosion"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("EdgeColor", Color) = (0,1,0,1)
		_Change ("Change", Range(0.0, 10.0)) = 0

	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True"}
		LOD 100

		Pass
		{
			Cull Off

			Blend SrcAlpha OneMinusSrcAlpha 

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			half _Change;
			fixed4 _EdgeColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				//float3 wdNormal = UnityObjectToWorldNormal(v.normal);
				//float3 wdPos = mul(unity_ObjectToWorld, v.vertex);

				v.vertex.xyz += v.normal * _Change;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex) + float2(_Time.y * max(_Change * 0.5, 0.5), 0);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				col.a = lerp(col.a, 0, _Change * 0.3);
				
				fixed w = fwidth(col.a) * 3.0;
				fixed spec = lerp(0, 1, smoothstep(-w, w, col.a -1));
				if(col.a <0.2)
				col.rgb = _EdgeColor.rgb;

				 
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
