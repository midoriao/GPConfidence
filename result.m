function result(folder)
    addpath('src/')
    %files = dir(strcat(folder, '/*.mat'));
    files_struct = dir(strcat(folder, '/*.mat'));
    files = {};
    nfs = numel(files_struct);
    for i = 1:nfs
        files{end + 1} = files_struct(i).name;
    end
    
    cov = [];
    lowRob = [];
    time = [];
    fns = {};
    for f = files
        fns{end + 1} = f;
        tic;
        ps = Parser(strcat(folder, '/', f{1}));
        lowRob = [lowRob; ps.lowRob];
        
        g = GPRwrapper(ps.gpr, 1000, 10, ps.ranges, ps.trainX);
        cov_ = g.mvn.appro_mvncdf();
        cov = [cov; cov_];
        
        tc = toc;
        time = [time;tc];
    end
    res = table(fns', cov, lowRob, time);
    res_name = split(folder, '/');
    writetable(res, strcat('results/', res_name{2}, '.csv'),'Delimiter',';');
end