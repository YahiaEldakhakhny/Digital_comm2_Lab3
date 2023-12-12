function bits = symbolIndexToBits(symbolIndex, k)
    SIs = symbolIndex -1;
    symbIndeces = de2bi(SIs, k, 'left-msb');
    s = size(symbIndeces);
    N = s(1);
    bits = zeros(1, N * k);
    bits_count = 1;
    for i = 1:N
        for j = 1: k
            bits(bits_count) = symbIndeces(i, j);
            bits_count = bits_count +1;
        end
    end
    
    

end