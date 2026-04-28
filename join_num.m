function txt = join_num(v)
v = reshape(v, 1, []);
if isempty(v)
    txt = '';
    return;
end
txt = sprintf("%.6g, ", v);
txt = txt(1:end - 2);
end


