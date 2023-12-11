M = 4;          % ModulationOrder
k = log2(M);
num_bits = 16;
bits = randi([0 1],1,num_bits);     % Bits
symb_bits = reshape(bits,k,16/k)'; % SymbolBits
r = size(symb_bits); r = r(1);
m = zeros(1, r); %SymbolIndex

for i = 1:r
    curr_bit_str = '';
    for j = 1:k
        curr_bit_str = strcat(curr_bit_str, num2str(symb_bits(i, j)));
    end
    m(i) = bin2dec(curr_bit_str);
end
m = m +1;

%transmitter
xl = cos(2*pi*(m-1)/M) + 1i* sin(2*pi*(m-1)/M);

% reciever
r_p = angle(xl);
r_p(r_p < 0) = r_p(r_p < 0) + 2*pi;
% p = 0:pi/M:2*pi;
% p_th = p(2:2:end-1);
m_r = M.*r_p./(2*pi) + 1;

