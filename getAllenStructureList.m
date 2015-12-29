function [ARA_list, col_names] = getAllenStructureList(downloadAgain)
% Download the list of adult mouse structures from the Allen API. 
%
% function [ARA_list, col_names] = getAllenStructureList(downloadAgain)
%
% Purpose
% Make an API query to read in the Allen Reference Atlas (ARA) brain area
% list. All areas and data are read. Data are cached in the system's temp
% directory and re-read from here if possible to improve speed. 
% 
% Inputs
% If downloadAgain is supplied and is true, the function wipes cached data
% and re-reads. zero by default. 
%
%
% Outputs
% ARA_list - a cell array containing the imported data. missing values replaced with -inf
% col_names - the names of the columns
%
%
%
% Rob Campbell - Basel 2015


if nargin<1
	downloadAgain=0;
end



cachedCSV = sprintf('/tmp/%s_CACHED.csv',mfilename);
cachedMAT =  sprintf('/tmp/%s_CACHED.mat',mfilename);



if ~downloadAgain 
	if exist(cachedMAT) %If the data have been imported before we can just return them
		load(cachedMAT)
		return
	end
end

%If we get here, the user either asked for the data be re-read or we couldn't find any cached data



% The adult mouse structure graph has an id of 1.		
url='http://api.brain-map.org/api/v2/data/Structure/query.csv?criteria=[graph_id$eq1]&num_rows=all';
[~,status] = urlwrite(url,cachedCSV);
if ~status
	error('Failed to get CSV file from URL %s', url)
end


fid = fopen(cachedCSV);
if fid<0
	error('Failed to open CSV file at %s\n', cachedCSV)
end


col_names = strsplit(fgetl(fid),','); %The names of the columns in the main cell array

%Loop through and read each data row
ARA_list={};
tline = fgetl(fid);

while ischar(tline)
	%First we need to get rid of any 
	tmp=textscan(tline,'%d%d%q%s%d%d%d%d%d%d%d%d%s%s%s%s%s%d%d%d%s','delimiter',',','emptyvalue',-inf);
	ARA_list = [ARA_list;tmp];
	tline=fgetl(fid);
end





fclose(fid);

%save to disk if needed
if ~exist(cachedMAT) | downloadAgain
	save(cachedMAT,'col_names','ARA_list')
end