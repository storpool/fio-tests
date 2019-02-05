#!/usr/bin/env python
import argparse
import fnmatch
import os

def extvalues(f):
    '''f: path to filename
    returns tuple of two lists with time/value series'''
    time = []
    value = []
    with open(f) as fs:
        for l in fs.readlines():
            s = l.split(',')
            time.append(s[0])
            value.append(s[1])
    if len(time) != len(value):
        exit('Parsing failed')
    return time, value

def genp(f, ylabel, showplot = False):
    '''
    f: list with strings - paths to filenames to plot
    ylabel: str - name of y absis label
    returns None
    if showplot is True opens a plot for observation, otherwise saves a png'''
    import matplotlib.pyplot as plt
    if len(f) > 1:
        # extract just the names of the directories, e.g.:
        # [ './res/pm863a/sustain_4k_iops_iops.1.log', ./res/hp/sustain_4k_iops_iops.1.log' ]
        # results in:
        # [ 'pm863a', 'hp' ]
        name = '_'.join([ os.path.basename(os.path.dirname(i)) for i in f])
        name += '_' + ylabel
    elif len(f) == 1:
        name = f[0]
    else:
        print "no files to plot"
        return
    if not showplot:
        plt.clf()
    plt.figure(0)
    plt.title(name)
    plt.xlabel('Time (ms)')
    plt.ylabel(ylabel)
    for el in f:
        x, y = extvalues(el)
        plt.plot(x, y)
    if showplot:
        plt.show()
        return
    img = name + '.png'
    plt.savefig(img)
    print 'Success generating {i}'.format(i = img)

def ffind(glob, directory):
    '''name: str glob to search for in the present directory
    returns all matching files in a list'''
    matches = []
    for root, _, filenames in os.walk(directory):
        for filename in fnmatch.filter(filenames, glob):
            matches.append(os.path.join(root, filename))
    if len(matches) == 0:
        print 'No files found with the {m} glob'.format(m = glob)
    return matches

if __name__ == '__main__':
    if "DISPLAY" not in os.environ.keys():
        exit("Please connect with X forwarding enabled (-X or -Y)")
    try:
        parser = argparse.ArgumentParser(description='''
        Generates plot images for each *_iops.*log and each *_lat.*log fio log file''')
        parser.add_argument('-s', '--showplot', help="Show plots instead of saving the images", action = 'store_true')
        parser.add_argument('directory', nargs = '?', help="Search for log files in this directory instead of the present", default = './')
        parser.add_argument('-c', '--compare', help="Show all logs of a type in a single plot/image", action = 'store_true')
        args = parser.parse_args()
        iopssource = ffind('*_iops*log', args.directory)
        latsource = ffind('*_lat.*log', args.directory)
        if args.compare:
            genp(iopssource, 'IOPS', args.showplot)
            genp(latsource, 'us', args.showplot)
        else:
            for filesource in iopssource:
                genp([filesource], 'IOPS', args.showplot)
            for filesource in latsource:
                genp([filesource], 'us', args.showplot)
    except KeyboardInterrupt as e:
        exit('KeyboardInterrupt detected, exiting')
    except Exception as e:
        raise
