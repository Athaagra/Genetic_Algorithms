function [powerloss individual] = s2158124_s2029413_ga(maxEvaluations)
  addpath('matpower4.1')
  file = load('para119.mat');
  
  #Upperbound array
  global ubArray;
  ubArray = file.para.ub;
  
  #Calculation_119 usage counter
  global evaluationsCounter;

  #Chance for each element in a individual to mutate
  #Between 0 and 100
  mutationRate = 25;

  #Number of parents to use each generation
  numParents = 10;

  #Evolutionarie algorithm
  evaluationsCounter = 0;
  [powerloss individual] = geneticAlgorithm(mutationRate,numParents,maxEvaluations);
endfunction

function [min_powerloss min_individual] = geneticAlgorithm(mutationrate,numParents,maxEvaluations)
  global evaluationsCounter;
  parents = [];
  powerParents = [];
  scores = [];
  
  #Create initial parents at random
  for numParent = 1:numParents
    parents = [parents,randomSolution()];
    individual = parents(:,numParent);
    
    evaluationsCounter = evaluationsCounter + 1;
    powerloss = calculation_119(individual);
    powerParents(numParent) = powerloss;
  endfor
  
  #Run algorithm with initialed parents
  while evaluationsCounter < maxEvaluations    
    #Creates mating combination where each parent mates with all other parents
    mates = selectMates(parents);
    
    #Crossover of each combination creating one offspring
    childeren = uniformCrossover(mates);
    
    #Mutates each offspring with mutationrate chance of mutating
    childeren = mutation(childeren,mutationrate);
    
    #Checks if offspring is feasible
    childeren = feasible(childeren);
    
    #Combines parents and childeren to create population
    population = horzcat(parents,childeren);
    
    #Select best individuals 
    [parents powerParents] = select(parents,childeren,numParents,powerParents);
  endwhile
  #Select best end individual
  bestIndividual = best(parents);
  
  min_individual = bestIndividual;
  min_powerloss = calculation_119(bestIndividual);  
endfunction

function selectMates = selectMates(parents)
  numParents = size(parents)(2);
  mates = [];
  
  #Creates combination of each parent with each other parent
  for i = 1:numParents
    for j = i+1:numParents
      mates(:,1,i,j) = parents(:,i);
      mates(:,2,i,j) = parents(:,j);
    endfor
  endfor

  selectMates = mates;
endfunction

function uniformCrossover = uniformCrossover(mates)
  matesSize = size(mates);
  invSize = matesSize(1);
  numParents = matesSize(4);
  
  #number of offspring is numParents - 1 and itterative summed
  # example: 5 - 1 = 4, summed is 4 + 3 + 2 + 1 = 10 offspring
  allOfspring = [];
  counter = 0;
  
  #For each combination
  for i = 1:numParents
    for j = i+1:numParents
      counter = counter + 1;
      mateA = mates(:,1,i,j);
      mateB = mates(:,2,i,j);
      offspring = [];
      
      #Loop through parents
      for k = 1:invSize
        
        #50% chance choosing parentA(k) and 50% choosing parentB(k) for offspring(k)
        crossoverChance = randi(100);
        if(crossoverChance <= 50)
          offspring(k) = mateA(k);
        else
          offspring(k) = mateB(k);
        endif
      endfor
      allOfspring(:,counter) = offspring;
    endfor
  endfor
  
  uniformCrossover = allOfspring;
endfunction

function mutation = mutation(indivinduals,mutationRate)
  global ubArray;
  matrixSizeIndiv = size(indivinduals);
  numIndiv = matrixSizeIndiv(2);
  sizeIndiv = matrixSizeIndiv(1);
  
  #For each indivindual
  for i = 1:numIndiv
    
      #Loop through genome
      for j = 1:sizeIndiv
      mutationChance = randi(100);
      
      #If random number is lower than mutationRate, mutate indivindual(j) to random number between 1 and 20
      if(mutationChance <= mutationRate)
        ub = ubArray(j);
        indivinduals(j,i) = randi(ub); 
      endif 
    endfor
  endfor
  
  mutation = indivinduals;
endfunction

function feasible = feasible(individuals)
  numIndividuals = size(individuals)(2);
  feasibleIndivinduals = [];
  counter = 0;
  
  #For each individual
  for i = 1:numIndividuals
    
    #If valid keep add to returning array otherwise don't (which removes the individual from gene pool)
    isValid = valid_119(individuals(:,i));  
    if isValid
      counter = counter + 1;
      feasibleIndivinduals(:,counter) = individuals(:,i);
    endif
  endfor
  
  feasible = feasibleIndivinduals; 
endfunction

function [newParents powerNewParents] = select(parents,childeren,k,parentsPower)
  global evaluationsCounter;
  topK = containers.Map('KeyType','double','ValueType','any');
  numIndiv = size(childeren)(2) + k;
  
  #Best k individuals
  resultK = [];
  powerK = [];
  
  #filler of map, doesn't influence result
  for i = 1:k
    topK(-i) = parents(i);
  endfor
  
  #For each individual
  for i = 1:numIndiv
    
    #Uses old calculation_119 values to reduce calculation_119 usage
    if i <= k
      individual = parents(:,i);
      indivPowerloss = parentsPower(i);
    else
      individual = childeren(:,i-k);
      evaluationsCounter = evaluationsCounter +1;
      indivPowerloss = calculation_119(individual);
    endif    

    added = false;
    keyset = cell2mat(keys(topK));
    
    #If already in map go to next individual
    if ismember(indivPowerloss,keyset)
      break
    endif
    
    #Check for filler topK entrys and replace
    for j = 1:k
      key = keyset(j);
      if key < 0
        remove(topK,key);
        topK(indivPowerloss) = individual;
        added = true;
        break
      endif    
    endfor 
    
    #Check for worse topK from highest powerloss to smallest powerloss and replace if current individual is lower
    if ~added
      keyset = sort(keyset,'descend');
      for j = 1:k
        
        #key is powerloss
        key = keyset(j);
        deltaP_loss = key - indivPowerloss;
        
        #If current indiv is better than map(key)
        if indivPowerloss < key
          remove(topK,key);
          topK(indivPowerloss) = individual;
          break
        endif
      endfor
    endif
  endfor
  
  keyset = cell2mat(keys(topK));
  
  #Map to array
  for i = 1:k
    individual = topK(keyset(i));
    powerK = [powerK,keyset(i)];
    resultK = [resultK,individual];
  endfor
  
  newParents = resultK;
  powerNewParents = powerK;
endfunction

function best = best(individuals)
  global evaluationsCounter;
  
  lowest = inf;
  lowIndiv = [];
  numIndiv = size(individuals)(2);
  
  for i = 1:numIndiv
    individual = individuals(:,i);
    evaluationsCounter = evaluationsCounter + 1;
    p_loss = calculation_119(individual);
    if p_loss < lowest
      lowest = p_loss;
      lowIndiv = individual;
    endif
  endfor
  best = lowIndiv;
endfunction

function RS = randomSolution(ub)
  global ubArray;
  flag = 0;
  
  while flag==0
    individual = [];  
    for i = 1:15
      ub = ubArray(i);
      individual = [individual;randi([1,ub])];
    endfor
    flag = valid_119(individual);
  endwhile
  RS =  individual;
endfunction


