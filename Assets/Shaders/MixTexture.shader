Shader "Custom/MixTexture"
{
    Properties
    {
        _Texture1("Texture 1", 2D) = "white"{}
        _Texture2("Texture 2", 2D) = "white"{}
        _MaskTex("Mask Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _Texture1;
        sampler2D _Texture2;
        sampler2D _MaskTex;

        struct Input
        {
            float2 uv_Texture1;   // 1 枚目の UV
            float2 uv_Texture2;   // 2 枚目の UV
            float2 uv_MaskTex;    // マスクの UV
        };

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c1 = tex2D(_Texture1, IN.uv_Texture1);
            fixed4 c2 = tex2D(_Texture2, IN.uv_Texture2);
            fixed4 p = tex2D(_MaskTex, IN.uv_MaskTex);

            o.Albedo = lerp(c1, c2, p);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
