function y = bpwnoise(wvar)
% function y = bpwnoise(wvar)
% returns a signal with variance "wvar"
% Gaussian (Normally) distributed random numbers;  
% xvar = 4.5; a=sqrt(xvar)*randn(1,10000); var(a)
% by LBP; rev 2004-June-18

noiseflg = 1;
y = noiseflg * sqrt(wvar) * randn(1,1);

% test code
% clear all; close all; pack
% for i=1:10000; xpto.wn(i) = bpwnoise(1e-4); end
% xpto.mean = mean(xpto.wn);
% xpto.std = std(xpto.wn);
% xpto.var = var(xpto.wn);
% whos
% xpto
% figure; plot(xpto.wn)

% ... eof ...