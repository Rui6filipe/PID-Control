function arxstr = arxmodel(arxstr_old,dctr,time)
% arx(3,1,1)
% y(k) = -a1*y(k-1) -a2*y(k-2) -a3*y(k-3) +b1*u(k-1) 

arxstr = arxstr_old;

% load data-hw123vum-real.mat;
% yudata = iddata(sensor.y,dctr.u);
% arxm311 = arx(yudata,'NA',3,'NB',1,'NK',1)

% M = dlmread('TesteArduino0.5.log.txt');
% yudata = iddata(M(:, 3)/1023,M(:, 5)/255);
% arxm311 = arx(yudata,'NA',3,'NB',1,'NK',1)

% M = dlmread('anel_aberto_teste2.log.txt');
% yudata = iddata(M(:, 3)/1023,M(:, 5)/255);
% arxm311 = arx(yudata,'NA',3,'NB',1,'NK',1)

%Teachers
% A(q) = 1 - 1.464 q^-1 + 0.282 q^-2 + 0.2244 q^-3                                                                                     
% B(q) = 0.04335 q^-1 

%Ours
%A(z) = 1 - 1.58 z^-1 + 0.4938 z^-2 + 0.1318 z^-3                                                 
%B(z) = 0.04613 z^-1    

%For arduino
% A(q) = 1 - 1.307 q^-1 - 0.1434 q^-2 + 0.4817 q^-3                                                                                     
% B(q) = 0.03356 q^-1

% a1 = -1.464; a2 = 0.282; a3 = 0.2244; b1 = 0.04335; % static_gain = b1 / (1+a1+a2+a3)
% a1 = -1.58; a2 = 0.4938; a3 = 0.1318; b1 = 0.04613;
a1 = -1.307; a2 = -0.1434; a3 = 0.4817; b1 = 0.03356;

if (time.k > 3)
    arxstr.y(time.k) = -a1 * arxstr.y(time.k-1) -a2 * arxstr.y(time.k-2) + -a3 * arxstr.y(time.k-3) + b1 * dctr.u(time.k-1)  + bpwnoise(1e-7);
end
