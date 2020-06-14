function [rxMsgSyms, rxTrnSyms, rxNzeSyms] = ...
    commsRXSync(rxSyms, trnSyms, modPktSize, params)
% UNTITLED Summary of this function goes here
%   Detailed explanation goes here

   % Upsample training sequence
    trnSyms = upsample(trnSyms, params.upsampFactor);
       
    % 
    [rxMsgSyms, rxTrnSyms, rxNzeSyms] = timePhaseSynchronization(...
        rxSyms, trnSyms, params.nNzeSyms, modPktSize);

end

function [msgSyms, trnSyms, nzeSyms] = timePhaseSynchronization(...
    in_syms, trn_syms, nNzeSyms, modPktSize)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    nTrnSyms = length(trn_syms);

    % Correlate input symbols and training symbols
    [xcorrsyms, lags] = xcorr(in_syms, trn_syms);
    
    % Estimate time offset
    [maxlagidx, foundPeak] = peakEstimation(abs(xcorrsyms), [], []);
    disp(maxlagidx);
    %if (maxlagidx>61000)
     %   error('SNR is too low? Lots of interference? \n');
    %end
    if (foundPeak) % Changed to debug should be only foundPeak
    
        % Time offset estimate
        
        toffset = lags(maxlagidx);
        %disp(in_syms);
        %disp(toffset); % Added for debugging
        %disp(modPktSize); % Added for debugging
        %disp(nTrnSyms); % Added for debugging
        % 
        msgSyms = in_syms(toffset + nTrnSyms + (1:modPktSize));
        trnSyms = in_syms(toffset + (1:nTrnSyms));
%         nzeSyms = in_syms(toffset - (1:nNzeSyms));
        nzeSyms = in_syms(1:toffset);
        
        % Estimated phase offset
        phaseofst = angle(xcorrsyms(maxlagidx));
        
        % Apply estimated phase offset and time correction to input symbols
        msgSyms = exp(-1j*phaseofst)*msgSyms;
        
    else
        
        error('Unable to acquire signal. No waveform detected or Pfa value set too small.');
        
    end
          
end