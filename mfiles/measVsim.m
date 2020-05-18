function measVsim

% Load Streamflow_MeasuredAndSimulated (originally xlsx)
load Streamflow_MeasuredAndSimulated.mat

gages = {'H1' 'ALP' 'Los_Padres_Res' 'DJ' 'NC' 'RR' 'SH'};

mos = [10 11 12 1 2 3 4 5 6 7 8 9];

% Water Years
yrs = 1993:1:2015;

% Cutoffs
cutoffs=[0 20 200 500];

% Water Year starting date number
wy_start = [];
wy_stop  = [];
for i=1:length(yrs)
    s = datenum(yrs(i)-1,10,1);
    e = datenum(yrs(i),9,30);
    
    wy_start = [wy_start;s];
    wy_stop   = [wy_stop;e];
end

%% WATER YEAR STATS

% Open Output and write header
fid = fopen('MeasuredVsSimulated_WaterYear.csv','wt');
fprintf(fid,'Gage, Time Start, Time Stop, Cutoff min (cfs), Cutoff max (cfs), Average Simulated (cfs), Standard Deviation Simulated (cfs), Average Measured (cfs), Standard Deviation Measured (cfs), count, r2\n');

% PLOTTING DISABLED FOR NOW
%
% Output Folder for plots
%if ~exist('MeasuredAndSimulated_Plots','dir')
%    disp(' Creating output folder for plots...')
%    mkdir('MeasuredAndSimulated_Plots')
%end

% Disable warning for polyfit
warning off;

% Loop through each Gage 
for g = 1:length(gages)
    
    % Put current Gage in G
    currentGage = gages(g);
    eval(['G=',cell2mat(currentGage),';'])
    
    % Data
    [y,m,d] = datevec(G.matching_time);
    sim     = G.matching_simulated_cfs;
    meas    = G.matching_measured_cfs;
    time    = datenum(y,m,d);
    
    % Water Year Stats
    for i=1:length(wy_start)
        
        % Water Year
        wy = datestr(wy_stop(i),10);
        
        % Time vector for this water year
        a = find(time>=wy_start(i) & time<=wy_stop(i));
        
        if length(a)>1
        
            % Data for this water year
            s = sim(a);
            m = meas(a);
            t = time(a);
            
            % Don't include Nans in measurements
            a = find(~isnan(m));
            s = s(a);
            m = m(a);
            t = t(a);
                         
            if ~isempty(m)

                % Fit and correlation
                [P,S] = polyfit(m,s,1);
                R     = corrcoef(m,s);
                R     = R(1,2);

                % Fit curve;
                mfit = min(m):1:max(m);
                sfit = polyval(P,mfit);

                % Output
                fprintf(fid,'%s,%s,%s,%4.0f,%4.0f,%6.2f,%6.2f,%6.2f,%6.2f,%6.0f,%4.4f\n',...
                    cell2mat(currentGage),datestr(wy_start(i)),...
                    datestr(wy_stop(i)),0,10000,mean(s,'omitnan'),std(s,'omitnan'),...
                    mean(m,'omitnan'),std(m,'omitnan'),length(s),R);

                % Plot
                %figure(1);clf
                %plot(m,s,'o');hold on;axis equal;
                %xlabel('Measured (cfs)')
                %ylabel('Simulated (cfs)')
                %titleStr = ['Gage ',cell2mat(currentGage),': Water Year ',wy,': Correlation ',num2str(R)];
                %titleStr = strrep(titleStr,'_','-');
                %title(titleStr);
                %plot(mfit,sfit,'k--');
                %printStr = ['MeasuredAndSimulated_Plots',filesep,cell2mat(currentGage),'_WY',wy,'_measVsim'];
                %eval(['print ',printStr,' -dpng'])
            end
            
            % NEW: Cutoff Loop
            for j=1:length(cutoffs)-1
                cutoffmin = cutoffs(j);
                cutoffmax = cutoffs(j+1);
                
                a = find(m>=cutoffmin & m<=cutoffmax);
                if ~isempty(a)
                    scut = s(a);
                    mcut = m(a);
                    
                    if length(a)>=3
                    
                        % Fit and correlation
                        [P,S] = polyfit(mcut,scut,1);
                        R     = corrcoef(mcut,scut);
                        R     = R(1,2);

                        % Fit curve;
                        mfit = min(mcut):1:max(mcut);
                        sfit = polyval(P,mfit);

                        % Output
                        fprintf(fid,'%s,%s,%s,%4.0f,%4.0f,%6.2f,%6.2f,%6.2f,%6.2f,%6.0f,%4.4f\n',...
                            cell2mat(currentGage),datestr(wy_start(i)),...
                            datestr(wy_stop(i)),cutoffmin,cutoffmax,mean(scut,'omitnan'),std(scut,'omitnan'),...
                            mean(mcut,'omitnan'),std(mcut,'omitnan'),length(scut),R);

                        % Plot
                        %figure(1);clf
                        %plot(mcut,scut,'o');hold on;axis equal;
                        %xlabel('Measured (cfs)')
                        %ylabel('Simulated (cfs)')
                        %titleStr = ['Gage ',cell2mat(currentGage),': Water Year ',wy,': ',num2str(cutoffmin),'-',num2str(cutoffmax),'cfs : Correlation ',num2str(R)];
                        %titleStr = strrep(titleStr,'_','-');
                        %title(titleStr);
                        %plot(mfit,sfit,'k--');
                        %printStr = ['MeasuredAndSimulated_Plots',filesep,cell2mat(currentGage),'_WY',wy,'_measVsim_',num2str(cutoffmin),'-',num2str(cutoffmax),'cfs'];
                        %eval(['print ',printStr,' -dpng'])
                    end
                end
            end       
        end
    end
