function TemplatesList = TemplateList_add(TemplatesList,T, W, prm)

% if the list is empty, insert the template (the first one)
if isempty(TemplatesList)
    TemplatesList=insertTemplate(TemplatesList,1,T,W,inf);        % The first template is never removed
    return;
end

% If we use only two templates, these are the first and the one lastly inserted
if prm.TwoTemplates
      TemplatesList=insertTemplate(TemplatesList,2,T,W,inf);        % The first template is never removed
    return;
end

% if pr.MinScoreToEnter==inf, no further templates are allowed
if isinf(prm.MinScoreToEnter)
    return;
end

% Compute score ofr the new template
MinDist=inf;
for i=1:length(TemplatesList)
    
    % resize the template to the size of the previous one
    Ts=imresize(T,size(TemplatesList{i}));
    Ws=imresize(Q.wT,size(TemplatesList{i}));
    OldT=TemplatesList{i}.T;
    OldW=TemplatesList{i}.W;
    % rescale the intesity range
    [ T , OldT ]= rescale_TandI(T,OldT,prm.TotalSTD);
    dist(i) = OldW.*Ws*(OldT-Ts).^2;
end
Score=min(dist);

% Consider entering the new template to the list
if Score>prm.MinScoreToEnter    % If the score is low, do not add the template
    if length(TemplatesList)<prm.MaxTemplates   % if we have room for templates, add the new one
        TemplatesList=insertTemplate(TemplatesList,length(TemplatesList)+1,T,W,Score);   
        return;
    else    % add the template only if there is one with a lower score
        PrevScores=[ TemplatesList.Score ];
        [mn, minind]=min(PrevScores);
        if Score>mn
             TemplatesList=insertTemplate(TemplatesList,minind,T,W,Score);   
        end
    end
end

 %% 
 function TemplatesList=insertTemplate(TemplatesList,index,T,W,Score)
 TemplatesList(index).T=T;
 TemplatesList(index).W=W;
 TemplatesList(index).Score=Score; % The first template is never removed
        
        
 

    
    


