// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//逐像素漫反射光照(半兰伯特模型):在兰伯特模型的基础上进行视觉增强，使得背光面也出现明暗变化

Shader "Unity Shader Book/Chapter 6/Diffuse Vertex-Level HalfLambert"
{
	Properties
	{
		_Diffuse ("Diffuse",Color) = (1,1,1,1)	//材质的漫反射颜色
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}	//干什么的？可以得到Unity的一些内置光照变量，如_LightColor0(入射光颜色)

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"	//为了使用Unity内置变量

			fixed4 _Diffuse;	//再声明，为了使用属性里面的变量，如_LightColor0(入射光颜色)

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;		//这个NORMAL是模型空间的
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TexCoord0;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//先将顶点数据转换到齐次裁剪空间
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);		

				//将法线转换世界坐标注意：这里使用了左乘
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);		//为什么这个矩阵一定是正交的？因为我们的模型前提是没有进行缩放的

				return o;
			
			}

			//将所有的运算都搬到了片元着色器中，片元着色器应该是逐像素操作的，不然为什么光照模型放到这边之后运算量会增大；如果是这样，那么片元着色器的输入值应该是顶点数据的插值
			fixed4 frag(v2f i) : SV_Target
			{
				//获取unity当前环境光属性;这种神奇的xyz写法;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;	

				//将世界法线归一化
				fixed3 worldNormal = normalize(i.worldNormal);

				//将世界坐标中该顶点接收到的光的方向向量归一化；
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//使用半兰伯特定律计算漫反射：入射光的颜色*漫反射颜色系数*max（0，dot（顶点法线单位矢量，光源的方向））;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(0.5*dot(worldNormal,worldLight+0.5));	//_LightColor0可以获得入射光颜色

				fixed3 color = ambient + diffuse;

				return fixed4(color, 1.0);
			}

			ENDCG

		}
	}

	Fallback"Diffuse"

}