end
fclose(fid);

%% MONTHLY STATS

% Open Output and write header
fid = fopen('MeasuredVsSimulated_Monthly.csv','wt');
fprintf(fid,'Gage, Year, Month, Average Simulated (cfs), Standard Deviation Simulated (cfs), Average Measured (cfs), Standard Deviation Measured (cfs), count, r2\n');

% Loop through each Gage 
for g = 1:length(gages)
    
    % Put current Gage in G
    currentGage = gages(g);
    eval(['G=',cell2mat(currentGage),';'])
    
    % Data
    [yr,mo,dy] = datevec(G.matching_time);
    sim     = G.matching_simulated_cfs;
    meas    = G.matching_measured_cfs;
    time    = datenum(yr,mo,dy);
    
    % NEW: Loop through years
    for j=1:length(yrs)
        
        a = find(yr==yrs(j));
        s = sim(a);
        m = meas(a);
        t = time(a);
        moy=mo(a);
    
    
        % Loop through the months
        for i=1:length(mos)
            currentMo = mos(i);

            % Matching Months
            a=find(moy==currentMo);

            if length(a)>1

                % Data for this Month
                s = sim(a);
                m = meas(a);
                t = time(a);

                % Don't include Nans in measurements
                a = find(~isnan(m));
                s = s(a);
                m = m(a);
                t = t(a);

                if ~isempty(m)

                    % Fit and correlation
                    [P,S] = polyfit(m,s,1);
                    R     = corrcoef(m,s);
                    R     = R(1,2);
                    if isnan(R)
                        R='';
                    else
                        R=num2str(R);
                    end


                    % Fit curve;
                    mfit = min(m):1:max(m);
                    sfit = polyval(P,mfit);

                    % Output
                    fprintf(fid,'%s,%4.0f,%6.0f,%6.2f,%6.2f,%6.2f,%6.2f,%6.0f,%s\n',...
                        cell2mat(currentGage),yrs(j),currentMo,...
                        mean(s,'omitnan'),std(s,'omitnan'),...
                        mean(m,'omitnan'),std(m,'omitnan'),length(s),R);

                    % Plot : COMMENTED OUT
                    %figure(1);clf
                    %plot(m,s,'o');hold on
                    %xlabel('Measured (cfs)')
                    %ylabel('Simulated (cfs)')
                    %titleStr = ['Gage ',cell2mat(currentGage),': Year ',num2str(yrs(j)),': Month ',num2str(currentMo),': Correlation ',num2str(R)];
                    %titleStr = strrep(titleStr,'_','-');
                    %title(titleStr);
                    %plot(mfit,sfit,'k--');
                    %printStr = ['MeasuredAndSimulated_Plots',filesep,cell2mat(currentGage),'_Year',num2str(yrs(j)),'_Month',num2str(currentMo),'_measVsim'];
                    %eval(['print ',printStr,' -dpng'])
                end

            end
        end
    end
end
warning on;
fclose(fid);
figure(1);close;
    
