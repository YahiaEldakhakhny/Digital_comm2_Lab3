% Generate BER curves
EbNo_range=[0:2:30];
BER_4 = my_MPSK(4);
BER_8 = my_MPSK(8);
BER_16 = my_MPSK(16);

figure
semilogy(EbNo_range, BER_4, 'linewidth',2,'marker','o');
hold on
semilogy(EbNo_range, BER_8, 'linewidth',2,'marker','o');
hold on
semilogy(EbNo_range, BER_16, 'linewidth',2,'marker','o');
xlabel('Eb/No (dB)')
ylabel('BER')
grid on
legend('QPSK', '8PSK', '16PSK')