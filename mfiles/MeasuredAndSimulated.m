function MeasuredAndSimulated
% 
% Load Streamflow_MeasuredAndSimulated (originally xlsx)
load Streamflow_MeasuredAndSimulated.mat

%gages = {'H1' 'BLP' 'ALP' 'Los_Padres_Res' 'DJ' 'NC' 'RR' 'SH'};
gages = {'ALP' 'BL' 'CA' 'CL' 'DJ' 'GA' 'GC' 'H1' 'HI' 'Los_Padres_Res' 'LP' 'NC' 'PI' 'PO' 'RC' 'RR' 'SH' 'TU'};


mos = [10 11 12 1 2 3 4 5 6 7 8 9];

yrs = 1992:1:2015;

if ~exist('MeasuredAndSimulated_BarPlots','dir')
    mkdir('MeasuredAndSimulated_BarPlots');
end

    
% Loop through each Gage 
for g = 1:length(gages)
    
    % Figure for this gage
    figure(1);clf;orient tall;
    
    % Put current Gage in G
    currentGage = gages(g);
    eval(['G=',cell2mat(currentGage),';'])
    
    % Data
    %y = G.year;
    %m = G.month;
    %d = G.day;
    [y,m,d] = datevec(G.matching_time);
    sim  = G.matching_simulated_cfs;
    meas = G.matching_measured_cfs;
    time = datenum(y,m,d);
    
    % Initialize
    SIM  = [];
    MEAS = [];
    YR   = [];
    
    % Loop through each Year
    for i=1:length(yrs)
        % Make this the current WATER year
        currentYear = yrs(i);
        WY_start = datenum(currentYear-1,10,1);
        WY_stop  = datenum(currentYear,09,30);
        
        a = find(time>=WY_start & time<=WY_stop);
        
        % Values are in cfs. Convert to af/y (1cfs = 724 af/y)
        if ~isempty(a)
            
            % CFS to AF/day
            afsim  = sim(a)*1.983;
            afmeas = meas(a)*1.983;
            
            SIM(i)  = sum(afsim); 
            MEAS(i) = sum(afmeas);
            
            %SIM(i)  = sum(sim(a))*724/365;
            %MEAS(i) = sum(meas(a))*724/365;
        else
            SIM(i)  = NaN;
            MEAS(i) = NaN;
        end
        YR(i) = currentYear;
    end
    
    % Assign to structure as cfs and af
    eval([cell2mat(currentGage),'_Yearly.Year = YR;'])
    eval([cell2mat(currentGage),'_Yearly.MEASaf = MEAS;'])
    eval([cell2mat(currentGage),'_Yearly.SIMCaf  = SIM;'])
    
    
    % Add to plot
    subplot(211);
    bar(YR,[SIM' MEAS'])
    legend('Simulated','Measured')
    xlabel('Water Year')
    ylabel('Total AF')
    title(strrep(cell2mat(currentGage),'_','-'));
    
    % Initialize
    SIM  = [];
    MEAS = [];
    MO   = [];
    
    % Loop through each Month
    for i=1:length(mos)
        currentMos = mos(i);
        
        % Values are in cfs. Convert to af/yr (1 cfs = 724 af/y)
        a = find(m==currentMos);
        if ~isempty(a)
            
             % CFS to AF/day
            afsim  = sim(a)*1.983;
            afmeas = meas(a)*1.983;
            
            SIM(i)  = sum(afsim); 
            MEAS(i) = sum(afmeas);
            
            %SIM(i)  = sum(sim(a))*724;
            %MEAS(i) = sum(meas(a))*724;
        else
            SIM(i)  = NaN;
            MEAS(i) = NaN;
        end
        MO(i) = currentMos;
    end
    X=-2:1:9;
    
    % Assign to structure
    eval([cell2mat(currentGage),'_Monthly.Month = MO;'])
    eval([cell2mat(currentGage),'_Monthly.Measaf = MEAS;'])
    eval([cell2mat(currentGage),'_Monthly.SIMCaf  = SIM;'])
    
    % Add to plot
    subplot(212);
    bar(X,[SIM' MEAS'])
    legend('Simulated','Measured')
    xlabel('Month')
    ylabel('Total AF')
    set(gca,'XTickLabel',mos);
    
    % Print
    eval(['print MeasuredAndSimulated_BarPlots',filesep,cell2mat(currentGage),'_MeasSim -dpng'])
    pause(1);
end

            
            
            
        

    
    

    

