%  Purpose:     give overall title to subplots
%  Input:
%   - title:    string with title name
%  Output:
%   - N/A

function subplotTitle(title)

axes('Position',[0,0.95,1,0.05])
set(gca,'Color','None','XColor','None','YColor','None')
text(0.5,0.25,title,'FontSize',14','FontWeight','Bold','HorizontalAlignment','Center','VerticalAlignment','Bottom')
