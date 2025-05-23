Shader "Custom/RimLighting"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (1,1,1,1)
    }
    SubShader 
    {
        Tags {"RenderType" = "Opaque"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
        };

        fixed4 _BaseColor;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 rimColor = fixed4(0.5, 0.7, 0.5, 1);

            o.Albedo = _BaseColor.rgb;
            float rim = 1 - saturate(dot(IN.viewDir, o.Normal));
            o.Emission = rimColor * pow(rim, 2.5);
        }
        ENDCG
    }
    FallBack "Diffuse"
}