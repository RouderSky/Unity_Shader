// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//这里计算高光的公式是非线性的，但是顶点的像素插值是线性的，所以通过逐顶点计算的高光，会被片元着色器的输入插值破坏

Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level"
{
	Properties
	{
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;		//顶点颜色
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//顶点世界法线
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

				//光线方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//计算漫反射：兰伯特定律
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

				//光线反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));

				//观察方向,顶点到摄像机的向量
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);

				//计算高光，Phone模型
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);

				//光照模型之间的运算时可叠加的
				o.color = ambient + diffuse + specular;

				return o;

			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color,1.0);
			}

			ENDCG

		}
	}

	Fallback "Specular"
}
