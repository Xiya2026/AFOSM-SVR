function y = predict_svr_model(model, xq)
if isvector(xq)
    xq = reshape(xq, 1, []);
end

backend = "matlab";
raw_model = model;
if isstruct(model) && isfield(model, "backend") && isfield(model, "raw_model")
    backend = lower(string(model.backend));
    raw_model = model.raw_model;
end

switch backend
    case "uqlab"
        y = uq_evalModel(raw_model, xq);
    otherwise
        y = predict(raw_model, xq);
end
y = reshape(y, size(xq, 1), 1);
end


