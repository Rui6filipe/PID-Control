function xdaq = usbdaq(xdev,flg,zdaq)
% usbdaq.m; DAQ acquisition from USB devices based on DAQ toolbox

xdaq = zdaq;

if (flg == 'init'),
    % signal to #2 actuators;
    xdaq.num.a = 2; xdaq.u = zeros(1,xdaq.num.a);
    % signals from #4 sensors
    xdaq.num.s = 4; xdaq.y = zeros(1,xdaq.num.s);

    % xdaq.idxxx = 'PMD-1208LS'; % 'PMD-1208LS; winsound'
	  xdaq.idxxx = 'NI-USB6009'; % 'NI-USB6008'
    % 1-step, initialization
    if (xdaq.idxxx == 'PMD-1208LS'),
        % xdaq.default.channel = 0;
        daqhwinfo('mcc'), xdaq.id = 'mcc';
        for k=1:xdaq.num.s
            xdaq.ai(k) = analoginput(xdaq.id,0); %
            addchannel(xdaq.ai(k),k-1);
            set(xdaq.ai(k), 'InputType', 'SingleEnded');
        end
        for k=1:xdaq.num.a
            xdaq.ao(k) = analogoutput(xdaq.id,0);
            addchannel(xdaq.ao(k),k-1);
        end
        % xdaq.ai = analoginput(xdaq.id,0); % create AI object; 0: for DAQ board; 1: for demo-board (signal generator)
        % xdaq.ao = analogoutput(xdaq.id,0); % create AO object
	elseif (xdaq.idxxx == 'NI-USB6008') | (xdaq.idxxx == 'NI-USB6009')
        % xdaq.default.channel = 0;   % PC portatil HP da SDC; porta usb de baixo (verif. com soft. NI_measurement)
        daqhwinfo('nidaq'), xdaq.id = 'nidaq';
        for k=1:xdaq.num.s
            xdaq.ai(k) = analoginput(xdaq.id,xdev); % ### Setup em software NI ... 'Dev-6009'
            addchannel(xdaq.ai(k),k-1);
            set(xdaq.ai(k), 'InputType', 'SingleEnded');
        end
        for k=1:xdaq.num.a
            xdaq.ao(k) = analogoutput(xdaq.id,xdev); % xdev = 'Dev1' for fbk38600
            addchannel(xdaq.ao(k),k-1);
        end
	end;
    % set(xdaq.ai,'SampleRate',time.Fs); % mcc; Fs > 100; only for a data buffer
    % set(bptxdaq.ai,'SamplesPerTrigger',time.tmax*time.Fs);
% read
elseif (flg == 'read'),
    % start(bptxdaq.ai); ?? only for data buffer
    for k=1:xdaq.num.s
        xdaq.y(1,k) = getsample(xdaq.ai(k));
    end
% write
elseif (flg == 'writ'),
    for k=1:xdaq.num.a
        putsample(xdaq.ao(k), xdaq.u(k));
    end
elseif (flg == 'down')
    disp('DAQ board: down to 0 volt ? ...');
    % delete(xdaq.ai) % delete AI object
    % delete(xdaq.ao) % delete AO object
end

% example to test usb-daq code
% run usb_txdaq
