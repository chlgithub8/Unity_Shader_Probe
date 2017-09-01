Shader "Demon/Swing" {
    Properties {
        _Diffuse("漫反射颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _Speed("动画速度(xyz)和Z方向振幅(w)", Vector) = (1.0, 1.0, 1.0, 1.0)
    }

    SubShader {
    	Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True"}
        Pass {
            Tags{"LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha 
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 color : TEXCOORD0;
            };

            fixed4 _Diffuse;
            float4 _Speed;

            v2f vert(a2v v) {
                v2f o;
                float3 offset = float3 (0,0,0);
                float dis = distance(v.vertex.xyz, offset);
                offset.x = sin(_Time.y * _Speed.x + dis);
                offset.y = sin(_Time.y * _Speed.y + dis);
                offset.z = _Speed.w * sin(_Time.y * _Speed.z + dis);
                v.vertex.xyz += offset;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

                float3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));           
                float3 lightDir = normalize(WorldSpaceLightDir (v.vertex));
                fixed diff = dot(normalDir, lightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * diff;

                o.color = fixed4(diffuse, _Diffuse.a);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
             	return  i.color;   
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}