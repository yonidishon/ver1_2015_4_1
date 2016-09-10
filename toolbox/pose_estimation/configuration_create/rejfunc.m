function rejfunc(mystring)
global stat
if strcmp(mystring,'rej')
    stat = 1;
else
    stat = 0;
end
uiresume(gcbf)
end
