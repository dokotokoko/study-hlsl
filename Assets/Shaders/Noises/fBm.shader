// このシェーダーはfBm（フラクタルブラウン運動）ノイズを生成します。
// fBm（fractal Brownian motion）は、パーリンノイズや値ノイズなどの基本ノイズを複数オクターブ重ね合わせることで、より複雑で自然な模様を作り出す手法です。
// 各オクターブごとに周波数を上げ、振幅を下げて合成することで、雲・大理石・山脈など自然界に見られる多重スケールのパターンを表現できます。
Shader "Custom/fBm"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // テスト用（未使用）
        _Scale ("Noise Scale", Float) = 8.0
        _Octaves ("Octaves", Int) = 5
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
        int _Octaves;

        struct Input
        {
            float2 uv_MainTex;
        };

        // 疑似乱数生成（ランダムな値を返す）
        float rand(float2 uv)
        {
            float n = dot(uv, float2(12.9898, 78.233));
            float s = sin(n);
            float r = s * 43758.5453;
            return frac(r);
        }

        // 勾配ベクトル生成（格子ごとの方向を乱数で決める）
        float2 gradient(float2 p)
        {
            float angle = rand(p) * 6.2831853; // 2π
            return float2(cos(angle), sin(angle));
        }

        // 線形補間
        float lerp2(float a, float b, float t)
        {
            return a + t * (b - a);
        }

        // パーリンノイズ
        float perlinNoise(float2 uv, float scale)
        {
            float2 p = uv * scale;
            float2 ip = floor(p);
            float2 fp = frac(p);

            float2 g00 = gradient(ip);
            float2 g10 = gradient(ip + float2(1, 0));
            float2 g01 = gradient(ip + float2(0, 1));
            float2 g11 = gradient(ip + float2(1, 1));

            float2 d00 = fp - float2(0, 0);
            float2 d10 = fp - float2(1, 0);
            float2 d01 = fp - float2(0, 1);
            float2 d11 = fp - float2(1, 1);

            float v00 = dot(g00, d00);
            float v10 = dot(g10, d10);
            float v01 = dot(g01, d01);
            float v11 = dot(g11, d11);

            // スムースステップで補間（滑らかな変化）
            float2 f = fp * fp * (3.0 - 2.0 * fp);
            float nx0 = lerp(v00, v10, f.x);
            float nx1 = lerp(v01, v11, f.x);
            return lerp(nx0, nx1, f.y);
        }

        // fBm: パーリンノイズ等を重ねる（複雑な自然模様を作る）
        float fbm(float2 uv, float scale, int octaves)
        {
            float value = 0.0;
            float amp = 0.5;
            float freq = 1.0;

            for (int i = 0; i < octaves; ++i)
            {
                value += perlinNoise(uv, scale * freq) * amp;
                freq *= 2.0;
                amp *= 0.5;
            }
            return value;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // fBmノイズ値を計算
            float n = fbm(IN.uv_MainTex, _Scale, _Octaves);

            // ノイズ値で色をグレーに設定（0〜1の範囲）
            o.Albedo = float3(n, n, n);
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
