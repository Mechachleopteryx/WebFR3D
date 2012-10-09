% pMakeModelFromSearchSaveFile(Search) creates an SCFG/MRF Node variable corresponding to the model in Search

% pMakeModelFromSearchSaveFile('LIB00002 IL 2008-03-20_23_29_25-Sarcin_13_flanked_by_cWW_in_1s72')
% Search = 'LIB00002 IL 2008-03-20_23_29_25-Sarcin_13_flanked_by_cWW_in_1s72';

% load LIB00014_IL_tSH-tSH-tHS-tHS.mat
% pMakeModelFromSearchSaveFile(Search,'IL',1);

function [Node,Truncate,Signature] = pMakeMotifModelFromSSF(Search,Param,Prior)

if nargin < 2,
  Param   = 0;
  Verbose = 0;
else
  Verbose = Param(1);
end
if nargin <3,
  Prior = [10000 10000 10000 10000 0];    % Extremely strong prior, makes for flat letter distribution
end

while length(Prior) < 5,
  Prior = [Prior 0];
end
% ----------------------------------- Load Search from filename, if applicable

if strcmp(class(Search),'char'),
  load(['MotifLibrary' filesep Search],'Search','-mat');
end

% ----------------------------------- Gather basic information about the search

[L,N] = size(Search.Candidates);        % L = num instances; N = num NT
N = N - 1;                              % number of nucleotides

f = Search.Candidates(:,N+1);           % file numbers of motifs

File = Search.File(f(1));                      % file of query motif
NTNumber = double(Search.Candidates(1,1));     % index of first NT
LastNTNumber = double(Search.Candidates(1,N)); % index of last NT

% ----- Display interactions in the first instance

i = Search.Candidates(1,1:N);                   % indices of query motif

if Verbose > 0,
  fprintf('Interactions in the first instance:\n');
  zShowInteractionTable(File,full(i));
end

% ----- Identify where the flanking pair is, to split up the two strands
% --------------------------------------- Find locations of truncations

F.Edge = pConsensusInteractions(Search);        % find consensus interact list

index = find(diag(fix(abs(F.Edge)),1)==1);
Truncate = index+1;

% This might not work for the C-loop, Group_150 as of 2010-10-12

fprintf('pMakeMotifModelFromSSF: Truncate = %4d\n', Truncate);

% ---------------------------------------- Extract a motif signature

Signature = zMotifSignature(F.Edge,2,1,1);
fprintf('Signature: %s\n', Signature);

% -------------------------------- Make the model for the consensus structure

F.NT = File.NT(Search.Candidates(1,1:N));   % use the first candidate as model
F.Crossing = zeros(N,N);                    % small enough, pretend none
F.Range    = zeros(N,N);
F.NumNT = length(F.NT);

if length(Truncate) > 0,                    % at least two strands
  b = 1:N;
  for t = 1:N,
    b(t) = b(t) + 100*sum(t >= Truncate);
  end
  binv = 1:max(b);                                  % invert the spreading

%size(binv)
%size(b)
%N

  binv(b) = 1:N;
else
  b = 1:N;
  binv = 1:N;
end

FF.Filename      = File.Filename;
FF.Edge(b,b)     = F.Edge;                        % spread the strands out
FF.NT(b)         = F.NT;
FF.Crossing(b,b) = F.Crossing;
FF.Range(b,b)    = F.Range;

disp('pMakeMotifModelFromSSF:  Consensus interaction table with nucleotides from the first candidate:');
zShowInteractionTable(FF,b);

Node = pMakeNodes(FF,Param,1,b(N),Truncate);          % make the SCFG/MRF model

for n = 1:length(Node),
  Node(n).LeftIndex    = binv(Node(n).LeftIndex);
  Node(n).RightIndex   = binv(Node(n).RightIndex);
  Node(n).MiddleIndex  = binv(Node(n).MiddleIndex);
  Node(n).InterIndices = binv(Node(n).InterIndices);
end

% ---------------------------- Set parameters for the nodes from instances

Text = xAlignCandidates(Search.File,Search);

for t = 1:length(Text),
  fprintf('%s\n', Text{t});
end

