
%br, budget, phi, cp, tspan, input_name, input_range, solver
function [x_log,obj_log] = breachSampling(br, budget, phi, cp, tspan, input_name, input_range, solver)

    %InitBreach;

    %mdl = 'Autotrans_shift';
    %Br = BreachSimulinkSystem(mdl);

    br.Sys.tspan = tspan;

    input_gen.type = 'UniStep';
    input_gen.cp = cp;
    br.SetInputGen(input_gen);
   


    %for cpi = 0:input_gen.cp-1
    %    throttle_sig = strcat('throttle_u', num2str(cpi));
    %    brake_sig = strcat('brake_u', num2str(cpi));
    %    Br.SetParamRanges({throttle_sig},[0 100]);
    %    Br.SetParamRanges({brake_sig},[0 325]);
    %end
    
    dim = numel(input_name);
   
    
    for i = 1:cp
        for j = 1:dim
            br.SetParamRanges({strcat(input_name(j),'_u',num2str(i-1))}, input_range(j, :));
            
        end
    end

    
    x_log = [];
    obj_log = [];
    
    while true

        falsif_pb = FalsificationProblem(br, phi);
        falsif_pb.max_time = Inf;
        falsif_pb.max_obj_eval = budget;
        falsif_pb.setup_solver(solver);
        falsif_pb.solve();
        if any(falsif_pb.obj_log<0)
            continue;
        else
            break;
        end
       
    end
    
    
    x_log = falsif_pb.X_log;
    obj_log = falsif_pb.obj_log;
    
    

    %save('test.mat', 'falsif_pb');



end
