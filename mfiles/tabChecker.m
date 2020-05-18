
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