for n = 1:length(Node),
  switch Node(n).type
  case 'Initial'
    if n == 1,
        %harsher penalties for initial node insertions
        Node(n).leftLengthDist = [.99,.01];     
        Node(n).rightLengthDist = [.99,.01];
    else
        a = max(Node(n-1).LeftIndex);                   % left NT of the query motif
        aa = min(Node(n+1).LeftIndex);          % next interacting base in the model
        b = min(Node(n-1).RightIndex);                  % right NT of the query motif
        bb = max(Node(n+1).RightIndex);      % next interacting base in the model
        %adjust insertion probs for initial nodes after clusters
        % ----------------------------- tally insertions on the left
            letter = Prior;                      % record which bases occur
            if n < length(Node)-1,                    % no insertions after last pair
             
              inscount = zeros(1,L);
              for c = 1:L,
                inscount(c) = abs(Search.Candidates(c,aa) - Search.Candidates(c,a)) - 1;
              end

        %disp('pMakeMotifModelFromSSF: Left insertion counts:')
        %inscount

              lld = zeros(1,max(inscount)+2);           % Dirichlet distribution
              for c = 1:L,
                lld(inscount(c)+1) = lld(inscount(c)+1) + 1;
                ff = Search.Candidates(c,N+1);          % file number
                d = Search.Candidates(c,a);             % index of interacting base
                if inscount(c) > 0,
                   for i = 1:inscount(c),
                     insb = Search.File(ff).NT(d+i).Code;  % A=1, C=2, G=3, U=4
                     if ~isempty(insb)
                       letter(insb) = letter(insb) + 1;
                     end
                   end
                end
              end

        %disp('pMakeMotifModelFromSSF: Left insertion tallies:')
        %lld
              numz = sum(lld==0);
              lld(lld==0) = (.01*sum(lld))/(1-.01*numz);
              Node(n).leftLengthDist = lld / sum(lld);    % normalize
              Node(n).leftLetterDist = letter / sum(letter);  % normalize 

        %     bb = max(Node(n+1).RightIndex);
        %     [rld,letter] = pInsertionConcenses(Search,Node,n,bb,b,Prior);
        %     Node(n).rightLengthDist = lld;
        %     Node(n).rightLetterDist = letter;

              % ----------------------------- tally insertions on the right
              inscount = zeros(1,L);
              letter = Prior;
              if bb==b
                inscount(1:L) = 0;
              else
                for c = 1:L,
                  inscount(c) = abs(Search.Candidates(c,b) - Search.Candidates(c,bb)) - 1;
                end
              end

        %disp('pMakeMotifModelFromSSF: Right insertion counts:')
        %inscount
              rld = zeros(1,max(inscount)+2);  % Dirichlet distribution
              for c = 1:L,
                rld(inscount(c)+1) = rld(inscount(c)+1) + 1;
                ff = Search.Candidates(c,N+1);          % file number
                d = Search.Candidates(c,b);            % index of interacting base
                if inscount(c) > 0,
                   for i = 1:inscount(c),
                     insb = Search.File(ff).NT(d-i).Code; % A=1, C=2, G=3, U=4
                     if ~isempty(insb)
                       letter(insb) = letter(insb) + 1;
                     end
                   end
                end
              end
        %disp('pMakeMotifModelFromSSF: Right insertion tallies:')
        %rld
              numz = sum(rld==0);
              rld(rld==0) = (.01*sum(rld))/(1-.01*numz);
              rld(rld==0) = sum(rld)*.01;
              Node(n).rightLengthDist = rld / sum(rld);    % normalize
              Node(n).rightLetterDist = letter / sum(letter);  % normalize 
            end
    end
    
  case 'Basepair'
    a = Node(n).LeftIndex;                   % left NT of the query motif
    b = Node(n).RightIndex;                  % right NT of the query motif

    disp('pMakeMotifModelFromSSF: Getting consensus for a basepair');

    Score = pConsensusPairSubstitution(a,b,f,Search.File,F,L,Search,Verbose);

    if Verbose > 0,
      fprintf('Original substitution probabilities\n');
      Node(n).SubsProb

      fprintf('Consensus substitution probabilities\n');
      Score
    end

    Node(n).SubsProb = Score;
     
%     aa = min(Node(n+1).LeftIndex);
%     [lld,letter] = pInsertionConcenses(Search,Node,n,a,aa,Prior);
%     Node(n).leftLengthDist = lld;
%     Node(n).leftLetterDist = letter;

% ----------------------------- tally insertions on the left
    inscount = zeros(1,L);          
    letter = Prior;                           % record which bases occur
    if n < length(Node)-1,                    % no insertions after last pair
      aa = min(Node(n+1).LeftIndex);          % next interacting base in the model
      for c = 1:L,
        inscount(c) = abs(Search.Candidates(c,aa) - Search.Candidates(c,a)) - 1;
      end

%disp('pMakeMotifModelFromSSF: Left insertion counts:')
%inscount

      lld = zeros(1,max(inscount)+2);           % Dirichlet distribution
      for c = 1:L,
        lld(inscount(c)+1) = lld(inscount(c)+1) + 1;
        ff = Search.Candidates(c,N+1);          % file number
        d = Search.Candidates(c,a);             % index of interacting base
        if inscount(c) > 0,
           for i = 1:inscount(c),
             insb = Search.File(ff).NT(d+i).Code;  % A=1, C=2, G=3, U=4
             if ~isempty(insb)
               letter(insb) = letter(insb) + 1;
             end
           end
        end
      end

%disp('pMakeMotifModelFromSSF: Left insertion tallies:')
%lld
      numz = sum(lld==0);
      lld(lld==0) = (.01*sum(lld))/(1-.01*numz);
      Node(n).leftLengthDist = lld / sum(lld);    % normalize
      Node(n).leftLetterDist = letter / sum(letter);  % normalize 

