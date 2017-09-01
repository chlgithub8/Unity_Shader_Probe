Shader "Demon/LightPixel" {
    Properties {
        _Diffuse("漫反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("高光反射", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("高光强度", Range(1,100)) = 1
    }

    SubShader {
        Pass {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 normalDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert(a2v v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.normalDir = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 normalDir = normalize(i.normalDir);           
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //fixed lambert = saturate(dot(normalDir , lightDir));
                //fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lambert;

                fixed halflambert = dot(normalDir , lightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halflambert;

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                //float3 reflectDir = normalize(reflect(-lightDir, normalDir));
                //fixed phongSpe = pow(saturate(dot(viewDir, reflectDir)), _Gloss);
                //float3 specular = _LightColor0.rgb * _Specular.rgb * phongSpe;

                float3 halfDir = normalize(lightDir + viewDir );
                float3 blinnPhongSpe  = pow(saturate(dot(halfDir, normalDir)), _Gloss);
                float3 specular = _LightColor0.rgb * _Specular.rgb * blinnPhongSpe;

                fixed3 color = ambient + diffuse + specular;
             	return  fixed4(color, 1.0);   
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}