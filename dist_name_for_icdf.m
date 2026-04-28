function dname = dist_name_for_icdf(dist_name)
switch lower(dist_name)
    case {"unif", "uniform"}
        dname = "Uniform";
    case {"wbl", "weibull"}
        dname = "Weibull";
    case {"logn", "lognormal"}
        dname = "Lognormal";
    case {"exp", "exponential"}
        dname = "Exponential";
    case {"rayl", "rayleigh"}
        dname = "Rayleigh";
    case {"gam", "gamma"}
        dname = "Gamma";
    case {"ev", "extreme value"}
        dname = "Extreme Value";
    otherwise
        dname = dist_name;
end
end


