function fixWelFile(in)

fido = fopen('temp.txt','w');

fid = fopen(in,'r');

load TabFileIDs.mat
ID = double(ID);

% Read the wel file
for i=1:10
    line = fgetl(fid);
    fprintf(fido,'%s\n',line');
end

% Loop
i=1;
while i>0
    line = fgetl(fid);
    if line == -1
        fclose(fid);
        i=0;
        break
    else
        line = str2num(line);
        idIn = line(1);
        
        % Find corresponding ID
        a = find(ID==idIn);
        fn = cell2mat(TabFile(a));
        fn = strrep(fn,'.\INPUT\modflow\','');
        fn = strrep(fn,'\','/');
        
        if ~exist(fn,'file')
            disp(['error reading ',fn])
        else
            % Scan it in
            fidi = fopen(fn,'r');
            C = textscan(fidi,'%d %d','headerlines',6);
            num = length(C{1});
            
            % Write it
            fprintf(fido,'%6.0f %6.0f %4.0f %4.0f %4.0f\n',...
                line(1),num,line(3),line(4),line(5));
        end
    end
end

        
        
            
            
        
        
        

        
    
