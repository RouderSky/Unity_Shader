// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//逐顶点漫反射光照:速度快，但是如果模型顶点比较少，渲染的效果就可能不好看

Shader "Unity Shader Book/Chapter 6/Diffuse Vertex-Level"
{
	Properties
	{
		_Diffuse ("Diffuse",Color) = (1,1,1,1)	//材质的漫反射颜色
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//先将顶点数据转换到齐次裁剪空间
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);		

				//获取unity当前环境光属性;这种神奇的xyz写法;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;	
				
				//将法线转换世界坐标再进行归一化,注意：这里使用了左乘
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

				//将世界坐标中该顶点接收到的光的方向向量归一化；
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//使用兰伯特定律计算漫反射：入射光的颜色*漫反射颜色系数*max（0，dot（顶点法线单位矢量，光源的方向））;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));	//_LightColor0可以获得入射光颜色

				o.color = ambient + diffuse;

				return o;
			
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}

			ENDCG

		}
	}

	Fallback"Diffuse"

}
