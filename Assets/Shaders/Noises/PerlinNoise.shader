// このシェーダーは2Dパーリンノイズを生成し、UV空間上で滑らかなノイズパターンを表示します。
// 各格子点にランダムな勾配ベクトルを割り当て、格子内の位置ベクトルとの内積を計算し、
// スムーズステップ関数で補間することで、連続的かつ自然なノイズを作り出します。

// perlinNoise2とperlinNoiseの違い
// perlinNoise2:
//   - 各格子点に「gradient」関数で単位勾配ベクトル（方向のみ）を生成
//   - ピクセル位置から各格子点への距離ベクトルを計算
//   - 勾配ベクトルと距離ベクトルの内積を計算
//   - その内積値をスムーズステップ関数で補間
//   - 出力値の範囲調整は特に行わず、-1～1程度の値を返す
//
// perlinNoise:
//   - 各格子点に「random2」関数でランダムな2Dベクトル（方向・大きさともにランダム）を生成
//   - 距離ベクトルとランダム2Dベクトルの内積を計算しつつ、補間も同時に行う
//   - 最後に+0.5fして出力値を0～1程度に持ち上げている
//
// まとめ:
//   - perlinNoise2は「勾配ベクトル生成→距離ベクトル→内積→補間」と各工程が明確
//   - perlinNoiseは「ランダム2Dベクトル→内積と補間を一体化」して計算が簡略化されている
//   - 出力範囲調整の有無も異なる

Shader "Custom/PerlinNoise"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Scale("Num of Div", Float) = 0.1
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

        fixed2 random2 (fixed2 uv)
        {
            uv = fixed2(dot(uv, fixed2(127.1,311.7)), dot(uv, fixed2(269.5,183.3)));

            return -1.0 + 2.0 * frac(sin(uv) * 43758.5453123);          
        }

        // 各格子点に乱数から「勾配ベクトル」を作る
        float2 gradient(float2 p)
        {
            // 0〜2πの範囲で角度を決め、単位円上のベクトルを作る
            float angle = random(p) * 6.2831853; // 6.283... = 2π
            return float2(cos(angle), sin(angle)); // 単位円上のランダム方向
        }

        // perlinNoise2関数の処理内容
        // 1. 入力座標uvを整数部（ip: 格子点座標）と小数部（fp: 格子内の位置）に分解
        // 2. 4つの格子点（左上・右上・左下・右下）それぞれで、gradient関数を使いランダムな勾配ベクトルを生成
        // 3. 各格子点から現在位置へのベクトル（d00, d10, d01, d11）を計算
        // 4. 各格子点の勾配ベクトルと距離ベクトルの内積（v00, v10, v01, v11）を計算
        // 5. スムーズステップ関数（f = fp * fp * (3.0 - 2.0 * fp)）で補間用の重みを計算
        // 6. x方向に線形補間（nx0, nx1）、さらにy方向に線形補間して最終ノイズ値を得る
        float perlinNoise2(float2 uv)
        {
            float2 ip = floor(uv);  // 格子点座標
            float2 fp = frac(uv);   // 格子内の位置

            // 各格子点で勾配ベクトルを生成
            float2 g00 = gradient(ip);
            float2 g10 = gradient(ip + float2(1, 0));
            float2 g01 = gradient(ip + float2(0, 1));
            float2 g11 = gradient(ip + float2(1, 1));

            // 各格子点からピクセルへのベクトル
            float2 d00 = fp - float2(0, 0);
            float2 d10 = fp - float2(1, 0);
            float2 d01 = fp - float2(0, 1);
            float2 d11 = fp - float2(1, 1);

            // 内積（勾配ベクトル×距離ベクトル）→値
            float v00 = dot(g00, d00);
            float v10 = dot(g10, d10);
            float v01 = dot(g01, d01);
            float v11 = dot(g11, d11);

            // スムーズステップ補間。f*f*(3-2*f)は滑らかさを生む関数
            float2 f = fp * fp * (3.0 - 2.0 * fp);

            float nx0 = lerp(v00, v10, f.x);
            float nx1 = lerp(v01, v11, f.x);

            return lerp(nx0, nx1, f.y);
        }

        // perlinNoise関数の処理内容
        // 1. 入力座標stを整数部（p: 格子点座標）と小数部（f: 格子内の位置）に分解
        // 2. スムーズステップ関数（u = f * f * (3.0 - 2.0 * f)）で補間用の重みを計算
        // 3. 4つの格子点（左上・右上・左下・右下）それぞれで、random2関数を使いランダムな勾配ベクトルを生成
        // 4. 各格子点から現在位置へのベクトル（f - オフセット）と勾配ベクトルの内積を計算
        // 5. x方向に線形補間、さらにy方向に線形補間して最終ノイズ値を得る
        // 6. 値の範囲を調整するために+0.5fして返す
        float perlinNoise(fixed2 st) 
        {
            fixed2 p = floor(st);
            fixed2 f = frac(st);

            // スムーズステップ補間
            fixed2 u = f * f * (3.0-2.0*f);

            float v00 = random2(p + fixed2(0,0));
            float v10 = random2(p + fixed2(1,0));
            float v01 = random2(p + fixed2(0,1));
            float v11 = random2(p + fixed2(1,1));

            return lerp( lerp(dot(v00, f - fixed2(0,0)), dot(v10, f - fixed2(1,0)), u.x ),
                         lerp(dot(v01, f - fixed2(0,1)), dot(v11, f - fixed2(1,1)), u.x ), 
                         u.y) + 0.5f;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float c = perlinNoise2(IN.uv_MainTex * _Scale);     
            o.Albedo = fixed4(c,c,c,1);
            o.Metallic = 0;
            o.Smoothness = 0;
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
