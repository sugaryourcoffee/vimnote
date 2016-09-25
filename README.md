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
use that function install pandoc with

    $ sudo apt-get install pandoc

pandoc uses latex-full to create pdf file. latex can be installed with

    $ sudo apt-get install latex-full

As a Vimler you are probably more comfortable with touch typing than using the 
mouse. If so I recommend zathura. To install zathura run

    $ sudo apt-get install zathura

Tasks can be extracted from a .mom.md file into a syc-task task. To use this 
function install syc-task with

    $ gem install syc-task

Usage
-----
When opening a file with the extension .mom.md a template file is loaded. The
template file is save at ~/.vim/bundle/vimnote/templates/mom.md. You can replace
the content of that file.

When opening a new note open it with

    $ vim /path/to/your/notes/directory/my-note.mom.md

This has the advantage when searching content of notes or note files they will
be found by the FindFiles and FindWords commands.

Commands
--------
vimnote provides following commands

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

### FindWord
To search all .mom.md files for a specific word run

    :FindWord clean

The files containing the search result will be populated to the quickfix list.
Open the quickfix list with `:copen`. Jump through the list with `:cnext` and
`:cprev`.

### FindFile
Similar to FindWord it is possible to search for files in the vimnote\_dir with

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

