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
        function this = Parser(filename)
            this.filename = filename;
            load(filename, 'logs');
            load(filename, 'vars');
            load(filename, 'ranges');
            
            this.vars = vars;
            this.ranges = ranges;
            
            xd = logs.x_log';
            this.trainX = xd;
            yd = logs.obj_log';
            
            this.lowRob = min(yd);
            
            this.gpr = fitrgp(xd,yd,'KernelFunction','squaredexponential','sigma',0.1,'verbose',1);
            
        end
        
        
    end
    
end
