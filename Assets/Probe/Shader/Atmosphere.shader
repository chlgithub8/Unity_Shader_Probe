Shader "Demon/Atmosphere" 
{
	Properties 
	{
		_Color ("Color", Color) = (0.1, 0.35, 1.0, 1.0)
		_Intensity("Intensity", float) = 20
	}

	SubShader 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    	Pass 
    	{
    		Tags { "LightMode" = "ForwardBase" }
			Blend One One
			ZWrite Off
			Cull Front
		
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			float4 _Color;
			float _Intensity;

			struct vertexInput 
			{
				float4 pos				: POSITION;
				float3 normal			: NORMAL;
			};

			struct vertexOutput 
			{
				float4 pos				: SV_POSITION;
				float3 normal			: TEXCOORD0;
				float3 viewDir			: TEXCOORD1;
				fixed diffuse			: TEXCOORD2;
			};
			
			vertexOutput vert(vertexInput input) 
			{
				vertexOutput output;
				output.pos = mul(UNITY_MATRIX_MVP, input.pos);
				output.normal = input.normal;
				output.viewDir = ObjSpaceViewDir(input.pos);

				float3 lightDir = WorldSpaceLightDir(input.pos);
				output.diffuse = saturate(dot(input.normal, lightDir) * 3);
				return output;
			}
		
			float4 frag(vertexOutput input) : SV_Target
			{
				float3 viewDir = normalize(input.viewDir);
				float3 normalDir = normalize(input.normal);
				float alpha = pow(saturate(dot(viewDir, -normalDir)), 3) * _Intensity;
				float4 result;
				result.rgb = _Color.rgb * input.diffuse * alpha;
				result.a = 1;
				return result;
			}

			ENDCG

    	}
	}
}
