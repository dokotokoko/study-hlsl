Shader "Custom/MovingCircle"
{
    Properties
    {
        _BackColor("Back Color", Color) = (1,1,1,1)
        _LineColor("Line Color", Color) = (1,1,1,1)
        _pt("line point", range(0,1)) = 0.1
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard
        #pragma target 3.0

        fixed4 _BackColor;
        fixed4 _LineColor;
        float _pt;

        struct Input
        {
            float3 worldPos;
        };

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float dist = distance(fixed3(0,0,0), IN.worldPos);
            float radius = 2;
            float val = abs(sin(dist*3.0 - _Time*100));

            if(val < _pt) 
            {
                o.Albedo = _LineColor;
            }
            else
            {
                o.Albedo = _BackColor;
            }
        }
        ENDCG
    }
    FallBack "Diffuse"
}
