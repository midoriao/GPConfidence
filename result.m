function result(folder)
    files = dir(folder);
    cov = [];
    lowRob = [];
    time = [];
    fns = {};
    for f = files
        fns{end + 1} = f;
        tic;
        ps = Parser(f);
        lowRob = [lowRob; ps.lowRob];
        
        g = GPRwrapper(ps.gpr, 1000, 10, ps.ranges, ps.trainX);
        cov_ = g.mvn.appro_mvncdf();
        cov = [cov; cov_];
        
        tc = toc;
        time = [time;tc];
    end
    res = table(fns', cov, lowRob, time);
    writetable(res,'results/folder','Delimiter',';');
end