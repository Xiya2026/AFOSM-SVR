function x_fixed = doc_to_fixed_wing_units(x_doc, cfg)
if isvector(x_doc)
    x_doc = reshape(x_doc, 1, []);
end
if size(x_doc, 2) ~= 7
    error("Input must have 7 columns.");
end

c0 = cfg.geometry.root_chord_mm;
kN2N = cfg.units.force_kN_to_N;

x_fixed = x_doc;
x_fixed(:, 5) = x_doc(:, 5) / 100 * c0; % d1: percent chord -> mm
x_fixed(:, 6) = x_doc(:, 6) / 100 * c0; % d2: percent chord -> mm
x_fixed(:, 7) = x_doc(:, 7) * kN2N;     % Fbar: kN -> N
end

