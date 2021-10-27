texture tex0;
texture mask;

sampler Samp0 = sampler_state { Texture = <tex0>; };

sampler Samp1 = sampler_state { Texture = <mask>; };

float4 PS(float2 input : TEXCOORD0) : COLOR0 {
  float4 output;
  float4 mask;

  output = tex2D(Samp0, input);
  mask = tex2D(Samp1, input);
  output.a *= mask.a;
  return output;
}

technique {
  pass { PixelShader = compile ps_2_0 PS(); }
}
