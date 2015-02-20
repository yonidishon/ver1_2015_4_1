function [ fname ] = fnameExtractor( filename )
    query_name=strsplit(filename,'\');
    query_name=query_name{end};
    %%%% for Time Mapping Code only %%%%
    %query_name=strsplit(query_name,'.');
    %fname=query_name{1};
    fname=query_name;
    %%%% for Time Mapping Code only %%%%
end

