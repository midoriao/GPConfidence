classdef MVN< handle
    properties
        
        num %number of samples
        mu
        sigma
        
    end
    
    methods
        function this = MVN(mu, sigma)
            this.mu = mu;
            this.sigma = sigma;
            
            this.num = numel(mu);
            
        end
        
        function prob =  appro_mvncdf(this)
            
            Xl = zeros(1, this.num);
            Xu = Inf*ones(1, this.num);
            this.sigma = round(this.sigma,2);
            this.sigma
            issymmetric(this.sigma)
            eig(this.sigma)
            
            %prob = 1- mvncdf(Xl,Xu,this.mu,this.sigma)
            res  = newMvncdf(Xl-this.mu, Xu -this.mu,  this.sigma,100)
            prob = 1- res.prob
            
        end
        
    end
end