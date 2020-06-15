function success = usrpJRCSimpleRx(sys_start_time)
        
    addpath(genpath('../../lib'));

    %% 
    %   Initialize radio
    %
   
    % Load params file
    load('../paramsFiles/params06Jun2017.mat');
    
    if 0
        startTime = setStartTime();
    else
        startTime = sys_start_time;
    end
    
    [ usrpSettings, usrpRadio ] = initUSRPRadio(commsParams); 

    %%
    %   Constant variable declarations
    %

    buffSamps = usrpSettings.buff_samps;
    procTime  = usrpSettings.proc_time;
    nTxCycles = commsParams.nTxCycles;
    
    %%
    %   Vector declarations
    %
        
    % Mallocs for composite waveform
    rxWav = zeros(buffSamps, nTxCycles);
    
    for nn = 1:nTxCycles

        % Receive data from USRP
        rxBuff = usrpRadio.rx_usrp(startTime);

        % Convert to MATLAB format
        rxWav(:,nn) = rxBuff(1:2:end)+1j*rxBuff(1:2:end);

        % Increment start timer
        startTime = startTime+procTime;

    end

    dateStr  = datestr(now, 'mmddyyyy_HHMMSS');
    fileName = ['usrpJRCSimpleRx_', dateStr, '.mat'];    
    save(fullfile('~/Data', fileName), 'rxWav');

    % Stop server
    usrpRadio.terminate_usrp(); 
 
    success = true;

end

function [ usrpSettings, usrpRadio ] = initUSRPRadio(p)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
        
    usrpSettings.bw             = 5e6;          %bw
    usrpSettings.sample_rate    = p.sampFreq;         %rate
    usrpSettings.rx_gain        = 40;           %rx_gain
    usrpSettings.tx_gain        = 50;           %tx_gain
    usrpSettings.usrp_address   = 'type=b200';
    usrpSettings.type           = 'double';		%type
    usrpSettings.ant            = 'TX/RX';      %ant
    usrpSettings.subdev         = 'A:B';		%subdev
    usrpSettings.ref            = 'gpsdo';		%ref
    usrpSettings.wirefmt        = 'sc16';		%wirefmt
    usrpSettings.buff_samps     = 200e3;
    usrpSettings.freq           = 900e6;        %freq
    usrpSettings.setup_time     = 0.1;          %setup_time2
    usrpSettings.proc_time = 5;         % MATLAB processing time (seconds)
    
    usrpRadio = local_usrp;
    
    usrpRadio.set_usrp(...
        usrpSettings.type, usrpSettings.ant, usrpSettings.subdev, ...
        usrpSettings.ref, usrpSettings.wirefmt, usrpSettings.buff_samps,...
        usrpSettings.sample_rate, usrpSettings.freq, usrpSettings.rx_gain, ...
        usrpSettings.tx_gain, usrpSettings.bw, usrpSettings.setup_time);

end

function posixTime = setStartTime(dateTimeStr)

    if ~exist('dateTimeStr','var') || isempty(dateTimeStr)
        
        p = posixtime(datetime('now', 'Timezone', 'America/Phoenix'));
        posixTime = double(uint64(p)+5);       
        
    else
        
        p = posixtime(datetime(...
            dateTimeStr, 'InputFormat', 'yyy-MM-dd HH:mm:ss', ...
            'Timezone','America/Phoenix'));
        
        posixTime = double(uint64(p));
        
    end

end