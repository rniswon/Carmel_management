function extractMeasuredFromCSV
% Looks through mGSFLOW post processing Output files for the respective
% gages, extracts measured values, and creates Streamflow_MeasuredAndSimulated.mat

% Load the measured streamflow data
disp(' Select the Streamflow_Measured.mat file (GSFLOW/Streamflow Folder)')
[filename, pathname] = uigetfile('Streamflow_Measured.mat', 'select Streamflow_Measured.mat ');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
   return
else
   disp(['User selected ', fullfile(pathname, filename)])
   eval(['load ',fullfile(pathname,filename)]);
end 

% Gages CSV file
disp(' select GAGES CSV File')
[filename, pathname] = uigetfile('Gages_Data.csv', 'Pick Gages_Data.CSV File ');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
   return;
else
   disp(['User selected ', fullfile(pathname, filename)])
end


% Scan in Gages CSV File
fid = fopen(fullfile(pathname,filename),'r');
C   = textscan(fid,'%n %s %s %n %n %n %n %n %n %n %n %n %n %n %n','headerlines',1','delimiter',',');
fclose(fid);

% Data we want
cfs = C{8};
filename = C{2};
[G,~]=strtok(filename,'.');
time = C{3};
stage_ft = C{4};

% Loop through the gages
%gages = {'H1' 'BLP' 'ALP' 'Los_Padres_Res' 'DJ' 'NC' 'RR' 'SH'};
gages = {'AD' 'ALP' 'AS' 'BL' 'CA' 'CL' 'DJ' 'GA' 'GC' 'H1' 'HI' 'Los_Padres_Res' 'LP' 'NC' 'PI' 'PO' 'RC' 'RR' 'SH' 'SJ' 'TU'};



for i=1:length(gages)
    eval(['V=',cell2mat(gages(i)),';'])
    f = cell2mat(gages(i));
    disp([' working on ',f]);
    a = strfind(G,f);
    
    % Indices
    n=[];
    for j=1:length(a)
        if ~isempty(cell2mat(a(j)))
            n=[n;j];
        end
    end
    
    % Simulated Time and Flow for this gage
    t_sim    = datenum(time(n));
    flow_sim = cfs(n);
    stage_sim = stage_ft(n);
    
    % Measured Time and Flow for this gage
    t_meas = datenum(V.year, V.month, V.day);
    flow_meas = V.measured_cfs;
    
    % Intersection of time
    [I,IA,IB] = intersect(t_sim,t_meas);
    
    % Matching Time
    t_match = I;
    flow_sim_match  = flow_sim(IA,:);
    flow_meas_match = flow_meas(IB,:);
    stage_sim_match = stage_sim(IA,:);
    
    % Los Padres Reservoir - want lake stage as well.
    %if i==3
    %    stage_sim_match = stage_sim(IA,:);
    %end
    
    
    % Matching Times
    %b = find(t_sim>=t_meas(1) & t_sim<=t_meas(end));
    
    % Matching Simulated Flow
    %flow_match = flow_sim(b);
    
    % Confirm that the size of the measured and simulated are the same
    %if length(t_meas) ~= length(flow_match)
    %    beep;
    %    disp(' measured and simulated time vectors not of equal length. kbd')
    %    if abs(length(t_meas)-length(flow_match))==1
    %        flow_match=[0;flow_match];
    %    else
    %        keyboard
    %    end
    %end
    
    % Put matching flow in V
    V.matching_time = t_match;
    V.matching_simulated_cfs = flow_sim_match;
    V.matching_measured_cfs  = flow_meas_match;
    V.matching_simulated_stage_ft = stage_sim_match;
    
    % Rename V to gage
    eval([f,'=V;'])
end

% Clean Up
clear a*;
clear b*;
clear C;
clear c*;
clear f*;
clear G;
clear g*;
clear i;
clear j;
clear n;
clear p*
clear t*;
clear V;
clear I*;
clear s*;
disp(' Saving Streamflow_MeasuredAndSimulated.mat...');
save Streamflow_MeasuredAndSimulated.mat;





