function s = format_u_row(u)
if isempty(u)
    s = '[]';
    return;
end
if iscell(u)
    try
        u = cell2mat(u);
    catch
        s = '[invalid]';
        return;
    end
end
u = double(reshape(u, 1, []));
if isempty(u)
    s = '[]';
    return;
end
s_body = sprintf('%.4f, ', u);
if numel(s_body) >= 2
    s_body = s_body(1:end - 2);
end
s = ['[', s_body, ']'];
end


