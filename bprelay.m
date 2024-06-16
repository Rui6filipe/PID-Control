function [drc] = bprelay(xflg,drci,outp,plant,time)

drc = drci;

if (xflg == 'init')
    drc.y = zeros(time.kmax,1);
    drc.r = zeros(time.kmax,1);
    drc.u = zeros(time.kmax,1);
    drc.h = 0.05;
    drc.umax = 1;
    drc.umin = 0;

elseif (xflg == 'xrun')

    if (drc.y(time.k) < (drc.r(time.k) - drc.h))
      drc.u(time.k) = drc.umax;
    elseif (drc.y(time.k) > (drc.r(time.k) + drc.h))
      drc.u(time.k) = drc.umin;
    else
      drc.u(time.k) = drc.u(time.k-1);
    end

end
