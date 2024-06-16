function [y] = bpsatur(v,umin,umax,flg)


delta = 0.5/100 * umax;
if (flg == 'sat')
	if (v > umax), y = umax; elseif (v < umin), y = umin; else y = v; end;
    % or, min(max(actuator.umin,adp.u(time.k)),actuator.umax);
elseif (flg == 'rnd')
	if (v > (umax-delta)), y = umax - delta + bpwnoise(1e-5);
        y = bpsatur(y,umin,umax,'sat');
	elseif (v < umin+delta), y = umin + delta + bpwnoise(1e-5);
        y = bpsatur(y,umin,umax,'sat');
	else y = v;
	end
else
    bpdebug('bpsatur->error:',0,0.1,1); pause;
end
% eof
