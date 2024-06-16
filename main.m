clc, clear all, close all, warning off

% time
time.k = 1; time.tmax = input('Tmax[s]: 180? '); %
time.Ts = 80 / 1000; % <= 80 ms
time.kmax = round(time.tmax / time.Ts);
time.elapsed = zeros(time.kmax,1);

% plant
plant.model.mode = 'pct9setup3tk';
plant.type = input('Plant("r-real,m-model"): ');

% sensor
sensor.n = 4;
sensor.yr = zeros(time.kmax,sensor.n);
sensor.y = zeros(time.kmax,1); sensor.y0 = sensor.y;
sensor.y1 = sensor.y;
sensor.ym = sensor.y; % model output
sensor.gain = 1/5; sensor.pole = 0.0;

% arxmodel
arxstr.y = zeros(time.kmax,1);

% actuator
actuator.ur = zeros(time.kmax,1);
actuator.gain = 1 * 5;

% digital controller
dctr.u0 = zeros(time.kmax,1);
dctr.u = zeros(time.kmax,1); % LP filtered
dctr.pole = 0; % 0.8;

% relay controller
dctr.relay.u = zeros(time.kmax,1);
dctr.relay.sp = zeros(time.kmax,1);
dctr.relay = bprelay('init',dctr.relay,0,plant,time);
dctr.ac = input('Controller(ma,re,pi): ');
dctr.sp.y = zeros(time.kmax,1); % > sensor.offset: 0.1113

% PI(D) controller
dctr.pid.id = 'dctr.pid.id';
dctr.pid = bppidbasic('init',dctr.pid,plant,time);

if (plant.type == 'r')
    xdaq.dev1.xpto = 1; xdaq.dev1 = usbdaq('Dev3','init',xdaq.dev1); % init DAQ; % USB daq struct
    xdaq.dev1.u = [0.0 0.0]; xdaq.dev1 = usbdaq('Dev3','writ',xdaq.dev1); % write an initial value
end



% main program
for k = 1:time.kmax
    tic; time.k = k;
    % read sensors
    if (plant.type == 'r')
        xdaq.dev1 = usbdaq('Dev3','read',xdaq.dev1); sensor.yr(time.k,:) = xdaq.dev1.y(:)';
        % sensor calibration
        sensor.y0(time.k) = sensor.gain * sensor.yr(time.k,1:1);
        sensor.y1(time.k) = 0 * sensor.gain * sensor.yr(time.k,2:2);
    else
        arxstr = arxmodel(arxstr,dctr,time);
        sensor.ym(time.k) = arxstr.y(time.k);
        sensor.y0(time.k) = sensor.ym(time.k);
    end
    sensor.y0(time.k) = bpsatur(sensor.y0(time.k),0,1,'sat');

    % LP filter ...
    if (time.k > 1),
        sensor.y(time.k) = sensor.pole * sensor.y(time.k-1) + (1 - sensor.pole) * sensor.y0(time.k);
    end;

    % additive output sensor fault
    if 0 & (time.k > (0.5 * time.kmax))
        sensor.fs.adit = 0.0; % -0.1, +0.1;
        sensor.y(time.k) = sensor.y0(time.k) + sensor.fs.adit;
    end

    % exp1: [0.1 0.3 0.2 0.4 0.1]
    % exp2: [0.1 0.4 0.2 0.1 0.3]
    if (time.k <= (1/5*time.kmax)), dctr.sp.y(time.k) = 20/100;
    elseif (time.k <= (2/5*time.kmax)), dctr.sp.y(time.k) = 50/100;
    elseif (time.k <= (3/5*time.kmax)), dctr.sp.y(time.k) = 30/100;
    elseif (time.k <= (4/5*time.kmax)), dctr.sp.y(time.k) = 80/100;
    else dctr.sp.y(time.k) = 10/100;
    end

    dctr.sp.y(time.k) = bpsatur(dctr.sp.y(time.k),0,1,'sat');
    dctr.relay.sp(time.k) = dctr.sp.y(time.k);

    % relay controller
    if (dctr.ac == 're')
        dctr.relay.r(time.k) = dctr.sp.y(time.k);
        dctr.relay.y(time.k) = sensor.y(time.k);
        dctr.relay = bprelay('xrun',dctr.relay,sensor.y(time.k),plant,time);
        dctr.u(time.k) = dctr.relay.u(time.k); % dctr.command; % Volt !!!
        dctr.u(time.k) = bpsatur(dctr.u(time.k),0,1,'sat');

    % classical PID controller
    elseif (dctr.ac == 'pi')
        dctr.pid.r(time.k) = dctr.sp.y(time.k);
        dctr.pid.y(time.k) = sensor.y(time.k);
        dctr.pid = bppidbasic('xrun',dctr.pid,plant,time);
        dctr.u(time.k) = dctr.pid.u(time.k);
        dctr.u(time.k) = bpsatur(dctr.u(time.k),0,1,'sat');

    % Manual Controller
    elseif (dctr.ac == 'ma')
        dctr.manc = bphumanctr('xrun',dctr.manc,plant,time);
        dctr.u(time.k) = dctr.manc.u(time.k);
        % dctr.u(time.k) = 0;
        dctr.u(time.k) = bpsatur(dctr.u(time.k),0,1,'sat');
    end



    % actuator
    if (plant.type == 'r')
        actuator.ur(time.k) = actuator.gain * dctr.u(time.k);
        xdaq.dev1.u = [actuator.ur(time.k) 0.0];
        xdaq.dev1 = usbdaq('Dev3','writ',xdaq.dev1);
        time.cpu = toc; pause(time.Ts-time.cpu);
    end

    if (time.k == 20) | (mod(time.k,round(0.05*time.kmax)) == 0)
        % [time.k / time.kmax]
        plot((1:time.k)*time.Ts,dctr.relay.sp(1:time.k),'r-.', ...
            (1:time.k)*time.Ts,dctr.u(1:time.k),'g', ...
            (1:time.k)*time.Ts,sensor.y(1:time.k),'b', ...
            (1:time.k)*time.Ts,0*sensor.y0(1:time.k),'m-.', ...
            (1:time.k)*time.Ts,0.5*sensor.y1(1:time.k),'m-.' ...
        );
        xlabel('Time[s]'); ylabel('r,y,y1,u'); title('Signals [r u y y1] = [R G B M]');
        pause(1/1000);
    end

end

if (plant.type == 'r')
    xdaq.dev1.u = [0.0 0.0]; xdaq.dev1 = usbdaq('Dev3','writ',xdaq.dev1); % write an initial value
end

% save data-hw123vum-sim.mat % PID Controller ...
save data-hw123vum-real.mat

% --- eof ---
