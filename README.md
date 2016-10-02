vimnote.vim
===========
Ease note taking with Vim by using the vimnote.vim plugin.

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
vimnote expects notes in a specific directory. To specify the directory add
following snippet to ~/.vimrc

    let g:notes_dir="/path/to/your/notes/directory"

vimnote is using pandoc to create pdf files from the mom.md file. In order to 
use that function install [pandoc](http://pandoc.org/) with

    $ sudo apt-get install pandoc

pandoc uses latex-full to create pdf file. 
[latex](https://www.latex-project.org/) can be installed with

    $ sudo apt-get install latex-full

As a Vimler you are probably more comfortable with touch typing than using the 
mouse. If so I recommend zathura. To install 
[zathura](https://pwmt.org/projects/zathura/) run

    $ sudo apt-get install zathura

Tasks can be extracted from a .mom.md file into a syc-task task. To use this 
function install [syc-task](https://rubygems.org/gems/syc-task) with

    $ gem install syc-task

Usage
-----
When opening a file with the extension .mom.md a template file is loaded. The
template file is located at ~/.vim/bundle/vimnote/templates/mom.md. You can 
replace the content of that file in order to use a different content.

When opening a new note open it with

    $ vim my-note.mom.md

it will be saved to the `notes_dir` directory. This has the advantage when 
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
A table like structure gets formatted into a pandoc pandoc multiline table.

    Topic | Description | Who
    ----- | ----------- | -------
    Shopping | Get some decent clothing | Me
    Cleaning | Clean the house before winter | Jane
    Study | Study VimL to get more professional | Jennifer

running `FormatTable` will create a pandoc multiline table

    -----------------------------------------------------
    Topic    Description                         Who
    -------- ----------------------------------- --------
    Shopping Get some decent clothing            Me

    Cleaning Clean the house before winter       Jane

    Study    Study VimL to get more professional Jennifer
    -----------------------------------------------------

More information can be found at

    $ man pandoc

then search for `multiline\_tables`

### WritePDF
When in the note file you can run the WritePDF command to create a pdf file

    :WritePDF

The pdf file is saved to /path/to/your/notes/directory/pdf/my-note.mom.pdf

### ScanTask
Tasks can be annotated with @tasks| where | is a field separator. Having 
following task list in the .mom.md file

    @tasks|
    title|description|tags
    Homework|do your homework|home_work
    Kitchen|clean the dishes|home_work

Then you can extract the tasks with

    :ScanTasks

Detailed information how to use the @task annotation can be found at
[Create tasks by scanning from files](https://github.com/sugaryourcoffee/syc-task#create-tasks-by-scanning-from-files)

### FindWord
To search all .mom.md files for a specific word run

    :FindWord clean

The files containing the search result will be populated to the quickfix list.
Open the quickfix list with `:copen`. Jump through the list with `:cnext` and
`:cprev`.

### FindFile
Similar to FindWord it is possible to search for files in the `notes_dir` with

    :FindFiles 2016-09-25*.mom.md

The result will be populated to the quickfix list and can be processed as 
described in the FindWord section.

License
=======
vimnote comes with the same license as Vim. To read the license see

    :help license

Contact
=======
Questions and comments are welcome at pierre@sugaryourcoffe.de

