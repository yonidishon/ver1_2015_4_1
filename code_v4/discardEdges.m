function result = discardEdges(map)
result=min(map(:)) .* ones(size(map));
result(5:(end-4),5:(end-4))=map(5:(end-4),5:(end-4));
end