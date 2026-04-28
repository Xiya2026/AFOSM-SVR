function out = uq_call_with_reinitialize(fun_handle, cfg)
try
    out = fun_handle();
catch ME
    if should_retry_uqlab_reinitialize(ME)
        force_uqlab_reinitialize(cfg);
        out = fun_handle();
    else
        rethrow(ME);
    end
end
end


