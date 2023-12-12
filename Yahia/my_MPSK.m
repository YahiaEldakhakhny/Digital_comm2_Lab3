function BER = my_MPSK(M)
    EbNo_range=[0:2:30];
    k = log2(M);
    BitsNumber=1e4*k;
    BER = zeros(1, length(EbNo_range));
    % Get phase thresholds
    p = 0:pi/M:2*pi;
    phaseThresholds = p(2:2:end);
    
    %% Transmitter
    % generate bits
    Bits=randi([0 1],1,BitsNumber);
    % bits to symbol index
    symbolIndex = bitsToSymbols(Bits, k)';
    % Transmitted low pass signal
    SignalTx = cos(2*pi*(symbolIndex-1)/M) + 1i* sin(2*pi*(symbolIndex-1)/M);
    
    for i=1:length(EbNo_range)
        %% Adding Noise to the Transmitted Signal
        % Get noise power
        EbNo = EbNo_range(i);
        Eb = 1/k;
        EbNo_linear=10^(EbNo/10);
        No=Eb/EbNo_linear;
        % Generate noise
        Noise=sqrt(No/2)*(randn(1, length(SignalTx))+1i*randn(1, length(SignalTx)));
        % Add noise to signal
        SignalRx = SignalTx + Noise;
        %% Receiver
        % Get phase of reciever signal
        phaseRx= angle(SignalRx);
        % Adjust phase to be positive (add 2pi to negative phases)
        phaseRx(phaseRx < 0) = phaseRx(phaseRx < 0) + 2*pi;
        
        
        
        % Get detected phases (compare recieved phases with thresholds)
        for t = 1:length(phaseThresholds)-1
            threshold = phaseThresholds(t);
            nextThreshold = phaseThresholds(t+1);
            phaseRx((phaseRx>threshold) &(phaseRx<=nextThreshold))=(threshold+nextThreshold)/2;
        end
        % Outer thresholds
        phaseRx((phaseRx >= phaseThresholds(end)) | (phaseRx < phaseThresholds(1))) = 0;
        
        % Get recieved symbols
        SymbolIndexRx = round((M.* phaseRx./(2*pi)) +1);
        % Turn symbol indices into bits
        BitsRx = symbolIndexToBits(SymbolIndexRx, k);
        
        % Calculate BER
        BER(i) = sum(abs(Bits - BitsRx))/BitsNumber;
        
        %% Plotting Constellation Diagram of Received Signal
        figure
        plot(SignalRx,'+')
        title(['Constellation Diagram for Eb/No=' num2str(EbNo)])
        
% 
%         if sum(BER(i))==0 && supress == 0
%             break
%         end
    end
    semilogy(EbNo_range(BER ~= 0),BER(BER ~= 0),'linewidth',2,'marker','o');
    xlabel('Eb/No (dB)')
    ylabel('BER')
    hold on
    grid on
    


end