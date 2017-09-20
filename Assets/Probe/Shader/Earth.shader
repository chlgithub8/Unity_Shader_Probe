Shader "Demon/Earth"
{
	Properties 
	{
		_AtmosphereColor ("Atmosphere Color", Color) = (0.1, 0.35, 1.0, 1.0)
		_AtmospherePow ("Atmosphere Power", Range(1.5, 8)) = 3
		_AtmosphereMultiply ("Atmosphere Multiply", Range(1, 3)) = 1.5
		_DiffuseTex("Diffuse", 2D) = "white" {}
		_CloudAndNightTex("Cloud", 2D) = "white" {}	
		_CloudSpeed("Cloud Speed", Range(0, 0.2)) = 0.01	
	}

	SubShader 
	{
		pass
		{
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert 
			#pragma fragment frag
			
			sampler2D _DiffuseTex;
			sampler2D _CloudAndNightTex;
			float4 _CloudAndNightTex_ST;
			fixed _CloudSpeed;

			fixed4 _AtmosphereColor;
			half _AtmospherePow;
			half _AtmosphereMultiply;

			struct vertexInput 
			{
				float4 pos				: POSITION;
				float3 normal			: NORMAL;
				float2 uv				: TEXCOORD0;
			};

			struct vertexOutput 
			{
				float4 pos			: SV_POSITION;
				float4 uv			: TEXCOORD0;
				half4 atmosphere	: TEXCOORD1;
			};
			
			vertexOutput vert(vertexInput input) 
			{
				vertexOutput output;
				output.pos = mul(UNITY_MATRIX_MVP, input.pos);

				fixed2 cloudSpeed = fixed2(frac(_Time.y * _CloudSpeed), 0);
				output.uv.xy = input.uv - cloudSpeed;
				output.uv.zw = input.uv + cloudSpeed;

				float3 lightDir = normalize(UnityWorldSpaceLightDir(input.pos));
				float3 normalDir = normalize(UnityObjectToWorldNormal(input.normal));
				output.atmosphere.w = saturate(dot(lightDir, normalDir) * 1.3);			
				
				half3 viewDir = normalize(ObjSpaceViewDir(input.pos));
				output.atmosphere.xyz = _AtmosphereColor.rgb * pow(1 - saturate(dot(viewDir, input.normal)), _AtmospherePow) * _AtmosphereMultiply;

				return output;
			}

			half4 frag(vertexOutput input) : SV_Target
			{
				half3 daySample = tex2D(_DiffuseTex, input.uv.xy).rgb;
				daySample += tex2D(_CloudAndNightTex, input.uv.zw).r;	
				daySample += input.atmosphere.xyz;
				half3 nightSample = tex2D(_CloudAndNightTex, input.uv.xy).ggb * 0.3;

				half4 result;
				result.rgb = lerp(nightSample, daySample, input.atmosphere.w);
				result.a = 1;
				return result;
			}
			ENDCG
		}
	}	
	Fallback "Diffuse"
}