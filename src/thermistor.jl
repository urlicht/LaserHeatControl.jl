## Steinhart-Hart
steinhart_hart(A,B,C,R) = A + B * log(R) + C * log(R) ^ 3
steinhart_hart(R) = steinhart_hart(SH_A, SH_B, SH_C, R)

## wheastone
function wheatstone(vg, vs, r1, r2, r3)
    (- r1 * r3 * vg - r2 * r3 * vg + r2 * r3 * vs) / (r1 * vg + r2 * vg + r1 * vs)
end

function wheatstone(v_ratio, r1, r2, r3)
    (r2 * (r3 - r1 * v_ratio - r3 * v_ratio))/(r1 + r1 * v_ratio + r3 * v_ratio)
end

vg_to_temp(vg, vs) = 1 / steinhart_hart(wheatstone(vg, vs, R_W1, R_W2, R_W3) * 1e3)

v_ratio_to_temp(v_ratio) = 1 / steinhart_hart(wheatstone(v_ratio, R_W1, R_W2, R_W3) * 1e3)
v_ratio_to_temp_celcius(v_ratio) = v_ratio_to_temp(v_ratio) - 273.15
