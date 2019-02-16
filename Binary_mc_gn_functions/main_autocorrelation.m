clear all
close all
clc

auto = @autorrelation;
x = [1,-1,1,-1,-1,1,1,-1]
[f] = auto(x);
disp(f)