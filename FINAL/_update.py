# allocativ 3001.2021.0002

## Update allocativ repo with edits in local repo
os.popen('cp ' + local + subject + '_setup.py ' + path + '_dev_allocativ/_setup.py')
os.popen('cp ' + local + subject + '_setup.r ' + path + '_dev_allocativ/_setup.r')
os.popen('cp ' + local + subject + '_public.py ' + path + '_dev_allocativ/hnb_2021/_public.py')
os.popen('cp ' + local + subject + '_spatial.r ' + path + '_dev_allocativ/hnb_2021/_spatial.r')
os.popen('cp ' + local + subject + '_learn.py ' + path + '_dev_allocativ/fp_3001/_learn.py')
os.popen('cp ' + local + subject + '_maps.r ' + path + '_dev_allocativ/fp_3001/_maps.r')
os.popen('cp ' + local + subject + '_model.py ' + path + '_dev_allocativ/fp_3001/_model.py')
os.popen('cp ' + local + subject + '_stats.r ' + path + '_dev_allocativ/hnb_2021/_stats.r')
os.popen('cp ' + local + subject + day + 'summary.txt ' + local + subject + day + 'summary.md')