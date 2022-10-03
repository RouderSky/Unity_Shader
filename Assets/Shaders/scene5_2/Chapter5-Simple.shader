Shader "Unity Shaders Book/Chapter 5/Simple shader"
{
	//可有可无
	Properties
	{
		_Color ("Color Tint",Color) = (1.0,1.0,1.0,1.0)
	}

	//POSITION,NORMAL,TANGENT这些语义的数据是由unity的MeshRender提供的
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert		//告诉unity哪个是顶点着色器函数
			#pragma fragment frag	//告诉unity哪个是片元着色器函数

			//SV类型的系统的数值能加上的时候尽量加上

			//定义顶点着色器的输入
			struct a2v
			{
				float4 vertex : POSITION;		//用当前顶点的模型空间位置填充
				float3 normal : NORMAL;			//用当前顶点的法线填充
				float4 texcoord : TEXCOORD0;	//用当前顶点纹理坐标填充
			};

			//定义顶点着色器的输出
			struct v2f
			{
				float4 pos : SV_POSITION;	//SV_POSITION告诉Unity，这个变量存储了裁剪空间坐标；从顶点着色器到片元着色器必须要有的数据，只有这个类型具有特殊意义；其它数据都是用户自己使用，渲染管线不管；
				fixed3 color : COLOR0;
			};


//			//这个函数每次处理一个顶点，逐顶点操作
//			float4 vert(float4 v : POSITION) : SV_POSITION		//POSITION是顶点的模型空间坐标，SV_POSITION代表函数的返回值是齐次裁剪空间的坐标
//			{
//				return mul (UNITY_MATRIX_MVP,v);	//转换到齐次裁剪空间
//			}

//			//这个函数每次处理一个顶点，逐顶点操作
//			float4 vert(a2v v) : SV_POSITION		//POSITION是顶点的模型空间坐标，SV_POSITION代表函数的返回值是齐次裁剪空间的坐标?是的
//			{
//				return mul (UNITY_MATRIX_MVP,v.vertex);
//			}
			
			//这个函数每次处理一个顶点，每个顶点是根据顶点着色器的输出进行插值得到的
//			fixed4 frag() : SV_Target	//SV_Target告诉unity将输出存储到一个渲染目标这里输出到默认的帧缓存
//			{
//				return fixed4(1.0,1.0,1.0,1.0);		//fixed用来存储颜色RGB数值
//			}


			//为什么这个函数可以没有SV_POSITION？自答：因为返回类型并不是单纯的齐次裁剪空间坐标
			v2f vert(a2v v)		
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);	
				return o;
			}

			//frag函数的输入值就是vert函数的返回值的插值
			//frag函数是逐像素操作的，每一个像素都会调用一次frag函数
//			fixed4 frag(v2f i) : SV_Target
//			{
//				return fixed4(i.color,1.0);
//			}

			//在CG代码中，需要定义一个与属性名称和类型都匹配的变量；在unity中，前面的uniform是可以省略的
			uniform fixed4 _Color;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 c = i.color;
				c *= _Color.rgb;		//使用_Color来控制颜色
				return fixed4(c,1.0);
			}

			ENDCG
		}
	}
}
