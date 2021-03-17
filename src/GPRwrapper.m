classdef GPRwrapper < handle
    
    properties
        gpr
        mvn
        
        N
        K
        %maxSize
        
        range
        
        trainX
    end
    
    methods
        function this = GPRwrapper(gpr, n, k,  range, trainX)
            
            
            
            this.gpr = gpr;
            this.N = n;
            this.K = k;
            %this.maxSize = ms;
            
            this.range = range;
            this.trainX = trainX;
                       
            this.getMVN();
        end
        
        function getMVN(this)
            
            %obtain the x that's included in
            
            Kappa = 1.96;
            AFcn = @(X)bayesoptim.lowerConfidenceBound(X, this.gpr, Kappa);
            %XBest = iFminbndGlobal(@constraintWeightedNegAF, VarSpec.LBTrans, ...
                   % VarSpec.UBTrans, this.PrivOptions.NumRestartCandidates, ...
                 %   this.PrivOptions.NumRestarts, this.PrivOptions.VerboseRestarts, ...
              %      this.PrivOptions.MaxIterPerRestart, this.PrivOptions.RelTol);
            
            
            %[x0, fvals] = iMinKPointsFromN(fcn, LB, UB, NumCandidates, BestK);
            LBt = this.range(:,1)';
            UBt = this.range(:,2)';
            
            %randomly generate N numbers
            %Unifs = rand(this.N, size(LBt,2));
            %X = Unifs .* repmat(UBt - LBt, this.N, 1);
            %X = X + repmat(LBt, this.N, 1);
            X = rand(this.N, size(LBt,2));
            
            %select the best K ones.
            fvals = fcn(X);
            [~, rows] = sort(fvals, 'ascend');
            X = X(rows(1:this.K), :);
            fvals = fvals(rows(1:this.K));
            
            
            %do local search for each remained X
            sizeX = numel(fvals);
            for row = sizeX:-1:1
                [xs(row,:), fvals(row)] = fminsearch(@boundedFcn, X(row,:), ...
                    optimset(...
                    'MaxIter', 500, ...
                    'TolX', Inf, ...
                    'TolFun', 1.0000e-03));
            end
            
            
            
            %remove X if X's lower bound is above 0
            %sizeXS = numel(fvals);
            %for ro = sizeXS:-1:1
            %    if fvals(ro) >= 0
            %        xs(ro,:) = [];
            %        fvals(ro) = [];
            %    end
            %end
            %for ro = this.K:-1:1
            %    if fvals >= 0
            %        X = X(rows(1:ro),:);
            %        fvals = fvals(rows(1:ro));
            %    end   
            %end
            
            %remove duplication
            xx = unique(xs,'rows');

            function y = fcn(x)
                y = -AFcn(x);
            end
            
            function y = boundedFcn(x)
                if any(x < LBt | x > UBt)
                    y = Inf;
                else
                    y = fcn(x);
                end
            end
            
            Xtest = xx;
            [ypred] = predict(this.gpr, Xtest);
            
            %compute covariance matrix
            
            %covariance function 
            kf = this.gpr.Impl.Kernel.makeKernelAsFunctionOfXNXM(this.gpr.Impl.ThetaHat);
            %covariance matrix
            CM = kf(Xtest, Xtest) - kf(Xtest, this.trainX)*(kf(this.trainX, this.trainX)^-1)*kf(this.trainX, Xtest);
            CMM = round(CM, 2);
            %instantiate MVN
            this.mvn = MVN(ypred', CMM);
         
            
        end
        
        
    end
    
end