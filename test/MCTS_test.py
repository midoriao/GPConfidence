import sys
import os
import time

model = ''
algorithm = '' 
optimization = []
phi_str = []
controlpoints = ''
scalar = []
partitions = []
T_playout = []
N_max = []
input_name = []
input_range = []

status = 0
arg = ''
linenum = 0
timespan = ''
parameters = []
T = ''
loadfile = ''
addpath = []

argument = ''
label = ''

trials = ''
#fal_home = os.environ['FALHOME']
#br_home = os.environ['BRHOME']

with open('./'+sys.argv[1],'r') as conf:
	for line in conf.readlines():
		argu = line.strip().split()
		if status == 0:
			status = 1
			arg = argu[0]
			linenum = int(argu[1])
		elif status == 1:
			linenum = linenum - 1
			if arg == 'model':
				model = argu[0]

			elif arg == 'optimization':
				optimization.append(argu[0])
			elif arg == 'phi':
				complete_phi = argu[0]+';'+argu[1]
				for a in argu[2:]:
					complete_phi = complete_phi + ' '+ a
				phi_str.append(complete_phi)
			elif arg == 'controlpoints':
				controlpoints = argu[0]
			elif arg == 'scalar':
				scalar.append(float(argu[0]))
			elif arg == 'partitions':
				partitions.append(map(int,argu))
			elif arg == 'T_playout':
				T_playout.append(int(argu[0]))
			elif arg == 'N_max':
				N_max.append(int(argu[0]))
			elif arg == 'input_name':
				input_name.append(argu[0])
			elif arg == 'input_range':
				input_range.append([float(argu[0]),float(argu[1])])
			elif arg == 'algorithm':
				algorithm = argu[0]
			elif arg == 'timespan':
				timespan = argu[0]
			elif arg == 'parameters':
				parameters.append(argu[0])
			elif arg == 'T':
				T = argu[0]
			elif arg == 'loadfile':
				loadfile = argu[0]
			elif arg == 'addpath':
				addpath.append(argu[0])
			elif arg == 'arg':
				argument = argu[0]
			elif arg == 'trials':
				trials = argu[0]
			elif arg == 'label':
				label = argu[0]
			else:
				continue
			if linenum == 0:
				status = 0

dirname = model + '_' + label
fullfn = '../log/' + dirname
if not os.path.exists(fullfn):
	os.mkdir(fullfn)

print partitions
for ph in phi_str:
	for cp in controlpoints:
		for c in scalar:
			for par in partitions:
				for nm in N_max:
					for opt in optimization:
						for tp in T_playout:
							property = ph.split(';')
							ts = time.strftime('%Y%m%d%H%M%S',time.localtime(time.time()))
							par_str = '_'.join(str(i) for i in par)
							filename = model + '_' + 'mcts' + '_'+property[0]+'_' + str(cp)  +'_'+str(nm)+ '_' + str(tp) + '_' + opt
							param = '\n'.join(parameters)
							with open('benchmarks/'+filename,'w') as bm:
								bm.write('#!/bin/sh\n')
								bm.write('csv=$1\n')
								bm.write('matlab -nodesktop -nosplash <<EOF\n')
								bm.write('clear;\n')
								for ap in addpath:
									bm.write('addpath(genpath(\'' + ap + '\'));\n')
								bm.write('addpath(genpath(\'' + '.' + '\'));\n')
								if loadfile!='':
									bm.write('load '+loadfile + '\n')
								bm.write('InitBreach;\n\n')
								bm.write(param+ '\n')
								bm.write('mdl = \''+ model + '\';\n')
								bm.write('Br = BreachSimulinkSystem(mdl);\n')
								bm.write('br = Br.copy();\n')
   								bm.write('N_max =' + str(nm)  + ';\n')
								bm.write('scalar = '+ str(c) +';\n')
								bm.write('phi_str = \''+ property[1] +'\';\n')
								bm.write('phi = STL_Formula(\'phi1\',phi_str);\n') 
								bm.write('T = ' + T + ';\n')
								bm.write('controlpoints = '+ str(cp)+ ';\n')
 								bm.write('hill_climbing_by = \''+ opt+'\';\n')
								bm.write('T_playout = '+str(tp)+';\n')
								bm.write('input_name = {\''+input_name[0]+'\'')
								for inm in input_name[1:]:
									bm.write(',\'')
									bm.write(inm)
									bm.write('\'')
								bm.write('};\n')
								bm.write('input_range = [['+ str(input_range[0][0])+' '+str(input_range[0][1])+']')
								for ir in input_range[1:]:
									bm.write(';[')
									bm.write(str(ir[0])+' '+str(ir[1]))
									bm.write(']')
								bm.write('];\n')
								bm.write('partitions = ['+ str(par[0]))
								for p in par[1:]:
									bm.write(' ')
									bm.write(str(p))
								bm.write('];\n')

								bm.write('filename = \''+filename+'\';\n')
								bm.write('algorithm = \''+algorithm+ '\';\n')
								bm.write('falsified_at_all = [];\n')
								bm.write('min_rob = [];\n')
								bm.write('coverage = [];\n')
								bm.write('time_cov = [];\n')

								bm.write('trials =' + trials +';\n')
								bm.write('for i = 1:trials\n')
								bm.write('\tm = MCTS(br,N_max, scalar, phi, T, controlpoints, hill_climbing_by, T_playout, input_name, input_range, partitions);\n')
								bm.write('\tlogs = m.log;\n')
								bm.write('\tvars = m.vars;\n')
								bm.write('\tranges = m.ranges;\n')

								bm.write('\tlogname = strcat(\'log/' + dirname + '/\', \''  + filename + '\',\'_\', int2str(N_max) , \'_\', int2str(i) , \'_\', \'' + ts + '.mat\');\n')
								bm.write('\tsave(logname,  \'logs\', \'vars\', \'ranges\');\n')

								bm.write('end\n')
								bm.write('quit force\n')
								bm.write('EOF\n')
