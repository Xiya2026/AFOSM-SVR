function uq_name = map_distname_to_uqlab(dist_name)
switch lower(string(dist_name))
    case {"norm", "normal", "gaussian"}
        uq_name = "Gaussian";
    case {"logn", "lognormal"}
        uq_name = "Lognormal";
    case {"wbl", "weibull"}
        uq_name = "Weibull";
    case {"unif", "uniform"}
        uq_name = "Uniform";
    case {"exp", "exponential"}
        uq_name = "Exponential";
    case {"rayl", "rayleigh"}
        uq_name = "Rayleigh";
    case {"gam", "gamma"}
        uq_name = "Gamma";
    case {"ev", "gumbel"}
        uq_name = "Gumbel";
    otherwise
        uq_name = char(dist_name);
end
uq_name = char(uq_name);
end


