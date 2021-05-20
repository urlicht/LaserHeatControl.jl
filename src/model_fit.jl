function fit_laser_model(list_U, list_v, list_t; plot_model=true)
    # detect heat on period
    idx_start = findfirst(list_v .> 1.1)
    idx_end = findlast(list_v .> 1.1)

    U0 = mean(list_U[1:5000])
    list_U_heat = list_U[idx_start:idx_end]
    list_t_heat = collect(0:length(list_U_heat)-1) ./ 1000;
    list_U_cool = list_U[idx_end:end] .- U0
    U_max_cool = maximum(list_U_cool)
    list_U_cool_norm = list_U_cool / U_max_cool
    list_t_cooling = collect(0:length(list_U_cool_norm)-1) ./ 1000

    # Umax * exp(-β*t)
    model_cooling(x, p) = exp.(-x * p[1])
    model_cooling_cost(p) = sum((model_cooling(list_t_cooling, p) .- list_U_cool_norm) .^ 2)
    optim_cool = optimize(model_cooling_cost, [1.0], ConjugateGradient())

    β = (optim_cool.minimizer[1])
    τ = log(2) / β
    
    α = let 
        dt = length(idx_start:idx_end) / 1000
        dT = list_U[idx_end] - list_U[idx_start]
        (dT + dt * β * list_U[idx_start]) / (dt * 2)
    end
    
    if plot_model
#         figure(figsize=(4,4))
#         plot(list_t_cooling, data_cooling_norm, label="data")
#         plot(list_t_cooling, model_cooling(list_t_cooling, optim_cool.minimizer), label="model")
#         xlabel("t (s)")
#         ylabel("U (norm)")
#         legend()
#         tight_layout()
    end

    println("α = $(α) deg C / (A s)")
    println("β = $(β) / s")
    println("half decay = $(log(2)/β) s")

    α, β, τ
end