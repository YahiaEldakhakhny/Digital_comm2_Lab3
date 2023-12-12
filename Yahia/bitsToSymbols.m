function symbols = bitsToSymbols(Bits, k)
    N = length(Bits);
    symbolBits = zeros(N/k, k);
    % Reshape
    for si = 1:N/k
        b = k*si + 1 - k;
        symbolBits(si, :) = Bits(b:b+k-1);
    end
    symbols = bin2dec(num2str(symbolBits)) + 1;
    
end

% b=1 => si = 1
% b= 4 => si = 2