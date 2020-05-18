function lowFlowAnalysis

% Load Streamflow_MeasuredAndSimulated (originally xlsx)
load Streamflow_MeasuredAndSimulated.mat

gages = {'H1' 'ALP' 'Los_Padres_Res' 'DJ' 'NC' 'RR' 'SH'};

mos = [10 11 12 1 2 3 4 5 6 7 8 9];

cutoff = [500 200 20 0];

% Years
yrs = 1992:1:2015;

% Open Output and write header
fid = fopen('MeasuredVsSimulated_LowFlow.csv','wt');
fprintf(fid,'Gage, Year, Month, Cutoff Low (cfs), Cutoff High (cfs), Average Simulated (cfs), Standard Deviation Simulated (cfs), Average Measured (cfs), Standard Deviation Measured (cfs), count, r2\n');


% Loop through each Gage 
for g = 1:length(gages)
    
    % Put current Gage in G
    currentGage = gages(g);
    eval(['G=',cell2mat(currentGage),';'])
    
    % Data
    [yr,mo,dy] = datevec(G.matching_time);
    sim        = G.matching_simulated_cfs;
    meas       = G.matching_measured_cfs;
    time       = datenum(yr,mo,dy);
    
    % Loop through each year
    for y=1:length(yrs)
        
        % Current Year
        a = find(yr==yrs(y));
        
        if ~isempty(a)
            s   = sim(a);
            m   = meas(a);
            t   = time(a);
            tmo = mo(a);
            
            % Loop Through each month
            for j =1:length(mos)
                b = find(tmo==mos(j));
                
                if ~isempty(b)
                    
                    sout = s(b);
                    mout = m(b);
                    tout = tmo(b);
                    
                    % Loop through each cutoff value
                    for k=1:length(cutoff)-1
                        c = find(mout<=cutoff(k) & mout>=cutoff(k+1));
                        
                        if length(c)>2
                            
                            warning off
                            % Fit and correlation
                            [P,S] = polyfit(mout(c),sout(c),1);
                            R     = corrcoef(mout(c),sout(c));
                            R     = R(1,2);
                            warning on
                            
                            if isnan(R)
                                R = '';
                            else
                                R=num2str(R);
                            end
                            
                            % Output
                            fprintf(fid,'%s,%6.0f,%6.0f,%6.0f,%6.0f, %6.2f,%6.2f,%6.2f,%6.2f, %6.0f, %s\n',...
                                cell2mat(currentGage),yrs(y),mos(j),cutoff(k+1),cutoff(k),...
                                mean(sout(c),'omitnan'),std(sout(c),'omitnan'),...
                                mean(mout(c),'omitnan'),std(mout(c),'omitnan'),length(sout(c)),R);
                        end
                    end
                end
            end
        end
    end
end

                    
