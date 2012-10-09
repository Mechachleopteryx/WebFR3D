function NormC = pClusterNorm(InterIndicesF,SubsProbF,LeftIndex,RightIndex)
    psum = 0;
    [numInterF,dum] = size(InterIndicesF);
    InterIndices = InterIndicesF(1,:);
    Inters = 1;
    added = 1;
    while added == 1,
        added = 0;
        for i = 2:numInterF,
            if ~isempty(intersect(InterIndices(:),InterIndicesF(i,:))) && isempty(intersect(i,Inters)),
                [numInter,dum] = size(InterIndices);
                InterIndices(numInter+1,:) = InterIndicesF(i,:);
                Inters(numInter+1) = i;
                added = 1;
            end
        end
    end
    SubsProb = SubsProbF(:,:,Inters);
    IBases = sort(unique(InterIndices(:)));
    Left = [];  Right = [];
    for i = 1:length(IBases),
        if IBases(i) < 100,
            Left(length(Left)+1) = find(LeftIndex == IBases(i));
        else
            Right(length(Right)+1) = find(RightIndex == IBases(i));
        end
    end
    numBases = length(Left) + length(Right);
    [numInter,dum] = size(InterIndices);
    Cols(1:length(Left)) = LeftIndex(Left);
    Cols(length(Left)+1:length(Left)+length(Right)) = RightIndex(Right);
    % System.out.println("ClusterNode.Normalize "+numIndices);
    if numInter == 1,
        psum = 1;
    else
        for i = 1:4^numBases,
            for j = 1:numBases
                li = floor((i-1)/(4^(numInter-j)));
                li = mod(li,4)+1;
                code(j) = li;
            end
            [numInter,dum] = size(InterIndices);
            % score codes[] according to the various interactions
            prob = 1;
            for j = 1:numInter,
                i1 = find(Cols == InterIndices(j,1));
                i2 = find(Cols == InterIndices(j,2));
                prob = prob*SubsProb(code(i1),code(i2),j);
            end
            psum = psum+prob;    
        end
    end
    if numInterF-numInter <= 1,
        NormC = psum;
    else
        remInt = setDiff(1:numInterF,Inters);
        InterIndicesR = InterIndicesF(remInt,:);
        SubsProbR = SubsProbF(:,:,remInt);
        NormC = psum*pClusterNorm(InterIndicesR,SubsProbR,LeftIndex,RightIndex);
    end
end