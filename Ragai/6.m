% This code is used to simulate symbol mapping (low pass equivalent of modulation schemes)
% The modulation schemes tested are MASK, MPSK, and square MQAM

%% Initialization
clc;
clear all;
close all;

%% Simulation Parameters
EbNo_range=[0:2:30];                            %Eb/No range of simulation dB
NumberFramesPerSNR=1e3;                         %Number of frames sent for every SNR value
ModulationOrder=16;
NumberBitsPerFrame=1e3*log2(ModulationOrder);   %Number of bits sent for every frame
ModulationType=1;                               %Modulation type 1:MASK, 2:MPSK, 3:MQAM


%% BER Loop
BER=[];


for EbNo=EbNo_range
    %Print Eb/No value every iteration
    EbNo
    % Calculating average energy per bit of the modulation scheme
    % In the sequel, we assume Ac^2 Ts/2=1
    % I.e., the constellation diagram contains {..., -5, -3, -1, 1, 3, 5, ...}
    if ModulationType==1
        Eb=(ModulationOrder^2-1)/(3*log2(ModulationOrder));
    elseif ModulationType==2
        Eb=1/log2(ModulationOrder);
    elseif ModulationType==3
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
        SymbolBits=reshape(Bits,log2(ModulationOrder),NumberBitsPerFrame/log2(ModulationOrder))';
        
        
        
        % The square MQAM modulator/demodulator can be implemented as two orthogonal
        % sqrt(M)-ASK modulator/demodulator (we use this idea here)
        
        %% Transmitter Branch 1
        % Taking first log2(M)/2 bits to branch 1
        SymbolBits_branch1=SymbolBits(:,[1:log2(ModulationOrder)]);
        % Transforming bits into intgers: bianry to decimal conversion
        SymbolIndex_branch1=binaryVectorToDecimal(SymbolBits_branch1)+1;
        
        % Symbol modulation using ASK modulation
        OutputModulator_branch1=2*(SymbolIndex_branch1)-1-(ModulationOrder);
        
        
        %% Transmitted Signal
        % The transmitted signal takes the in-phase component from branch 1
        % as real component and the quadrature component from branch 2 as
        % imaginary component
        TransmittedSignal=OutputModulator_branch1;
        
        
        %% Adding Noise to the Transmitted Signal
        % Generating Noise signal with the correct variance corresponding
        % to Eb/No
        Noise=sqrt(No/2)*(randn(length(TransmittedSignal),1)+1i*randn(length(TransmittedSignal),1));
        
        % Adding noise
        ReceivedSignal=TransmittedSignal+Noise;
        
        %% Receiver Operation: Receiver Branch 1
        % In-phase component is the real part of the signal
        ReceivedSignal_branch1=real(ReceivedSignal);
        
        % Receiver operation is threshold operation
        % Threshold is {..., -4, -2, 0, 2, 4, ...}
        for threshold=-ModulationOrder+2:2:(ModulationOrder)-4
            DetectedSymbols_branch1((ReceivedSignal_branch1>threshold) &(ReceivedSignal_branch1<=threshold+2))=threshold+1;
        end
        
        % Detecting edge symbols
        DetectedSymbols_branch1(ReceivedSignal_branch1>(ModulationOrder)-2)=(ModulationOrder)-1;
        DetectedSymbols_branch1(ReceivedSignal_branch1<=-(ModulationOrder)+2)=-(ModulationOrder)+1;
        
        % Transform detected symbols into symbol index
        ReceivedSymbolIndex_branch1=(DetectedSymbols_branch1+(ModulationOrder)-1)/2;
   
        % Transform detected symbols into bits: decimal to binary
        DetectedBits_branch1=dec2bin(ReceivedSymbolIndex_branch1',log2(ModulationOrder));
        
        %% Parallel to Serial Operation in Receiver
        ReceivedBits=[DetectedBits_branch1];
        
        % Serializing output
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