// このシェーダーはUV座標ごとにランダムなノイズ(値)を生成し、テクスチャ(色)として表示します。
// rand関数はUV座標と時間を使って擬似乱数を生成します。
// surf関数内でこの乱数値を使い、Albedo（色）にグレースケールで反映します。
Shader "Custom/RandomNoise"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
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

        float rand(float2 uv)
        {
            // dot(): 2つのベクトルの内積を計算する（例：a.x*b.x + a.y*b.y）
            // この場合、uv座標に2つの大きな素数を掛けて足し合わせている。
            // 素数を使う理由：よりランダムに見えるため。変更可能だが、同じ値でないと「乱数の種」が変わる。
            float n = dot(uv, float2(12.9898, 78.233));  // 12.9898, 78.233は"乱数の種"としてよく使われる固定値

            // sin(): サイン関数。周期的に値が変わる（-1〜1の間で波のような値）。
            // 擬似的に乱数性を加えるのに使う。
            float s = sin(n);
            
            // 43758.5453は大きな定数。sinの結果を0〜1の範囲に分布させるために掛ける
            // この値も"乱数の質"を調整するための有名な値。sin関数の周期（2π ≈ 6.28）と関係するが、基本的にこのまま使う 
            float r = s * 43758.5453;

            // frac(): 小数部分だけを取り出す（例：1.75 → 0.75、-1.75 → 0.25）
            // これで[0,1)の範囲に収まる「乱数」を得る   
            return frac(r);
        }

        float random(fixed2 p)
        {
            return rand(p);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float c = random(IN.uv_MainTex);
            o.Albedo = fixed4(c,c,c,1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
