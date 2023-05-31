import sys
import time
import os
from os import path

model = ''
algorithm = '' 
optimization = []
phi_str = []
controlpoints = []
input_name = []
input_range = []
parameters = []
numsim = []
timespan = ''
loadfile = ''
label = ''

status = 0
arg = ''
linenum = 0

algopath = ''
trials = ''
timeout = ''
max_sim = ''
addpath = []

with open(sys.argv[1],'r') as conf:
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
				controlpoints.append(int(argu[0]))
			elif arg == 'input_name':
				input_name.append(argu[0])
			elif arg == 'input_range':
				input_range.append([float(argu[0]),float(argu[1])])
			elif arg == 'parameters':
				parameters.append(argu[0])	
			elif arg == 'timespan':
				timespan = argu[0]
			elif arg == 'trials':
				trials = argu[0]
		#	elif arg == 'timeout':
		#		timeout = argu[0]
			elif arg == 'max_sim':
				max_sim  = argu[0]
			elif arg == 'numsim':
				numsim.append(int(argu[0]))
			elif arg == 'addpath':
				addpath.append(argu[0])
			elif arg == 'loadfile':
				loadfile = argu[0]
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

for ph in phi_str:
	for cp in controlpoints:
		for opt in optimization:
			property = ph.split(';')
			ts = time.strftime('%Y%m%d%H%M%S',time.localtime(time.time()))
			filename = model+  '_' + property[0] + '_' + str(cp)  +'_' + opt + '_' + str(max_sim)

			param = '\n'.join(parameters)
			with open('benchmarks/'+filename,'w') as bm:
				bm.write('#!/bin/sh\n')
				bm.write('csv=$1\n')
				bm.write('matlab -nodesktop -nosplash <<EOF\n')
				bm.write('clear;\n')
				for ap in addpath:
					bm.write('addpath(genpath(\'' + ap + '\'));\n')
				if loadfile!= '':
					bm.write('load ' + loadfile + '\n')
				bm.write('InitBreach;\n\n')
				bm.write(param + '\n')
				bm.write('mdl = \''+ model + '\';\n')
				bm.write('Br = BreachSimulinkSystem(mdl);\n')
				bm.write('br = Br.copy();\n')
				bm.write('budget = ' + max_sim + ';\n')
				if len(numsim)!=0:
					bm.write('numsim = [' + str(numsim[0]))
					for ns in numsim[1:]:
						bm.write(',')
						bm.write(str(ns))
					bm.write('];\n')

				bm.write('tspan ='+ timespan +';\n')
				bm.write('controlpoints = ' + str(cp) + ';\n')

				bm.write('spec = \''+ property[1]+'\';\n')
				bm.write('phi = STL_Formula(\'phi\',spec);\n')
				bm.write('input_name = {\'' + input_name[0] + '\'')
				for iname in input_name[1:]:
					bm.write(',')
					bm.write('\'' + iname + '\'')
				bm.write('};\n')

				bm.write('input_range = [[' + str(input_range[0][0]) + ' ' + str(input_range[0][1]) + ']')
				for ir in input_range[1:]:
					bm.write(';[' + str(ir[0]) + ' ' + str(ir[1]) + ']')
				bm.write('];\n')

				bm.write('solver = \'' + opt + '\';\n')
				bm.write('trials = ' + trials + ';\n')	
				#bm.write('filename = \''+filename+'\';\n')
				#bm.write('algorithm = ' + opt + ';\n')
		
				bm.write('for n = 1:trials\n')
				#bm.write('\t[logs, vars, ranges] = breachSampling(br, budget, phi, controlpoints, tspan, input_name, input_range, solver);\n')
				if opt == 'random':
					bm.write('\t[logs, vars, ranges] = randomSample(br, budget, phi, controlpoints, tspan, input_name, input_range);\n')
				else:
					bm.write('\t[logs, vars, ranges] = breachSampling(br, budget, phi, controlpoints, tspan, input_name, input_range, solver);\n')

				bm.write('\tif numel(logs.obj_log) ~= 0\n')
				if label == 'sim':
					bm.write('\t\ttlogs = logs;\n')
					bm.write('\t\tfor ns = numsim\n')
					bm.write('\t\t\tfilename = strcat(\'log/' + dirname + '/\', \''  + filename + '\',\'_\', int2str(ns) , \'_\', int2str(n) , \'_\', \'' + ts + '\');\n')
					bm.write('\t\t\tlogs.X_log = tlogs[:, 1:ns];\n')
					bm.write('\t\t\tlogs.obj_log = tlogs[1:ns];\n')
					bm.write('\t\t\tsave(filename, \'spec\', \'logs\', \'vars\', \'ranges\');\n')
					bm.write('\t\tend\n')
				else:
					bm.write('\t\tfilename = strcat(\'log/' + dirname + '/\', \''  + filename + '\',\'_\', int2str(budget) , \'_\', int2str(n) , \'_\', \'' + ts + '.mat\');\n')
					bm.write('\t\tsave(filename, \'logs\', \'vars\', \'ranges\', \'spec\');\n')
				bm.write('\tend\n')
				bm.write('end\n')
				
				bm.write('quit force\n')
				bm.write('EOF\n')
