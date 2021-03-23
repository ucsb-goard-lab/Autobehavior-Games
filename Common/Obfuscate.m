function out = Obfuscate(str, deobfuscate,decompFactor,offset)
if nargin<2
    deobfuscate = false;
end
if nargin<3
    decompFactor = 3;
end
if nargin<4
    offset = -37;
end
if ~deobfuscate
    native = unicode2native(str);
    n = decompFactor*numel(native);
    out = zeros(1,n);
    real = getReal(n);
    out(real) = native+offset;
    out(~real) = randi(200,1,numel(out(~real)));
    out = string(native2unicode(out));
else
    native = unicode2native(str);
    native = native(getReal(numel(native)));
    native = native - offset;
    out = string(native2unicode(native));
end
end
function logicalArray = getReal(n)
    logicalArray = false(1,n);
    for i = 1:n
        logicalArray(i) = mod(i,3)==1;
    end
    
end