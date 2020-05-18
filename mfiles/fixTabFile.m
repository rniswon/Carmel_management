function fixTabFile(in)
disp([' working on ',in,'...'])

fid = fopen(in,'r');
if fid<0
    disp(['unable to open : ',in])
    return
end
fido = fopen('temp.txt','w');
firstTime = 1;

i=1;
while i>0
    line = fgetl(fid);
    l = line;
    if line == -1
        fclose(fid);
        break
    else
        if strcmp(line(1),'#')
            fprintf(fido,'%s\n',line);
        else
            line = str2num(line);
            if isempty(line)
                fclose(fid);
                break
            else               
                dy  = line(1);
                val = line(2);
                if firstTime
                    fprintf(fido,'%6.0f %8.5f\n',(dy),(val));
                    dym  = dy;
                    valm = val;
                    firstTime=0;
                elseif dym+1==dy
                    fprintf(fido,'%6.0f %8.5f\n',(dy),(val));
                    disp([' no pumping Days ',int2str(dy),'to ',int2str(dym)])
                    dym  = dy;
                    valm = val;
                    
                else
                    dym = dy-1;

                    fprintf(fido,'%6.0f %8.5f\n',(dym),(valm));
                    fprintf(fido,'%6.0f %8.5f\n',(dy),(val));
                    valm = val;
                end
            end
        end
    end
    i=i+1;
end
fclose(fido);
copyfile('temp.txt',in);
delete('temp.txt');

