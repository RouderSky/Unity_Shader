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
		_MainTex("Main Tex",2D) = "white" {}	//花括号什么意思？？？
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}		//LightMode标签是Pass标签的其中之一，定义了该Pass在Unity的光照流水线中的角色

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"	//为了获得顶点光照颜色_LightColor0

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;		//这个变量名字是规定的，格式为：纹理名_ST，可以得到对应纹理的缩放xy和平移zw； tiling代表材质空间是纹理空间的几倍，offset代表材质空间的原点在纹理空间中的什么地方；
			float4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;	//该顶点在第一张纹理中的坐标
			};

			struct v2f
			{
				float4 pos : SV_POSITION;		//这个声明打上之后，在顶点着色器函数返回信息的时候，信息会自动提取这个信息，然后继续传给片元着色器
				float3 worldNormal : TEXCOORD0;	//更上面的结构体的意义不同，这里的这个没有特殊含义
				float3 worldPos : TEXCOORD1;	//.............
				float2 uv : TEXCOORD2;
			};

			//只有顶点着色器可以获得顶点的详细信息
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;			//..........
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;		//将材质空间中的纹理坐标转换到纹理空间中，准没错
				//使用内置函数：o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;

			}

			//片元着色器想要获得顶点模型坐标、法线等信息必须要通过顶点着色器接收
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos)); 

				//纹理采样：采样时万一坐标uv坐标超出了范围[0,1]，就要依据纹理的导入设置来决定如果处理，有两种方式：repeat、clamp
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;	//为什么是逐分量相乘？？？
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;	//为什么是逐分量相乘？？？为什么环境光要这样算？？？

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//高光反射
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);	//为什么是将所有的颜色加起来？？？
			}

			ENDCG

		}
	}

	Fallback "Specular"
}