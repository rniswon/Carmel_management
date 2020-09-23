
fid = fopen('hobsplotter_Wells2Plot.csv','r');
line = fgetl(fid);

i=1;
while i>0
    line = fgetl(fid);
    if line == -1
        fclose(fid);
        i=0;
        break
    else
        a = strfind(line,',');
        well = line(1:a(1)-1);
        year = line(a(2)+1:a(3)-1);
        
        foo = str2num(year);
        if ~isempty(foo)
            hobsplotter(well,foo)
        else
            hobsplotter(well,'all')
        end
    end
end
fclose all;

