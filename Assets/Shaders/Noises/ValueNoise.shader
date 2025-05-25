Shader "Custom/ValueNoise"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Scale("Num of Div", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        float _Scale;

        struct Input
        {
            float2 uv_MainTex;
        };

        float random(fixed2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
        }

        float blockNoise(fixed2 uv, float scale)
        {
            float2 grid = floor(uv * scale);
            
            return random(grid);            
        }

        // 格子点に乱数値を持たせ、その間をより滑らかに補間するノイズ
        float valueNoise2(fixed2 st, float scale)
        {
            fixed2 v = st * scale;
            fixed2 p = floor(v);
            fixed2 f = frac(v);

            float v00 = random(p + fixed2(0,0));
            float v10 = random(p + fixed2(1,0));
            float v01 = random(p + fixed2(0,1));
            float v11 = random(p + fixed2(1,1));
            
            // uは補間用の重みを計算するための変数です。
            // f * f * (3.0 - 2.0 * f) はスムーズステップ関数（イーズイン・イーズアウト補間）であり、
            // 線形補間よりも滑らかに格子点間をつなぐために使われます。
            // これによりノイズの連続性が向上し、滑らかなグラデーションが得られます。
            fixed2 u = f * f * (3.0 - 2.0 * f);            

            float v0010 = lerp(v00, v10, u.x);
            float v0111 = lerp(v01, v11, u.x);

            return lerp(v0010, v0111, u.y);
        }

        // 格子点に乱数値を持たせ、その間を滑らかに補間するノイズ
        float valueNoise(fixed2 uv, float scale)
        {
            fixed2 p = uv * scale; // スケールで拡大
            fixed2 ip = floor(p); // 格子点座標（左上整数点）
            fixed2 fp = frac(p); // 小数部分（格子内の位置）

            // 4隅の格子点で乱数を取得
            float v00 = random(ip + fixed2(0,0));
            float v10 = random(ip + fixed2(1,0));
            float v01 = random(ip + fixed2(0,1));
            float v11 = random(ip + fixed2(1,1));          
            
            // x軸で線形補間
            float v0010 = lerp(v00, v10, fp.x);
            float v0111 = lerp(v01, v11, fp.x);

            // lerp(float a, float b, float t) : aからbまで、tの割合で補間（0ならa, 1ならb, 0.5なら中間）
            // y軸でさらに線形補間
            return lerp(v0010, v0111, fp.y);
        }


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float c = valueNoise2(IN.uv_MainTex, _Scale);
            o.Albedo = fixed4(c,c,c,1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
