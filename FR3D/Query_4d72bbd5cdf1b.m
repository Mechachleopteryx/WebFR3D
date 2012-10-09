Query.Filename = '3I8I';
Query.ChainList{1}='A';
Query.ChainList{2}='A';
Query.ChainList{3}='A';
Query.ChainList{4}='A';
Query.ChainList{5}='A';
Query.ChainList{6}='A';
Query.ChainList{7}='A';
Query.ChainList{8}='A';
Query.ChainList{9}='A';
Query.ChainList{10}='A';
Query.ChainList{11}='A';
Query.ChainList{12}='A';
Query.ChainList{13}='A';
NTList = '1856_A,1857_A,1858_A,1859_A,1860_A,1870_A,1871_A,1872_A,1878_A,1879_A,1880_A,1881_A,1882_A';
Query.DiscCutoff = 0.4;
Query.Name = '4d72bbd5cdf1b';
Query.Geometric = 1;
Query.ExcludeOverlap=1;
Query.SearchFiles = cell(1,1);
Query.SearchFiles{1} = '3I8I';
[File,QIndex] = zAddNTData(Query.Filename);
[Indices,Ch] = zIndexLookup(File(QIndex),NTList);
Query.NumNT = length(Indices);
for i=1:min(25,length(Indices)),    Query.NTList{i} =File(QIndex).NT(Indices(i)).Number;    Query.NT(i) = File(QIndex).NT(Indices(i));end
Query.Diagonal{1} ='N';
Query.Diagonal{2} ='N';
Query.Diagonal{3} ='N';
Query.Diagonal{4} ='N';
Query.Diagonal{5} ='N';
Query.Diagonal{6} ='N';
Query.Diagonal{7} ='N';
Query.Diagonal{8} ='N';
Query.Diagonal{9} ='N';
Query.Diagonal{10} ='N';
Query.Diff{2,1} ='';
Query.Diff{3,1} ='';
Query.Diff{3,2} ='';
Query.Diff{4,1} ='';
Query.Diff{4,2} ='';
Query.Diff{4,3} ='';
Query.Diff{5,1} ='';
Query.Diff{5,2} ='';
Query.Diff{5,3} ='';
Query.Diff{5,4} ='';
Query.Diff{6,1} ='';
Query.Diff{6,2} ='';
Query.Diff{6,3} ='';
Query.Diff{6,4} ='';
Query.Diff{6,5} ='';
Query.Diff{7,1} ='';
Query.Diff{7,2} ='';
Query.Diff{7,3} ='';
Query.Diff{7,4} ='';
Query.Diff{7,5} ='';
Query.Diff{7,6} ='';
Query.Diff{8,1} ='';
Query.Diff{8,2} ='';
Query.Diff{8,3} ='';
Query.Diff{8,4} ='';
Query.Diff{8,5} ='';
Query.Diff{8,6} ='';
Query.Diff{8,7} ='';
Query.Diff{9,1} ='';
Query.Diff{9,2} ='';
Query.Diff{9,3} ='';
Query.Diff{9,4} ='';
Query.Diff{9,5} ='';
Query.Diff{9,6} ='';
Query.Diff{9,7} ='';
Query.Diff{9,8} ='';
Query.Diff{10,1} ='';
Query.Diff{10,2} ='';
Query.Diff{10,3} ='';
Query.Diff{10,4} ='';
Query.Diff{10,5} ='';
Query.Diff{10,6} ='';
Query.Diff{10,7} ='';
Query.Diff{10,8} ='';
Query.Diff{10,9} ='';
Query.Edges{1,2} ='';
Query.Edges{1,3} ='';
Query.Edges{1,4} ='';
Query.Edges{1,5} ='';
Query.Edges{1,6} ='';
Query.Edges{1,7} ='';
Query.Edges{1,8} ='';
Query.Edges{1,9} ='';
Query.Edges{1,10} ='';
Query.Edges{2,3} ='';
Query.Edges{2,4} ='';
Query.Edges{2,5} ='';
Query.Edges{2,6} ='';
Query.Edges{2,7} ='';
Query.Edges{2,8} ='';
Query.Edges{2,9} ='';
Query.Edges{2,10} ='';
Query.Edges{3,4} ='';
Query.Edges{3,5} ='';
Query.Edges{3,6} ='';
Query.Edges{3,7} ='';
Query.Edges{3,8} ='';
Query.Edges{3,9} ='';
Query.Edges{3,10} ='';
Query.Edges{4,5} ='';
Query.Edges{4,6} ='';
Query.Edges{4,7} ='';
Query.Edges{4,8} ='';
Query.Edges{4,9} ='';
Query.Edges{4,10} ='';
Query.Edges{5,6} ='';
Query.Edges{5,7} ='';
Query.Edges{5,8} ='';
Query.Edges{5,9} ='';
Query.Edges{5,10} ='';
Query.Edges{6,7} ='';
Query.Edges{6,8} ='';
Query.Edges{6,9} ='';
Query.Edges{6,10} ='';
Query.Edges{7,8} ='';
Query.Edges{7,9} ='';
Query.Edges{7,10} ='';
Query.Edges{8,9} ='';
Query.Edges{8,10} ='';
Query.Edges{9,10} ='';
aWebFR3DSearch;
aWriteHTMLForSearch('4d72bbd5cdf1b');