function setupMice
names = {'CNMtest', '0001'}
%names = {'wehrTest','3337'};
%names = {'test','j10lt','j10ln','j8lt','j8ln'};
%names = {'test','j10rt','j8rt','j7rt','j6rt'};

ratrixPath = 'C:\Users\nlab\Desktop\wehrData';
for i=1:length(names)
    standAloneRun(ratrixPath,'setProtocolCNM',names{i},[],[],true)
    %standAloneRun(ratrixPath,'setProtocolCNM',names{i},[],[],true)
end
end