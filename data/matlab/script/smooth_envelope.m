function [ env ] = smooth_envelope( gram, span )
%smooth_envelope provides a smoothed envelope of the input seismogram
%   Uses the hilbert transform h and computes sqrt( gram^2 + h^2)
% smooths useing a aquare convolution of span points
envl= sqrt(imag(hilbert(gram)).^2 + gram.^2);
window = ones(span,1)/span;
env=convn(envl,window,'same');