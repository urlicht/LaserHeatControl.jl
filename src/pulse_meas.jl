const af_lp = digitalfilter(Lowpass(20, fs=1000), FIRWindow(hamming(61)))

function filter_voltage(list_v)
    filtfilt(af_lp, list_v)
end

function process_pulse_meas(ai_res)
    v_ratio_list = ai_res[:,1] ./ ai_res[:,2]
    v_ratio_list_filt = filter_voltage(v_ratio_list)

    list_U = v_ratio_to_temp_celcius.(v_ratio_list_filt)
    list_t = collect(1:length(list_U)) ./ 1000
    list_v = ai_res[:,3]
    list_U_Δ = list_U .- mean(list_U[1:50])
    U_max = maximum(list_U_Δ)
    
    list_U, list_v, list_t
end

function plot_pulse_meas(list_U, list_v, list_t)
    list_ΔU = list_U .- mean(list_U[1:50])
    ΔU_max = maximum(list_ΔU)
    
    figure(figsize=(4,4))
    subplot(2,1,1)
    plot(list_t, list_ΔU)
    title("ΔU_max = $(round(ΔU_max, digits=3)) deg C")
    ylabel("ΔU (deg C)")
    xlabel("time (s)")
    savefig("temp plot")
    subplot(2,1,2)
    title("control voltage")
    ylabel("V")
    xlabel("time (s)")
    plot(list_t, list_v)
    tight_layout()
    
    nothing
end

function pulse_model_fit(; task_ai=nothing, task_ao=nothing, plot_meas=false)
    task_ai, task_ao = configure_daqmx_pulse_measure(task_ai, task_ao)

    list_ai_read = []
    q_record = true
    @async begin
        # start DI task first since it is dependent on AI
        start(task_ao)
        start(task_ai)
        sleep(0.1)

        while q_record
            push!(list_ai_read, read(task_ai, SAMPLE_RATE_AI))
            sleep(0.1)
        end

        stop(task_ao)
        stop(task_ai)
    end
    
    # laser pulse
    sleep(10)
    ao_buffer = zeros(Float64, 4000)
    ao_buffer[1:3000] .= 1.925/2 * 10
    write(task_ao, ao_buffer)

    # wait for cool down
    @showprogress for i = 1:(10*120)
        sleep(0.1)
    end
    q_record = false
    clear(task_ai)
    clear(task_ao)
    ai_res = vcat(list_ai_read...)
    
    # get temp
    list_U, list_v, list_t = process_pulse_meas(ai_res)    
    plot_meas && plot_pulse_meas(list_U, list_v, list_t)
    
    list_U, list_v, list_t
end

function pulse_align(; task_ai=nothing, task_ao=nothing, plot_meas=false)
    task_ai, task_ao = configure_daqmx_pulse_measure(task_ai, task_ao)
    
    list_ai_read = []
    q_record = true
    @async begin
        # start DI task first since it is dependent on AI
        start(task_ao)
        start(task_ai)
        sleep(0.1)

        while q_record
            push!(list_ai_read, read(task_ai, SAMPLE_RATE_AI))
            sleep(0.1)
        end

        stop(task_ao)
        stop(task_ai)
    end

    # laser pulse
    sleep(0.1)
    ao_buffer = zeros(Float64, 200)
    ao_buffer[1:100] .= 1.925/2 * 10
    write(task_ao, ao_buffer)

    # stop recording
    sleep(1)
    q_record = false
    clear(task_ai)
    clear(task_ao)
    ai_res = vcat(list_ai_read...)
    
    # get temp
    list_U, list_v, list_t = process_pulse_meas(ai_res)    
    plot_meas && plot_pulse_meas(list_U, list_v, list_t)
    
    list_U, list_v, list_t
end