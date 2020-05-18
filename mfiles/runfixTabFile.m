function runfixTabFile

D=dir('*.tab');

for i=1:length(D)
    fn = D(i).name;
    fixTabFile(fn);
end

    