%     bb = max(Node(n+1).RightIndex);
%     [rld,letter] = pInsertionConcenses(Search,Node,n,bb,b,Prior);
%     Node(n).rightLengthDist = lld;
%     Node(n).rightLetterDist = letter;

      % ----------------------------- tally insertions on the right
      inscount = zeros(1,L);
      letter = Prior;
      bb = max(Node(n+1).RightIndex);      % next interacting base in the model
      if bb==b
        inscount(1:L) = 0;
      else
        for c = 1:L,
          inscount(c) = abs(Search.Candidates(c,b) - Search.Candidates(c,bb)) - 1;
        end
      end
    
%disp('pMakeMotifModelFromSSF: Right insertion counts:')
%inscount
      rld = zeros(1,max(inscount)+2);  % Dirichlet distribution
      for c = 1:L,
        rld(inscount(c)+1) = rld(inscount(c)+1) + 1;
        ff = Search.Candidates(c,N+1);          % file number
        d = Search.Candidates(c,b);            % index of interacting base
        if inscount(c) > 0,
           for i = 1:inscount(c),
             insb = Search.File(ff).NT(d-i).Code; % A=1, C=2, G=3, U=4
             if ~isempty(insb)
               letter(insb) = letter(insb) + 1;
             end
           end
        end
      end
%disp('pMakeMotifModelFromSSF: Right insertion tallies:')
%rld
      numz = sum(rld==0);
      rld(rld==0) = (.01*sum(rld))/(1-.01*numz);
      rld(rld==0) = sum(rld)*.01;
      Node(n).rightLengthDist = rld / sum(rld);    % normalize
      Node(n).rightLetterDist = letter / sum(letter);  % normalize 
    end

  case 'Cluster'
    Indices = [Node(n).LeftIndex(Node(n).Left) ...
               Node(n).RightIndex(Node(n).Right)];
     for ii = 1:length(Node(n).IBases(:,1)),
      a = Indices(Node(n).IBases(ii,1));
      b = Indices(Node(n).IBases(ii,2));

disp('pMakeMotifModelFromSSF: Getting consensus for pairs in a cluster');

      Score = pConsensusPairSubstitution(a,b,f,Search.File,F,L,Search,Verbose);

    if Verbose > 0,
      fprintf('Original substitution probabilities\n');
      Node(n).SubsProb(:,:,ii)

      fprintf('Consensus substitution probabilities\n');
      Score
    end

      Node(n).SubsProb(:,:,ii) = Score;
      if Verbose > 0,
        fprintf('\n');
      end
      
      %Adjust insertion probabilities
      if L<100,
      Node(n).Insertion = [];
      LeftInteracting = intersect(Node(n).LeftIndex, Node(n).InterIndices(:));
      RightInteracting = intersect(Node(n).RightIndex, Node(n).InterIndices(:));
      Interacting = union(LeftInteracting,RightInteracting);
      PosIns = setdiff(Interacting,union(max(LeftInteracting),max(RightInteracting)));
      for k = 1:length(PosIns),
          minIns = 0;
         if ismember(PosIns(k),LeftInteracting),      %Left side
             a = PosIns(k);
             aloc = find(LeftInteracting == a);
             aa = LeftInteracting(aloc+1);
             fi = find(Node(n).LeftIndex == a);
             li = find(Node(n).LeftIndex == aa);
             Right=0;
   %          minIns = li-fi-1;
         else                                         %Right side
             a = PosIns(k);
             aloc = find(RightInteracting == a);
             aa = RightInteracting(aloc+1);
             fi = find(Node(n).RightIndex == a);
             li = find(Node(n).RightIndex == aa);
             Right=1;
   %          minIns = li-fi-1;
         end
         inscount = [];
         letter = Prior;
         for c = 1:L,
           inscount(c) = abs(Search.Candidates(c,aa) - Search.Candidates(c,a)) - 1;
         end
         if max(inscount) ~= 0,                    % if insertion seen, add to node
           lld = zeros(1,max(inscount)+2);         % Dirichlet distribution
           for c = 1:L,
            lld(inscount(c)+1) = lld(inscount(c)+1) + 1;
            ff = Search.Candidates(c,N+1);         % file number
            d = Search.Candidates(c,a);            % index of interacting base
            if inscount(c) > 0,
                for i = 1:inscount(c),
                  insb = Search.File(ff).NT(d+i).Code;  % A=1, C=2, G=3, U=4
                  if ~isempty(insb)
                    letter(insb) = letter(insb) + 1;
                  end
                end
            end
           end
           InsNum = length(Node(n).Insertion)+1;
           numz = sum(lld==0)-minIns;
           lld(lld==0) = (.01*sum(lld))/(1-.01*numz);
           if minIns > 0,
             lld(1:minIns) = 0;
           end
           Node(n).Insertion(InsNum).Position = find(Interacting == a);
           Node(n).Insertion(InsNum).LengthDist = lld / sum(lld);        % normalize
           Node(n).Insertion(InsNum).LetterDist = letter / sum(letter);  % normalize
           l1=Search.Candidates(1,a);
           l2=Search.Candidates(1,aa);
           Node(n).InsertionComment{InsNum} = [' // Insertion between ' File.NT(l1).Base File.NT(l1).Number ' and ' File.NT(l2).Base File.NT(l2).Number];
         end
      end
     end
   end  
  case 'Junction'

  end

  if Verbose > 0,
    fprintf('\n')
  end
end
