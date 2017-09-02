Shader "Demon/Unlit/ToonOutline"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_Ramp ("Ramp Texture", 2D) = "white" {}
		_Outline ("Outline", Range(0.0, 1.0)) = 0.1
		_OutlineColor ("Outline Colort", Color) = (0, 0, 0, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_SpecularScale ("Specular Scale", Range(0.0, 0.1)) = 0.05
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "AutoLight.cginc" 

		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;				
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
		};

		fixed _Outline;
		fixed4 _OutlineColor;

		v2f vert (appdata v)
		{
			v2f o;
			float4 viewpos = mul(UNITY_MATRIX_MV, v.vertex);
			float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			normal.z = -0.5;
			viewpos += float4(normalize(normal), 0) * _Outline;
			o.pos = mul(UNITY_MATRIX_P, viewpos);
			return o;
		}
		
		fixed4 frag (v2f i) : SV_Target
		{
			return _OutlineColor;
		}

		struct appdata_n
		{
			float4 vertex : POSITION;			
			float2 uv : TEXCOORD0; 
			float3 normal : NORMAL;

		};

		struct v2f_n
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
			SHADOW_COORDS(3)
		};

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _Ramp;
		fixed4 _Specular;
		float  _SpecularScale;

		v2f_n vert_n (appdata_n v)
		{
			v2f_n o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			TRANSFER_SHADOW(o);			
			return o;
		}
		
		fixed4 frag_n (v2f_n i) : SV_Target
		{
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			fixed3 worldHalfDir = normalize(worldViewDir + worldLightDir);

			fixed4 c = tex2D(_MainTex, i.uv);
			fixed3 albedo = c.rgb * _Color.rgb;

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			fixed diff = (dot(worldNormal, worldLightDir) * 0.5 + 0.5) * atten;
			fixed3 diffuse = _LightColor0 * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;

			fixed spec = dot(worldNormal, worldHalfDir);
			//抗锯齿处理
			fixed w = fwidth(spec) * 3.0;
			spec = lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1.0));

			fixed3 specular = _Specular.rgb * spec * step(0.0001, _SpecularScale);
			return fixed4(ambient + diffuse + specular, 1.0);
		}

		ENDCG

		Pass
		{
			NAME "OUTLINE"			
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Cull Back

			CGPROGRAM
			#pragma vertex vert_n
			#pragma fragment frag_n
		    #pragma multi_compile_fwdbase
			ENDCG
		}
	}
	Fallback "Diffuse"
}
