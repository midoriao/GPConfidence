classdef Parser < handle
    
    properties
        filename
        gpr
        
        vars 
        ranges
        
        lowRob
        trainX
    end
    
    methods
        function this = Parser(filename, num)
            this.filename = filename;
            load(filename, 'logs');
            load(filename, 'vars');
            load(filename, 'ranges');
            
            this.vars = vars;
            this.ranges = ranges;
            
            xd = logs.X_log(:, 1:num)';
            this.trainX = xd;
            yd = logs.obj_log(1:num)';
            
            this.lowRob = min(yd);
            
            this.gpr = fitrgp(xd,yd,'KernelFunction','squaredexponential', 'Optimizer', 'fmincon', 'sigma',0.01,'verbose',1);
            
        end
        
        
    end
    
end
