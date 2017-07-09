// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Specular Blinn-Phong UseBuildInFunction pixel-Level"
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
			Tags{"LightMode" = "ForwardBase"} //？？？

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;	//用到齐次坐标的地方并不多，一般只在顶点变换的过程中用到
				float3 normal : NORMAL;
			};

			//顶点着色器的输入都是模型空间中的数值
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;		//
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//顶点世界法线
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//顶点世界坐标
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//归一化的世界法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//光线方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//计算漫反射：兰伯特定律
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

				//观察方向,顶点到摄像机的向量
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//h向量
				fixed3 halfDir = normalize(worldLightDir+viewDir);

				//计算高光,Blinn-Phong模型
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				//光照模型之间的运算时可叠加的
				return fixed4(ambient + diffuse + specular,1.0);

			}

			ENDCG

		}
	}

	Fallback "Specular"
}