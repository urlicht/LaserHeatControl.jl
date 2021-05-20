# thermistor
const thermistor_list_T = collect(-10:10:70) .+ 273.15 # kelvin
const thermistor_list_R = 1e3 * [100.3, 62.92, 40.56, 26.82, 18.16, 12.58, 8.892, 6.407, 4.700] # Ohm
const SH_A, SH_B, SH_C = 0.0006635504917642715, 0.00025902522628296846, 1.0045064654811129e-7

# wheastone
const R_W1, R_W2, R_W3 = 21.93, 21.89, 21.99

# nidaq
const SAMPLE_RATE_AI = 1000 # Hz
const DEV_NAME = "Dev1"
