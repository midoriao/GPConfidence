function [logs, vars, ranges] = randomSample(br, budget, phi, cp, tspan, input_name, input_range)
    br.Sys.tspan = tspan;

    input_gen.type = 'UniStep';
    input_gen.cp = cp;
    br.SetInputGen(input_gen);

    [dim, ~] = size(input_range);

    for i = 1:cp
        for j = 1:dim
            br.SetParamRanges({strcat(input_name(j),'_u',num2str(i-1))}, input_range(j, :));

        end
    end



    rng('default')
    rng('shuffle')
    
    logs = [];
    logs.X_log = [];
    logs.obj_log = [];

  %  for ii = 1:10
    %quit = false;
    %X_log_ = [];
    %obj_log_ = [];

    %for i = 1: budget
    vars = br.GetSysVariables();
    ranges = br.GetParamRanges(vars);
    while true

        x_list = [];
       % [dim, ~] = size(input_range);
        %for j = 1:dim
        %    for h = 1:cp
        %        x_temp = (input_range(j, 2) - input_range(j, 1))*rand + input_range(j, 1);
        %        x_list = [x_list x_temp];
        %    end
        %end
        
        %for cpi = 1:cp
        %    for j = 1:dim
        %        br.SetParam({strcat(input_name(j),'_u',num2str(cpi-1))}, x_list((j-1)*cp + cpi))
        %    end
        %end

	val = ranges(:, 1) + rand(cp*dim, 1).*(ranges(:, 2) - ranges(:,1))
	br.SetParam(vars, val);
	
        br.Sim(tspan);
        obj = br.CheckSpec(phi)

	if obj < 0
		continue;
	end

	%obj_log_ = [obj_log_ obj];
	logs.X_log = [logs.X_log val];
	logs.obj_log = [logs.obj_log obj];
	if numel(logs.obj_log) == budget
	    break;	
	end
    end
end
