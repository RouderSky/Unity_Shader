// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//材质、纹理、着色器的关系：
//材质是用来收集各种数据的，如：漫反射颜色、高光反射度、纹理图片、自定义变量、材质空间相对于纹理空间的信息以及由meshRender传递过来的顶点信息，然后材质将这些数据传递给着色器；
//纹理只是材质的一种输入数据之一，这个数据有不同于一般的图片，而是一般的图片信息加上额外信息组成，如：WrapMode展开模式、FilterMode过滤模式（当图片呈现在摄像机中存在缩放是的抗锯齿效果）、Generate Mip Mapping生成多级渐远纹理（预先通过过滤生成大小不同的纹理）；
//着色器是对所有信息进行加工处理的场所，计算这个材质的最终渲染表现；
//ps：注意模型贴上的是材质，而不是纹理，所以我认为还有材质空间和纹理空间之分；

Shader "Unity Shaders Book/Chapter 7/Chapter 7/Single Texture"
{
	Properties
	{
		_Color ("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"	//为了获得顶点光照颜色_LightColor0

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;		//tiling代表材质空间是纹理空间的几倍，offset代表材质空间的原点在纹理空间中的什么地方；
			float4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				//原理：o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos)); 

				//纹理采样：采样时万一坐标uv坐标超出了范围[0,1]，就要依据纹理的导入设置来决定如果处理，有两种方式：repeat、clamp
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//高光反射
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);
			}

			ENDCG

		}
	}

	Fallback "Specular"
}
