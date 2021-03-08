function [x_log, obj_log] = randomSample(br, budget, phi, cp, tspan, input_name, input_range)
    


   % InitBreach;

   % mdl = 'Autotrans_shift';
   % Br = BreachSimulinkSystem(mdl);

    br.Sys.tspan = tspan;

    input_gen.type = 'UniStep';
    %input_gen.cp = input('\n Please input control points\n');
    input_gen.cp = cp;
    br.SetInputGen(input_gen);


    rng('default')
    rng('shuffle')
    

    


    %num_sim = input('\n Please input the number of simulations: \n');

    %log = [];
    x_log = [];
    obj_log = [];

    while true
        
        t_x_log = [];
        t_obj_log = [];
        for i = 1: budget

    %        x1 = (r1(2)-r1(1))*rand + r1(1);
    %        x2 = (r2(2)-r2(1))*rand + r2(1);
            x_list = [];
            [dim, ~] = size(input_range);
            for j = 1:dim
                for h = 1:cp
                    x_temp = (input_range(j, 2) - input_range(j, 1))*rand + input_range(j, 1);
                    x_list = [x_list x_temp];
                end
            end


            for cpi = 1:cp
                for j = 1:dim
                    br.SetParam({strcat(input_name(j),'_u',num2str(cpi-1))}, x_list((j-1)*cp + cpi))
                end
            end


            t_x_log = [t_x_log x_list'];


            br.Sim(0:.01:30);
            obj = br.CheckSpec(phi);
            if obj < 0
                break;
            end
            
            t_obj_log = [t_obj_log obj];

        end
        if numel(obj_log) < budget
            continue;
        else
            x_log = t_x_log;
            obj_log = t_obj_log;
            break;
        end
        
        
    end

    %save('test.mat', 'falsif_pb');
    %object = min(falsif_pb.obj_log);
end