%br, budget, phi, cp, tspan, input_name, input_range, solver
function [logs, vars, ranges] = breachSampling(br, budget, phi, cp, tspan, input_name, input_range, solver)

    br.Sys.tspan = tspan;

    input_gen.type = 'UniStep';
    input_gen.cp = cp;
    br.SetInputGen(input_gen);
    
    dim = numel(input_name);
    
    for i = 1:cp
        for j = 1:dim
            br.SetParamRanges({strcat(input_name(j),'_u',num2str(i-1))}, input_range(j, :));
            
        end
    end

    logs = [];
    logs.X_log = [];
    logs.obj_log = [];
    
    rem_budget = budget;
    while true
    	falsif_pb = FalsificationProblem(br, phi);
    	falsif_pb.max_time = Inf;
    	falsif_pb.max_obj_eval = rem_budget;
		
        if contains(solver, '_')
            s = split(solver, '_');
            falsif_pb.setup_solver(s{1});
            falsif_pb.solver_options.PopSize = str2num(s{2});
        else
            falsif_pb.setup_solver(solver);
        end

        falsif_pb.solve();
        if min(falsif_pb.obj_log) > 0  %&& numel(falsif_pb.obj_log) >= budget
            logs.X_log = [logs.X_log falsif_pb.X_log];
            logs.obj_log = [logs.obj_log falsif_pb.obj_log];
        else
            continue;
        end
        
        if numel(falsif_pb.obj_log) >= rem_budget
            break;
        else
            rem_budget = rem_budget - numel(falsif_pb.obj_log);
        end
        
    end


    vars = br.GetSysVariables();
    ranges = br.GetParamRanges(vars);

end
