
SimDays = 0:1:9000;
SimVals = zeros(size(SimDays));

SimDays = SimDays';
SimVals = SimVals';

D=dir('Well*.tab');
for i=1:length(D)
    fn = D(i).name;
    %disp([' working on ',fn])
    
    % Scan in the file
    fid = fopen(fn,'r');
    C = textscan(fid,'%f %f','headerlines',6);
    fclose(fid);
    
    day = C{1};
    val = C{2};
    
    a = find(unique(day));
    if length(a)~= length(day)
        disp([fn,' Length mismatch by ',int2str(length(day)-length(a)),' day'])
    end
        
   
    
end

    foo = [day val];
    foo = sortrows(foo,1);
    
    day = foo(:,1);
    val = foo(:,2);
    
    a = find(unique(day));
    day = day(a);
    val = val(a);
    
    foo = [day val];
    foo = sortrows(foo,1);
    
    day = foo(:,1);
    val = foo(:,2)
    
    dayint = min(day):1:max(day);
    valint = interp1(day,val,dayint);
    
    dayint = dayint';
    valint = valint';
    
    SimVals(1:length(valint))=SimVals(1:length(valint))+valint;


    
    

