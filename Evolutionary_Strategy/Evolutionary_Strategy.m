function [xopt,fopt]  = s2158124_s2029413_es(fitnessfct,N,lb,ub,eval_budget)
  global generation;
  pkg load statistics;
  
  numPar = 10;
  Pm = [0.001,0.005,0.01,0.05,0.1,0.2];
  PmString = strsplit(num2str(Pm));
  
  [solution] = EvolutionStrategy(fitnessfct,numPar,N,lb,ub,eval_budget,Pm(2));

  xopt = solution.genome;
  fopt = solution.fitness;

end 

function [lowest]= EvolutionStrategy(fitnessfct,numPar,N,lb,ub,eval_budget,Pm)
  global eval_budget_used;
  global generation;
  eval_budget_used = 0;
    
  generation = 0;
  numOff = 2*numPar;
  lowest.fitness = inf;
  
  %Change initialization from mutliple D to single D with multiple values
  [parents] = createIndividuals(numPar,N,lb,ub);
  parFitness = fitnessForMatrix(parents,fitnessfct);

  indiv_step_sizes = (rand(numOff,N)*200-100)*Pm;
  %% Main loop
  while(eval_budget > eval_budget_used)
    generation = generation + 1;
   
    %Partner Creation
    partners = PartnerCreation(parents,numOff);
   
    %Crossover
    offspring = Crossover(partners);
    
    %Mutation
    mutatedOffspring = mutation(offspring,indiv_step_sizes,ub,lb);

    %Selection
    parents = selection(mutatedOffspring,fitnessfct,numPar);

    %Check for best solution
    for i = 1:size(parents)(1)
      if parents(i).fitness < lowest.fitness
        lowest = parents(i);
      end
    end
  end
end

function [individuals] = createIndividuals(amount,N,lb,ub)
  individuals = [];
  for i = 1:amount
    individual.genome = rand(1,N).*(ub-lb) + lb;
    individuals = [individuals;individual];
  endfor
endfunction

function [fitness] = fitnessForMatrix(population,fitnessfct)
  global eval_budget_used;
  fitness = [];
  n = size(population)(1);
 
  for i = 1 : n
    eval_budget_used = eval_budget_used + 1;
    individual = population(i);
    fitness = [fitness;fitnessfct(individual.genome)];
  end
end

function [partners] = PartnerCreation(parents,offspringSize)
  partners = [];
  parentSize = size(parents)(1);
  
  for offspringI = 1:offspringSize
    i = mod(offspringI,parentSize)+1;
    parent1 = parents(i,:);
    
    randomParentNumber = randi(parentSize);
    while(randomParentNumber == i)
      randomParentNumber = randi(parentSize);
    end
    parent2 = parents(randomParentNumber,:);
    
    partners = [partners;parent1;parent2];
  end
end
  
function [offspring] = Crossover(partners)
  offspring = [];
  partnersN = size(partners)(1)/2;
  
  for i = 1:partnersN
    partnerSetIndex = 2*i;
    parent1 = partners(partnerSetIndex-1,:);
    parent2 = partners(partnerSetIndex,:);
    
    child.genome = uniformCrossover(parent1,parent2);
    child.fitness = -1;
    
    offspring = [offspring;child];
  end
end
  
function [offspring] = uniformCrossover(parent1,parent2)
  n = length(parent1.genome);
  offspring = [];
  
  for geneI = 1:n
    chance = rand();
    if chance <= 0.5
      offspring = [offspring,parent1.genome(geneI)];
    elseif (chance > 0.5) && (chance <= 1)
      offspring = [offspring,parent2.genome(geneI)];
    else
      error("uniform crossover error")
    end
  end
end  
      
function [offspring] = mutation(offspring, indiv_step_sizes,ub,lb)
  indiv_step_sizes = changeStepSize(indiv_step_sizes,ub,lb);
  
  offspringSize = size(offspring)(1);
  for i = 1:offspringSize
    step_size = indiv_step_sizes(i,:);
    steps = size(step_size)(2);
    curGenome = offspring(i).genome;
    
    for j = 1:steps
      step = abs(step_size(j));
      curGenome(j) = curGenome(j) + normrnd(0,step);
    end
    offspring(i).genome = curGenome;
  end
end

function [indiv_step_sizes] = changeStepSize(indiv_step_sizes,ub,lb)
  n = size(indiv_step_sizes)(1);
  TauGlobal = 1/sqrt(2*n);
  TauLocal = 1/sqrt(2*sqrt(n));
  
  MutationGlobal = normrnd(0,1) * TauGlobal;
  for step_sizeI = 1:n
    MutationLocal = normrnd(0,1) * TauLocal;
    step_size = indiv_step_sizes(step_sizeI,:);
    for stepI = 1:size(step_size)(2);
      step = step_size(stepI);
      newStep = step * exp(MutationGlobal + TauLocal);
      
      if newStep > ub(stepI);
        newStep = ub(stepI);
      elseif newStep < lb;
        newStep = lb(stepI);
      end
      
      step_size(stepI) = newStep;
    end
    indiv_step_sizes(step_sizeI,:) = step_size;
  end  
end

function [nextGen] = selection(population,fitnessfct,maxPopulation)
  global eval_budget_used;
  n = size(population)(1);
  nextGen = [];
  
  if(maxPopulation > n)
    error("Selection error: Can't ask for more nextGen than given population")
  end
  
  for i = 1:n
    eval_budget_used = eval_budget_used + 1;
    individual = population(i,:);
    individual.fitness = fitnessfct(individual.genome);
    nextGen = [nextGen;individual];
  end

  while(size(nextGen)(1) ~= maxPopulation)
    contestent1 = nextGen(1);
    contestent2 = nextGen(2);
    
    fit1 = contestent1.fitness;
    fit2 = contestent2.fitness;
    
    if ge(fit1,fit2)
      winner = contestent2;
    elseif gt(fit2,fit1)
      winner = contestent1;
    end  
    
    nextGen = [nextGen(3:end);winner];
  end  
end