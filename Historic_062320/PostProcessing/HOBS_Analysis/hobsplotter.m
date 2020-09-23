function hobsplotter(inwell,inyr)

load HobsData.mat

% Name;
c        = find(strcmp(inwell,commonWell));
pname    = cell2mat(commonName(c));
titleStr = [inwell,': ',pname];

% WEll DATA (all)
a     = find(strcmp(well_seq,inwell));
wobs  = obs(a);
wsim  = sim(a);
wdnum = dnum(a);
    
% Specific Year
if isnumeric(inyr)
    
    % Data for the selected year
    tstart = datenum(inyr,1,1);
    tstop  = datenum(inyr,12,31);
    b      = find(wdnum>=tstart & wdnum<=tstop);
    
    % Data to plot
    pobs   = wobs(b);
    psim   = wsim(b);
    ptim   = wdnum(b);
    delta  = abs(pobs-psim);
    
    % Output Filename
    outName = [inwell,'_',pname,'_',int2str(inyr)];
else
    % Data to plot
    pobs   = wobs;
    psim   = wsim;
    ptim   = wdnum;
    delta  = abs(pobs-psim);
    
    % Output Filename    
    outName = [inwell,'_',pname,'_All'];
    
end

% Correlation Coefficient
[r,~] = corrcoef(pobs,delta);
[~,ncols] = size(r);
if ncols>1
    r     = r(1,2);
end
r = abs(r);

% Plot
figure(1);clf
subplot(211);
plot(ptim,psim,'b-o');
hold on
plot(ptim,pobs,'k-o','markerfacecolor','g')
%xlabel('time')
ylabel('Head (m)')
datetick('x',12);
legend('simulated','observed')
title(titleStr)

subplot(212)
plot(pobs,delta,'ko')
xlabel('Observation Head (m)')
ylabel('Abs (Obs-Sim) Head (m)')
title(sprintf('n = %3.0f  Correlation = %1.4f',length(pobs),r));

% Print it
a = find(isspace(outName));
if ~isempty(a)
    outName(a)='_';
end
disp([' printing ',outName])
eval(['print HobsPlots/',outName,' -dpsc'])
    
    
    