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

    let g:vimnote_dir=/path/to/your/notes/directory

vimnote is using pandoc to create pdf files from the mom.md file. In order to 
use that function install pandoc with

    $ sudo apt-get install pandoc

pandoc uses latex to create pdf file. latex can be installed with

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

### FindWord

### FindFile

License
=======
vimnote comes with the same license as Vim. To read the license see

    :help license

Contact
=======
Questions and comments are welcome at pierre@sugaryourcoffe.de

