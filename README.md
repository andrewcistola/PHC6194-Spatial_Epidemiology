# PHC 6194 - Spatial Epidemiology
PHC 6194 - Spatial Epidemiology (Spring 2021)

## About this Repository
This repository contains student work completed for PHC 6194 Spatial Epidemiology taken in Spring of 2021 from Dr. Hui Hu (https://www.hui-hu.com) at the University of Florida. Course content is pulled from https://github.com/benhhu/PHC6194SPR2021 and stored with completed assignments in this repoistory. At the end of the semester, visibility of the repo will be changed to private. 

## Directory
`WK1` Week 1 Course content<br>
`_code` Code scripts not connected to assignments, labs, or projects<br>
`_data` Data files taken from https://github.com/andrewcistola/healthy-neighborhoods.git for use in final project<br>
`LICENSE` Generic MIT licenses for open source projects from DrewC!<br>
`.gitattributes` File extensions marked for GH large file storage<br>
`README.md` Description, directory, notes<br>

## Organization and Style
This repository uses the following description for file organization and coding style:

### File Organization:
This repository organizes file by project specfic topics and generic folders<br>
Project specfic topic descriptions are included in the README<br>
Generic folders may include the following based on the needs of the repository:<br>
`_code` Code scripts used by multiple projects<br>
`_fig` Figures used by multiple projects<br>
`_data` Data files use dmy multiple projects<br>
`_archive` Old files no longer used<br>
`_refs` References, literature, or documentation files<br>

### File Names:
File names use 2-6 letter label based on the file content followed by standard prefixes and suffixes<br>
Template: `topic_version_suffix.ext`<br>
Greek alphabet is used to represent file versions:<br>
`alpha_`, `beta_`, `gamma_`... `omega_`<br> 
Standard suffixes represent the following types of files:<br>
`_code` Development code script for working in an IDE<br>
`_book` Jupyter notebook <br>
`_stage` Data files that have been modified from raw source<br>
`_2020-01-01` Text scripts with results output with date it was run<br>
`_map` 2D geographic display<br>
`_graph` 2D chart or graph representing numeric data

### Variable Names:
Python and R code scripts use the following variable naming conventions:<br>
`xx` = 2-6 letter abbrevation based on content within data object<br>
`df_xx` Pandas and R dataframes<br>
`l_xx` Pandas and R lists<br>
`v_xx` R vectors<br>
`a_xx` Numpy arrays<br>
`m_xx` Numpy or R matrices<br>
`df_X` feature tables <br>
`df_Y` target tables <br>

### PEP-8 Standards:
Whenever possible code scripts follow PEP-8 standards with the following elective options:<br>
<br>
`=` for variable defintions (no `<-`)<br>
`''` for all character strings or arguments (no `""`) <br>
A single space is provided between each element ex. `columns = 'ColA'`<br>

## Disclaimer
While the author (Andrew Cistola) is a Florida DOH employee and a University of Florida PhD student, these are NOT official publications by the Florida DOH, the University of Florida, or any other agency. 
No information is included in this repository that is not available to any member of the public. 
All information in this repository is available for public review and dissemination but is not to be used for making medical decisions. 
All code and data inside this repository is available for open source use per the terms of the included license. 