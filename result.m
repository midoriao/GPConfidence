function result(folder)
    addpath('src/')
    %files = dir(strcat(folder, '/*.mat'));
    files_struct = dir(strcat(folder, '/*.mat'));
    files = {};
    nfs = numel(files_struct);
    for i = 1:nfs
        files{end + 1} = files_struct(i).name;
    end
    
    num = 2000;
    
    cov = [];
    lowRob = [];
    time = [];
    fns = {};
    spec = {};
    for f = files
        if contains(f{1}, 'gpr')
            continue
        end
        f{1}
        fns{end + 1} = f;
        tic;
        ps = Parser(strcat(folder, '/', f{1}), num);
        lowRob = [lowRob; ps.lowRob];
        
        g = GPRwrapper(ps.gpr, 10000, 20, ps.ranges, ps.trainX);
        cov_ = g.getMVN();
        cov = [cov; cov_];
        
        spec{end + 1} = ps.spec;
        
        tc = toc;
        time = [time;tc];
    end
    res = table(fns', spec', cov, lowRob, time);
    res_name = split(folder, '/');
    writetable(res, strcat('results/', res_name{2}, '.csv'),'Delimiter',';');
end