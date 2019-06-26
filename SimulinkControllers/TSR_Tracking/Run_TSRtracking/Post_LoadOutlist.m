function Outlist = Post_LoadOutlist(FAST_OutFile)
% Load Model OutList from an *.out file. 
% Loads OpenFast model output into a MATLAB structure to be post processed
%
% Inputs: FAST_OutFile - *.out file from an openfast run
% Outputs: OutList - Cell Array containing names of openfast output
%                    channels
%
% Nikhar Abbas


fid = fopen(FAST_OutFile, 'r');
if fid == -1, error('Error loading file'), end

% Define Headers
n_rec = 0;                              % record keeper to keep while loop running until the header line has been found    
ind = 0;
while n_rec == 0 
    ind = ind+1;
    tline = fgetl(fid);
    w_str = strtrim(tline);
    w_str = strsplit(w_str); 
    if strcmpi(w_str{1},'time')
        n_rec = 1;
        headers = w_str;                % define headers
        
        tline = fgetl(fid);
        check = strtrim(tline);         
        if check(1) == '('              % find units line
            units = strtrim(tline);
            units = strsplit(units);    % define units
            ind = ind+1;                % index headerlines
        end
    end
end

Outlist = headers';

end