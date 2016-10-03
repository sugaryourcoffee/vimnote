vimnote.vim
===========
Ease note taking with Vim by using the vimnote.vim plugin.

                            _                       __     
                     _   __(_)___ ___  ____  ____  / /____ 
                    | | / / / __ `__ \/ __ \/ __ \/ __/ _ \
                    | |/ / / / / / / / / / / /_/ / /_/  __/
                    |___/_/_/ /_/ /_/_/ /_/\____/\__/\___/ 
                                                           

Installation
------------
The easiest way to install vimnote.vim is to use 
[pathogen.vim](https://github.com/tpope/vim-pathogen) following the instructions
on the pathogen.vim website on Github.

When pathogen.vim is installed the installation of vimnote.vim is as follows

    $ cd ~/.vim/bundle
    $ git clone git://github.com/sugaryourcoffee/vimnote.git

Next time you start up vimnote will be available.

Preparation
-----------
vimnote expects notes in a specific directory. If you don't specify a directory
`~/vimnote/` will be created and used to save notes. To specify the directory
add following snippet to ~/.vimrc

    let g:notes_dir="/path/to/your/notes/directory"

Create the directory along with a sub-directory 'pdf'

    $ mkdir -p /path/to/your/notes/directory/pdf

vimnote is using pandoc to create pdf files from the currently edited file. In
order to use that function install [pandoc](http://pandoc.org/) with

    $ sudo apt-get install pandoc

pandoc uses latex-full to create pdf file. 
[latex](https://www.latex-project.org/) can be installed with

    $ sudo apt-get install latex-full

As a Vimler you are probably more comfortable with touch typing than using the 
mouse. If so I recommend zathura. To install 
[zathura](https://pwmt.org/projects/zathura/) run

    $ sudo apt-get install zathura

Tasks can be extracted from a file into a syc-task task. To use this 
function install [syc-task](https://rubygems.org/gems/syc-task) with

    $ gem install syc-task

Usage
-----
When opening a file with the extension .minutes, .note or .speech a template 
file is loaded. The template files are located in the directory
'~/.vim/bundle/vimnote/templates/'. You can replace the content of these
files in order to adjust the content to your convenience.

When opening a new note open it with

    $ vim my-note.note

It will be saved to the `notes_dir` directory. This has the advantage when 
searching content of notes or note files they will be found by the 
**FindFiles** and **FindWords** commands.

If the file exists in the `notes_dir` it will be opened even though the path to
the `notes_dir` is not provided. If a path different from the `notes_dir` path
is provided the path will be stripped off and the file will be saved to the 
`notes_dir`.

Commands
--------
vimnote provides following commands

### FormatTable	        
A table like structure gets formatted into a pandoc multi line table. The
column separator defaults to the bar '|'. But if another separator is used, as
in the example a semicolon ';' FormatTable takes an optional separator.

    Topic ; Description ; Who
    ----- ; ----------- ; -------
    Shopping ; Get some decent clothing ; Me
    Cleaning ; Clean the house before winter ; Jane
    Study ; Study VimL to get more professional ; Jennifer

Visually select the table, then press `:<C-U>FormatTable;`. This will create a 
pandoc multi line table as shown below

    -----------------------------------------------------
    Topic    Description                         Who
    -------- ----------------------------------- --------
    Shopping Get some decent clothing            Me

    Cleaning Clean the house before winter       Jane

    Study    Study VimL to get more professional Jennifer
    -----------------------------------------------------

More information can be found at

    $ man pandoc

Then search for `multiline_tables`

### WritePDF
When in the note file you can run the WritePDF command to create a pdf file

    :WritePDF

The pdf file is saved to /path/to/your/notes/directory/pdf/my-note.note.pdf

### ScanTask
Tasks can be annotated with @tasks| where | is a field separator. Having 
following task list in the vimnote file

    @tasks|
    title|description|tags
    Homework|do your homework|home_work
    Kitchen|clean the dishes|home_work

Then you can extract the tasks with

    :ScanTasks

Detailed information how to use the @task annotation can be found at
[Create tasks by scanning from files](https://github.com/sugaryourcoffee/syc-task#create-tasks-by-scanning-from-files)

### FindWord
To search all vimnote files for a specific word run

    :FindWord clean

The files containing the search result will be populated to the quickfix list.
Open the quickfix list with `:copen`. Jump through the list with `:cnext` and
`:cprev`.

### FindFile
Similar to FindWord it is possible to search for files in the `notes_dir` with

    :FindFiles 2016-09-25*.minutes

The result will be populated to the quickfix list and can be processed as 
described in the FindWord section.

License
=======
vimnote comes with the same license as Vim. To read the license see

    :help license

Contact
=======
Questions and comments are welcome at pierre@sugaryourcoffe.de

       ____                 __  __              _____     ______       
      / __/_ _____ ____ ____\ \/ /__  __ ______/ ___/__  / _/ _/__ ___ 
     _\ \/ // / _ `/ _ `/ __/\  / _ \/ // / __/ /__/ _ \/ _/ _/ -_) -_)
    /___/\_,_/\_, /\_,_/_/   /_/\___/\_,_/_/  \___/\___/_//_/ \__/\__/ 
             /___/                                                     

