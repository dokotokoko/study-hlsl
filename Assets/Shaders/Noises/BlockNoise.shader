// このシェーダーはUV空間を指定した分割数（_Scale）で格子状に分割し、
// 各ブロックごとにランダムなグレースケール値を生成して表示します。
// ブロックごとの乱数は、各格子のインデックス（floor(uv * _Scale)）を使って計算され、
// その値をAlbedoに反映することで、モザイク状のノイズパターンを作ります。
Shader "Custom/BlockNoise"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Scale ("Number of Divisions", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        float _Scale;

        float random(fixed2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
        }

        float blockNoise(float2 uv, float scale)
        {
            // floor(): 小数点以下を切り捨てて整数にする（例：2.7→2, -2.7→-3）
            // これによりuv空間を「scale×scale」の格子に分割できる
            float2 grid = floor(uv * scale);
            
            return random(grid);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float c = blockNoise(IN.uv_MainTex, _Scale);
            o.Albedo = fixed4(c,c,c,1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
