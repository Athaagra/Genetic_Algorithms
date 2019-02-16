function [powerloss individual] = s2158124_s2029413_mc(eval_budget)
  addpath('matpower4.1')
  file = load('para119.mat');
  global ubArray;
  ubArray = file.para.ub;
  
  [powerloss individual] = mcmain(eval_budget);
endfunction

function [minp_powerloss minp_individual] = mcmain(eval_budget)    
  allPowerloss = [];
  individuals = [];
  scores = [];
  minp_powerloss = inf;
  
  #For each budget create one feasible solution
  parfor i=1:eval_budget
    individual = randomSolution();
    powerloss = calculation_119(individual); 
    allPowerloss = [allPowerloss,powerloss];
    individuals = [individuals,individual];
  endparfor
 #Retrieve lowest score and individual
 minp_powerloss = min(allPowerloss);
 minp_individual = individuals(:,find(allPowerloss==minp_powerloss));
endfunction

#Creates random feasible solution using upperbound
function RS = randomSolution()
  global ubArray;
  flag = 0;
  
  while flag==0
  individual = [];  
    parfor i = 1:15
      ub = ubArray(i);
      individual = [individual;randi(ub)];
    endparfor
    flag = valid_119(individual);
  endwhile
  RS = individual;
endfunction
