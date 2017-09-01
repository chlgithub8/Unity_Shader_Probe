Shader "Hidden/NightVision"
{
	Properties
	{
		_Color("Color", Color) = (0,1,0,1)
		_MainTex ("Texture", 2D) = "white" {} 
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
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
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
	        fixed4 _Color;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 screenPoint = i.uv;
				fixed scale =  _ScreenParams.x / _ScreenParams.y;
				screenPoint.x *= scale;
				half dis = length(screenPoint - fixed2(0.5 * scale, 0.5));
				
				//if(dis >=0.35 && dis <=0.55)
				//	dis = 1- (dis-0.35) * 5;	
				//else
				//	dis = step(dis, 0.55);	

				//和上面的等效
				dis = lerp(1.0, 0, smoothstep(0.35, 0.55, dis));	

				fixed4 tex = tex2D(_MainTex, i.uv);
				fixed grayscale = (tex.r + tex.g + tex.b) * 0.333 * 1.5;
				tex = fixed4(grayscale, grayscale, grayscale, 1.0);

	            fixed4 col = lerp(fixed4(0,0,0,1.0), tex * _Color, dis);    
				return col;
			}
			ENDCG
		}
	}
}
