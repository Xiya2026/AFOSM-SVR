function txt = summarize_uqlab_analysis_object(myRel)
% summarize_uqlab_analysis_object: Helper function in the AFOSM-SVR modular workflow.
txt = "";
try
    rel_norm = normalize_container_for_scan(myRel);
    rel_fields = get_container_fieldnames(rel_norm);
    rel_top = strjoin(rel_fields(:).', ",");
catch
    rel_top = "";
end

try
    if isstruct(myRel) && isfield(myRel, "Results")
        res = myRel.Results;
    else
        res = myRel.Results;
    end
    res_norm = normalize_container_for_scan(res);
    res_fields = get_container_fieldnames(res_norm);
    res_top = strjoin(res_fields(:).', ",");
catch
    res_top = "";
end

if strlength(string(rel_top)) > 0 || strlength(string(res_top)) > 0
    txt = " | UQLab debug: myRel fields=[" + string(rel_top) + "], Results fields=[" + string(res_top) + "]";
end
end



