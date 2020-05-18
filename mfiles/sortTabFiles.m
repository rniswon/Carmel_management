%D=dir('Well*.tab');
%for i=1:length(D)
    %fn = D(i).name;
    
    fn = 'Well_100184.tab';

    disp([' working on ',fn])
    
    % Scan in the file
    fid = fopen(fn,'r');
    C = textscan(fid,'%f %f','headerlines',6);
    fclose(fid);
    
    day = C{1};
    val = C{2};
    
    
    
    fido = fopen('temp.txt','w');
    fidi = fopen(fn,'r');
    for j=1:6
        line = fgetl(fidi);
        fprintf(fido,'%s\n',line);
    end
    fclose(fidi);
    
    
    for j=1:length(day)
        if j == 1
            fprintf(fido,'%8.0f %6.2f\n',day(j),val(j));
            pday = day(j);
            pval = val(j);
        else
            % Check current day
            if day(j)>pday     
                fprintf(fido,'%8.0f %6.2f\n',day(j),val(j));
                pday = day(j);
                pval = val(j);
            else
                if pval == val(j)
                    disp(['Non sequential DUPLICATE : pday = ',num2str(pday),' pval = ',num2str(pval),' : current day = ',num2str(day(j)),' current val = ',num2str(val(j)),' : skipping'])
                end
            end
        end
    end
    fclose(fido);

    % Now read in the temp file and fix non-sequentials
    fidi = fopen('temp.txt','r');
    fido = fopen('temp2.txt','w');
    
    % Header
    for j=1:6
        line = fgetl(fidi);
        fprintf(fido,'%s\n',line);
    end
    
    j=1;
    while j>0
        line = fgetl(fidi);
        if line == -1
            fclose(fidi);
            fclose(fido);
            j=0;
            break
        else
            line = str2num(line);
            if j==1
                fprintf(fido,'%8.0f %6.2f\n',line(1),line(2));
                prevday = line(1);
                prevval = line(2);
            else
                if line(1)-1 == prevday
                    % Sequential day, so value should change
                    fprintf(fido,'%8.0f %6.2f\n',line(1),line(2));
                    prevday = line(1);
                    prevval = line(2);
                else
                    % Non-Sequantial day, so value should be same as
                    % previous
                    fprintf(fido,'%8.0f %6.2f\n',line(1),prevval);
                    prevday = line(1);
                    prevval = line(2);
                end
            end
        end
    end
            
                
    
    
