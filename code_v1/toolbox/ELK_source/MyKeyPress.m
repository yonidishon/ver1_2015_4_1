function MyKeyPress(stat,evnt)
global ESC;

switch evnt.Key
    case 'escape' % Escape
        ESC = true;
end