Shader "Custom/WaterSurface"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveSpeed_y("y speed", Float) = 1.0
        _WaveSpeed_x("x speed", Float) = 1.0
    }

    SubShader
    {
        Tags {"RenderType" = "Opaque"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        float _WaveSpeed_x;
        float _WaveSpeed_y;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed2 uv = IN.uv_MainTex;
            uv.x += _WaveSpeed_x * _Time;
            uv.y += _WaveSpeed_y * _Time;
            o.Albedo = tex2D(_MainTex, uv);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
