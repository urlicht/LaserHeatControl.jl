module LaserHeatControl

using NIDAQ, PyPlot, Optim, DSP, Statistics, ProgressMeter

printstyled("WARNING: risk of permanant eye damamge. 
Using this class 4 laser requires training and approval."; color = :red)

include("constant.jl")
include("model_fit.jl")
include("nidaq.jl")
include("pulse_meas.jl")
include("thermistor.jl")

# pulse_meas.jl
export pulse_model_fit,
    pulse_align,
    # model_fit.jl
    fit_laser_model

end # module
