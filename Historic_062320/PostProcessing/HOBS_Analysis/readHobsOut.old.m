function readHobsOut

% Does hobsout.dat exist in the pwd?
if ~exist('hobsout.dat','file')
    disp(' hobsout.dat not found in pwd. breaking.')
    return
end

% Scan it in
fid = fopen('hobsout.dat','r');
C   = textscan(fid,'%n %n %s','headerlines',1);
fclose(fid);
    
% Parse
sim  = C{1};
obs  = C{2};
ID   = C{3};

% Open temp file and write formatted data
fid = fopen('_temp.tmp','wt');

for i=1:length(ID)
    currentWell = cell2mat(ID(i));
    [t,r]       = strtok(currentWell,'_');
    
    % Well name in variable 't'
    % Time info in variable 'r'
    r  = strrep(r,'_','');
    mo = str2num(r(1:2));
    dy = str2num(r(3:4));
    yr = str2num(r(5:8));
    dnum = datenum(yr,mo,dy);
    
    outStr = sprintf('%9.4f %9.4f %9.0f %s',sim(i),obs(i),dnum,t);
    fprintf(fid,'%s\n',outStr);
end
fclose(fid);

% Read the temp file back in and delete temp file
clear
fid = fopen('_temp.tmp','r');
C   = textscan(fid,'%n %n %n %s');
fclose(fid);
delete('_temp.tmp');

% Assign
sim  = C{1};
obs  = C{2};
dnum = C{3};
well = C{4};

well_seq={};

% Make a new well variable that will be sequential
for i=1:length(well)
    w = lower(cell2mat(well(i)));
    wnum = str2num(strrep(w,'w',''));
    if wnum<10
        wnew=['w0',int2str(wnum)];
    else
        wnew=['w',int2str(wnum)];
    end
    well_seq{i}=wnew;
end
well_seq=well_seq';        
        
    
    
    

% Scan in the Common Name csv file
fid = fopen('well_common_names.csv','r');
C   = textscan(fid,'%s','headerlines',1,'delimiter',',');
fclose(fid);
commonName = C{1};
%commonWell = unique(well);
commonWell = unique(well_seq);

% Open STATS Output file here
fido = fopen('HOBS_Stats.csv','w');
hdr = ['Well No., Common Name, Year, Yr_Count, Yr_r, Q1_Count, Q1_r, Q2_Count, Q2_r, Q3_Count, Q3_r, Q4_Count, Q4_r'];
fprintf(fido,'%s\n',hdr);

% Loop to calculate Stats here
for i=1:length(commonWell)
    %b           = find(strcmp(commonWell(i),well));
    b           = find(strcmp(commonWell(i),well_seq));
    
    if isempty(b)
        beep
        keyboard
    end
    
    currentWell = cell2mat(commonWell(i));
    currentSim  = sim(b);
    currentObs  = obs(b);
    currentTime = dnum(b);
    currentName = cell2mat(commonName(i));
    
    % Try stats by Year and Quarter
    [yr,mo,dy] = datevec(currentTime);
    
    % Calcualte stats for entire data set for this well
    currentDelta = abs(currentSim-currentObs);
    [r,p] = corrcoef(currentObs,currentDelta);
    [nrows,ncols] = size(r);
    if ncols>1
        r     = r(1,2);
    end
    r = abs(r);
    out = sprintf('%s,%s,All Years,%6.0f,%1.4f,,,,,,,,,',...
                currentWell,currentName,length(currentObs),r);
    fprintf(fido,'%s\n',out);
    
    % Years to loop through
    lyr = 1990:1:2015;
    for y = 1:length(lyr)
        currentYr = lyr(y);
        c = find(yr==currentYr);
        
        if ~isempty(c)
            
            yrSim      = currentSim(c);
            yrObs      = currentObs(c);
            yrYr       = yr(c);
            yrMo       = mo(c);
            yrDy       = dy(c);
            yrDelta    = abs(yrSim-yrObs);
            
            % Determine correlation coefficient
            [r,p] = corrcoef(yrObs,yrDelta);
            [nrows,ncols] = size(r);
            if ncols>1
                r     = r(1,2);
            end
            r = abs(r);
            
            
            % Yearly Output
            if length(c) > 1
                outYr = sprintf('%s,%s,%6.0f,%6.0f,%1.4f,',...
                    currentWell,currentName,currentYr,length(c),r);
            else
                 outYr = sprintf('%s,%s,%6.0f,%6.0f, ,',...
                    currentWell,currentName,currentYr,length(c));
            end
               
            
            % Quarters to Loop through
            qStart = [1 4 7 10];
            qEnd   = [3 6 9 12];
            
            out = outYr;
            for q=1:4
                a = find(yrMo>=qStart(q) & yrMo<=qEnd(q));
                if isempty(a)
                    % No data this quarter
                    v1 = 0;
                    v2 = 0;
                    %outQ = sprintf('%6.0f,%1.4f,',v1,v2);
                    outQ = [', ,'];
                else
                    
                    % Determine correlation coefficient
                    [r,p] = corrcoef(yrObs(a),yrDelta(a));
                    [nrows,ncols] = size(r);
                    if ncols>1
                        r     = r(1,2);
                    end
                    r = abs(r);
                    if length(a)>1                    
                        outQ = sprintf('%6.0f,%1.4f,',length(a),r);
                    else
                        outQ = sprintf('%6.0f, ,',length(a));
                    end
                end
                % Splice
                out = [out outQ];
            end
            
            % Write the stats
            fprintf(fido,'%s\n',out);
        end
    end
end
fclose(fido);
            
                
            





%keyboard
%return

%% PLOTTING

% Unique Wells - loop through and plot
a = unique(well);
for i=1:length(a)
    b=find(strcmp(a(i),well));
    
    currentName = cell2mat(a(i));
    currentSim  = sim(b);
    currentObs  = obs(b);
    currentTime = dnum(b);
    titleName = cell2mat(commonName(i));
    
    c = find(currentSim==0);
    if ~isempty(c)
        currentSim(c)=NaN;
    end
    d = find(currentObs==0);
    if ~isempty(d)
        currentObs(d)=NaN;
    end
    
    
    figure(1);
    clf;
    subplot(211);
    plot(currentTime,currentObs,'-r*',currentTime,currentSim,'-bo');
    xlabel('Time')
    ylabel('Elevation')
    legend('Obs','Sim');
    datetick('x');
    title(currentName);
    %title(titleName);
    
    subplot(212);
    plot(currentObs,currentSim,'ko');
    V=axis;
    F=V;
    
    e = find(V==min(V));
    f = find(V==max(V));
    e = e(1);
    f = f(1);
    
    F(1) = V(e);
    F(3) = V(e);
    F(2) = V(f);
    F(4) = V(f);
    axis(F);
    %F=V;
    %if V(1)>V(3)
    %    F(1)=V(3);
    %else
    %    F(1)=V(1);
    %end
    %if V(2)>V(4)
    %    F(4)=V(2);
    %else
    %    F(4)=V(4);
    %end
    %axis(F);
        
    xlabel('Elevation: Obs');
    ylabel('Elevation: Sim');
    
    eval(['print ',currentName,' -dpdf'])
    
end



   
    

        

