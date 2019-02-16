clear all
close all
clc

counting = @counting_ones;
x = ones(1,3)
[f] = counting(x);
disp(f)