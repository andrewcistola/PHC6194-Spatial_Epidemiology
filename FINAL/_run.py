# allocativ 3001.2021

## Copy allocativ to local repo
os.popen('cp ' + local + subject + '_local ' + local + subject + '_local.py')
os.popen('cp ' + local + subject + '_local ' + local + subject + '_local.r')
os.popen('cp ' + path + '_dev_allocativ/_setup.py ' + local + subject + '_setup.py')
os.popen('cp ' + path + '_dev_allocativ/_setup.r ' + local + subject + '_setup.r')
os.popen('cp ' + path + '_dev_allocativ/hnb_2021/_public.py ' + local + subject + '_public.py')
os.popen('cp ' + path + '_dev_allocativ/hnb_2021/_spatial.r ' + local + subject + '_spatial.r')
os.popen('cp ' + path + '_dev_allocativ/fp_3001/_learn.py ' + local + subject + '_learn.py')
os.popen('cp ' + path + '_dev_allocativ/hnb_2021/_maps.r ' + local + subject + '_maps.r')
os.popen('cp ' + path + '_dev_allocativ/fp_3001/_model.py ' + local + subject + '_model.py')
os.popen('cp ' + path + '_dev_allocativ/fp_3001/_stats.r ' + local + subject + '_stats.r')

## Create Summary file
text_file = open('summary.txt', 'w') # Write new corresponding text file
text_file.close() # Close file

## README
text_file = open(local + subject + 'README.txt', 'w') # Write new corresponding text file
text_file.write(title + descriptive + outcome + '\n') # Script title
text_file.write(author + '\n\n') # Project Author(s)
text_file.write('This directroy was created from scripts located in `' + local + 'allocativ/`. Refer there for more documentation.\n\n') # allocativ location and documentation
text_file.close() # Close file