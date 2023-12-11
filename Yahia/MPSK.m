% This code is used to simulate symbol mapping (low pass equivalent of modulation schemes)
% The modulation schemes tested are MASK, MPSK, and square MQAM
function MPSK(M)
    %% Initialization
    clc;
    clear all;
    close all;

    %% Simulation Parameters
    EbNo_range=[0:2:30];                             %Eb/No range of simulation dB
    NumberFramesPerSNR=1e3;                         %Number of frames sent for every SNR value
    ModulationOrder=M;                              %The number of sent waveforms (M)
    k = log2(ModulationOrder);
    NumberBitsPerFrame=1e3*k;                  %Number of bits sent for every frame
    ModulationType=2;                                 %Modulation type 1:MASK, 2:MPSK, 3:MQAM


    %% BER Loop
    BER=[];


    for EbNo=EbNo_range
        %Print Eb/No value every iteration
        EbNo
        % Calculating average energy per bit of the modulation scheme
        % In the sequel, we assume Ac^2 Ts/2=1
        % I.e., the constellation diagram contains {..., -5, -3, -1, 1, 3, 5, ...}
        if ModulationType==1    %MASK
            Eb=(ModulationOrder^2-1)/(3*log2(ModulationOrder));
        elseif ModulationType==2    %MPSK
            Eb=1/log2(ModulationOrder);
        elseif ModulationType==3    %MQAM
            Eb=2*(ModulationOrder-1)/(3*log2(ModulationOrder));
        end

        % Writing Eb/No in linear scale
        EbNo_linear=10^(EbNo/10);

        % Calculating Noise PSD (No) corresponding to Eb/No
        No=Eb/EbNo_linear;

        % Initializing sum of probability of error over frames to zero
        sum_prob_error=0;

        for frame=1:NumberFramesPerSNR

            % Print the frame index to track the code progression
            if mod(frame,100)==0
                frame
            end

            % Generating random bits each frame
            Bits=randi([0 1],1,NumberBitsPerFrame);

            % Obtaining Symbol bits
            SymbolBits=reshape(Bits,k,NumberBitsPerFrame/k)';


            % Simulating the square MQAM case only
            % Your task is to include the cases of MASK and MPSK similarly

            % The square MQAM modulator/demodulator can be implemented as two orthogonal
            % sqrt(M)-ASK modulator/demodulator (we use this idea here)

           %% Transmitter
           % r is the number of rows in SymbolBits (number of transmitted
           % symbols)
           r = size(SymbolBits); r = r(1);
           % allocate space for symbol index (m)
           SymbolIndex = zeros(1, r);
           
           % Calculate symbol corresponding to each k bits
           for i = 1:r
               curr_bit_str = '';
               for j = 1:k
                   curr_bit_str = strcat(curr_bit_str, num2str(SymbolBits(i, j)));
               end
               SymbolIndex(i) = bin2dec(curr_bit_str);
           end
           SymbolIndex = SymbolIndex +1;
           % Calculate transmitted signal
           TransmittedSignal = cos(2*pi*(SymbolIndex-1)/ModulationOrder) + 1i* sin(2*pi*(SymbolIndex-1)/ModulationOrder);
           
            %% Adding Noise to the Transmitted Signal
            % Generating Noise signal with the correct variance corresponding
            % to Eb/No
            Noise=sqrt(No/2)*(randn(length(TransmittedSignal),1)+1i*randn(length(TransmittedSignal),1));

            % Adding noise
            ReceivedSignal=TransmittedSignal+Noise;

            %% Receiver
            % Get phase of reciever signal
            phaseRec = angle(ReceivedSignal);
            % Adjust phase to be positive (add 2pi to negative phases)
            phaseRec(phaseRec < 0) = phaseRec(phaseRec < 0) + 2*pi;
            
            % Get phase thresholds
            p = 0:pi/ModulationOrder:2*pi;
            phaseThresholds = p(2:2:end);
            
            % Get detected phases (compare recieved phases with thresholds)
            for t = 1:length(phaseThresholds)-1
                threshold = phaseThresholds(t);
                nextThreshold = phaseThresholds(t+1);
                phaseRec((phaseRec>threshold) &(phaseRec<=nextThreshold))=(threshold+nextThreshold)/2;
            end
            % Outer thresholds
            phaseRec((phaseRec >= phaseThresholds(end)) | (phaseRec < phaseThresholds(1))) = 0;
            
            % Get recieved symbols
            ReceivedSymbolIndex = round((ModulationOrder .* phaseRec./(2*pi)) +1);
            
            % Get recieved bits
            ReceivedBits = dec2bin(ReceivedSymbolIndex, k);
            ReceivedBits=reshape(ReceivedBits',1,NumberBitsPerFrame);
            %% BER calculation
            prob_error_frame=sum(xor(Bits,double(ReceivedBits-48)))/NumberBitsPerFrame;
            sum_prob_error=sum_prob_error+prob_error_frame;

        end

        %% Plotting Constellation Diagram of Received Signal
        figure
        plot(ReceivedSignal,'+')
        title(['Constellation Diagram for Eb/No=' num2str(EbNo)])

        BER=[BER sum_prob_error/NumberFramesPerSNR]

        if sum(sum_prob_error)==0
            break
        end
    end
    %% Plotting BER vs EbNo
    semilogy(EbNo_range(1:length(BER)),BER,'linewidth',2,'marker','o');
    xlabel('Eb/No (dB)')
    ylabel('BER')
    hold on
    grid on
end