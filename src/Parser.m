classdef Parser < handle
    
    properties
        filename
        gpr
        
        trainX
    end
    
    methods
        function this = Parser(filename)
            this.filename = filename;
            load(filename, 'x_log');
            load(filename, 'obj_log');
            xd = x_log';
            this.trainX = xd;
            yd = obj_log';
            this.gpr = fitrgp(xd,yd,'KernelFunction','squaredexponential','sigma',0.1,'verbose',1);
            
        end
        
        
    end
    
end
