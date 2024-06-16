function pid = bppidbasic(flg,xxpid,plant,time)

pid = xxpid;

if (flg == 'init')
    % pid.Kp = 1.674; pid.Ti = 10000; pid.Tt = pid.Ti; pid.Td = 0.32;
    pid.Kp = 3.57; pid.Ti = 1.97; pid.Tt = pid.Ti; pid.Td = 1.19;
    pid.bi = pid.Kp * time.Ts / pid.Ti;
    pid.u = zeros(time.kmax,1);
    pid.r = zeros(time.kmax,1);
    pid.y = zeros(time.kmax,1);
    pid.v = zeros(time.kmax,1); % tmp
    pid.ao = time.Ts / pid.Tt;
    pid.bd = pid.Td / time.Ts;
    pid.P = zeros(time.kmax,1);
    pid.I = zeros(time.kmax,1);
    pid.D = zeros(time.kmax,1);
    pid.error = zeros(time.kmax,1);

elseif (flg == 'xrun')
    if (time.k > 1)
        % pid.r, pid.y ...
        pid.error(time.k) = pid.r(time.k) - pid.y(time.k);
        pid.P(time.k) = pid.Kp * pid.error(time.k);
        pid.D(time.k) = pid.bd * (pid.error(time.k) - pid.error(time.k-1));
        pid.v(time.k) = pid.P(time.k) + pid.I(time.k-1) + pid.D(time.k);
        pid.u(time.k) = bpsatur(pid.v(time.k),0,1,'sat');
        pid.I(time.k) = pid.I(time.k-1) + pid.bi * pid.error(time.k) + ...
            pid.ao * (pid.u(time.k) - pid.v(time.k));
    end
end
