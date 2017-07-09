Shader "Unity Shaders Book/Chapter 5/False Color"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//法线
				o.color = fixed4(v.normal * 0.5 + fixed3(0.5,0.5,0.5),1.0);

				//切线
//				o.color = fixed4(v.tangent * 0.5 + fixed3(0.5,0.5,0.5),1.0);		//为什么fixed4可以和fixed3进行相加

				//副切线
				fixed3 binormal = cross(v.normal,v.tangent.xyz) * v.tangent.w;		//为什么要乘上w分量？w分量是用来修正副切线的方向的
//				o.color = fixed4(binormal * 0.5 + fixed3(0.5,0.5,0.5),1.0);

				//可视化第一组纹理坐标
//				o.color = fixed4(v.texcoord.xy,0.0,1.0);	//这里这个用法好奇怪，fixed4有多少种构造方法，texcoord取值的方法

				//可视化第二组纹理坐标
//				o.color = fixed4(v.texcoord1.xy,0.0,1.0);	//这里这个用法好奇怪，fixed4有多少种构造方法，texcoord1取值的方法
			
				//可视化第一组纹理坐标的的小数部分，没看懂？？？
//				o.color = frac(v.texcoord);
//				if(any(saturate(v.texcoord) - v.texcoord))
//					o.color.b = 0.5;
//				o.color.a = 1.0;

				//可视化顶点颜色
//				o.color = v.color;

				return o;

			}

			fixed4 frag(v2f i) : SV_Target
			{
				return i.color;
			}

			ENDCG

		}
	}
}
