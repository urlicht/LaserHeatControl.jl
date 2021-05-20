empty_str = ""
ptr_empty_str = pointer(empty_str)

function configure_daqmx_pulse_measure(task_ai=nothing, task_ao=nothing)
    task_ai = isnothing(task_ai) ? analog_input("$DEV_NAME/ai2, $DEV_NAME/ai3, $DEV_NAME/_ao0_vs_aognd",
        terminal_config=NIDAQ.Differential, range=[-10,10]) : task_ai
    task_ao = isnothing(task_ao) ? analog_output("$DEV_NAME/ao0", range=[-10,10]) : task_ao

    NIDAQ.catch_error(NIDAQ.DAQmxCfgSampClkTiming(task_ai.th, ptr_empty_str, SAMPLE_RATE_AI, NIDAQ.DAQmx_Val_Rising,
        NIDAQ.DAQmx_Val_ContSamps, SAMPLE_RATE_AI))
    NIDAQ.catch_error(NIDAQ.DAQmxCfgSampClkTiming(task_ao.th, "ai/SampleClock", SAMPLE_RATE_AI, NIDAQ.DAQmx_Val_Rising,
        NIDAQ.DAQmx_Val_ContSamps, SAMPLE_RATE_AI))

    task_ai, task_ao
end