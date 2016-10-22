vimnote
=======
**vimnote** is a Vim plugin to support note taking with Vim. **vimnote** should
support following functions

* Command to open a template for e.g. a minutes of meetings document
* Formatting the document
* Compile the document to pdf using pandoc
* Extract tasks to syctask
* Search through all documents and promote them to the quickfix list
* Search minutes of meetings files

Templates
---------
When opening a file with a specific ending we want to open a template that 
relates to that type of file. When we create a new minutes of meeting file it
should contain following lines

     % <+TITLE+>
     % Date:     <+DATE+> - <+TIME+>
     % Location: <+LOCATIION+>

     Participants
     ------------

     Objective
     ---------

     Results
     -------

The header part indicated by **%** will be formatted nicely with **pandoc**.

A minutes of meetings file will have the ending **.mom.md**. If a file with that
ending is created then the template should be loaded. We then want to replace
the placeholders, e.g. **<+TITLE+>** with the actual title. To make this more
conveniant we provide a mapping that jumps to the placeholder, selects it and
enters insert mode.

The template we put into `~/.vim/templates` and we create a mapping that loads
the template when we create a file with the `mom.md` ending.

    autocmd BufNewFile *.mom.md 0r ~/.vim/templates/mom.md

We map <c-j> in insert and normal mode to search and change the placeholder

    nnoremap <c-j> /<+.\{-1,\}+><cr>c/+>/e<cr>
    inoremap <c-j> <ESC>/<+.\{-1,}+><cr>c/+>/e<cr>

Formatting the document
-----------------------
The format of a document has several aspects. Formatting includes highlighting
of specific words and sections. In this section we want to talk about the 
implementation of highlighting and also talk about formatting helpers.

### Filetype specific formatting
*Vimnote* uses the markdown format. But we want to add additional functions 
based on the file extension, e.g. loading templates. If we would use for all
files the .markdown or .md extension we could not trigger specific behaviour.
Therefore we create a new filetype that actually formats to markdown.

#### Detecting the filetype
We will have as we go different filetypes as the requirements occur. We start 
with the .minutes and .note filetypes. Both filetypes acutally format as 
markdown.

To implement filetype detection we create the `vimnote/ftdetect/` directory  and
add the vimnote.vim file.

    $ mkdir vimnote/ftdetect
    $ touch vimnote/ftdetect/vimnote.vim

Add following to vimnote.vim

    au BufNewFile,BufRead *.minutes setfiletype=markdown
    au BufNewFile,BufRead *.note setfiletype=markdown

When we are create (BufNewFile) or opening (BufRead) a file with extension 
.minutes or .note the filetype vimnote will be set. After closing Vim and 
reopening with a file test.note and then asking for the file type, Vim should 
respond with `filetype=vimnote`.

    :set filetype?
    filetype=markdown

If we add text to the file with markdown markup we will see the nicely 
highlighted as markdown.

### Table format
Writing the minutes of meeting we want to concentrate on the content and not so
much on the formatting. Escpecially when creating tables we just put the text in
a table structure but won't nicely indent the columns. Column indentation 
should be done automatically.

When we create a table this might look like this

    Topic | Description | Who
    ----- | ----------- | ---
    Invite to meeting | Participants: Jane, Jack, Jon | Sue
    Minutes | Distribute by tomorrow | Jane
    Decide upon investment | Get all stakeholders on one table within next 5 days and check if the business cases are challengable and investment can be released | Jeniffer

    Table: Todos by next Monday

The table is unformatted and contains a multiline column. To format the table we
have to convert the table to markdown multiline table and after the 
transformation it will look like this

    -------------------------------------------------------------------
    Topic                  Description                         Who
    ---------------------- ----------------------------------- --------
    Invite to meeting      Participants: Jane, Jack, Jon       Sue

    Minutes                Distribute by tomorrow              Jane

    Decide upon investment Get all stakeholders at one table 
                           within next 5 days and check if the 
                           business cases are challengable and 
                           investment can be released          Jeniffer
    -------------------------------------------------------------------
   
    Table: Todos by next Monday

This kind of multiline table is an extension of **pandoc**. Details can be found
at `man pandoc`.

The original table should be saved to .raw.mom.md

To format a table it has to be visually selected. Then `:FormatTable` will 
format it to a multiline table.

To programatically get the visual selection we can use

    normal `<y`>
    
which will yank the selected text to the **0** buffer. We can retrieve the 
selection with 

    let selection = @0

The lines are separated with `^@` wich is Vim's `\n` and we can split up the 
selection into lines with

    let lines = split(selection, '\n')

Next we have to determine the maximum length of each column value. To retrieve
the columns we need to

* determine the column separator
* split each line into columns
* group the lines' column values
* determine the maximum column width of each column

The table width should not exceed 80 characters. So we have to distribute the
table colum widths to not exceed 80 characters.

* calculate the width of each column
* split each column value in multiple lines if neccessary so the column value
  fits into the column width. This one is a bit tricky so we further describe
  the approach
    + split up each line's column into chunks and fill it up with spaces so it 
      fits the column width
    + determine the column with the most rows and concat each column row to one
      row.

Now we have prepared the columns and are ready to create the table.

* start the table with a dashed line over the width of the table
* use the first non-empty line as the header
* underline the header values with a dashed line with the column width
* write the columns of each line respecting the column width. If neccessary fill
  with blanks
* separate each line with a blank line
* After the last line print a dashed line over the width of the table

Finally replace the old table with the newly created table.

### Insert an image
To insert an image with markdown syntax we use 
`![some image caption](url/of/the/image.png)`. When the user enters `![` the
application listens for `](`. As soon as the user types this sequence of 
characters the *image directory* is inserted and the user can invoke `^x^f`
to display files in the image directory. If the user enters a new line before
the character sequence `](` appears the application starts listening for `![`
again.

The string that holds the typed character sequence has to be global, so that
between key strokes the content doesn't get lost.

The *image directory* can be set in the `vimrc` file.

    let g:image_dir="~/Pictures/"

If the *image directory* is not set then a default directory will be used, which
is `~/vimnote/images/`.

    function! InsertImage()
      if !exists("g:image_sequence")
        if v:char == '!'
          let g:image_sequence = v:char
          let g:image_line = line('.')
        endif
      else
        let g:image_sequence .= v:char
        if g:image_line != line('.')
          unlet g:image_sequence
        elseif g:image_sequence =~ '^!\[.\+\]('
          unlet g:image_sequence
          let v:char .= g:image_dir
        endif
      endif
    endfunction
    autocmd InsertCharPre * call InsertImage()

Compile to PDF
--------------
To distribute our document we have to convert it to a document format that can
be read by the typical PC user. Therefor we want to thd PDF format. For that
purpose we want to use **pandoc**. To create a pdf document from a markdown
document we use following command assuming we have a document 
**investments.mom.md**

    $ pandoc investments.mom.md -f markdown -s -o pdf/investments.mom.pdf

But instead of running the command from command line we want to do the 
conversion from within the document. To do so we need a mapping to the external
pandoc command. We create a script for that

    function! vimnote#CreatePDF()
      let outfile = split(@%, 'md')[0] . 'pdf' 
      let command = 'pandoc ' . @% . '-f markdown -s -o ' . outfile
      let message = system(command)
      
      if message == ''
        let message = 'created ' . outfile
      endif

      echomsg '[vimnote] ' . message
    endfunction
    command! WritePDF call vimnote#CreatePDF()

We first create an outfile accessing the current file with `@%` and stripping of
the `md` extension `split(@%, 'md')[0] . 'pdf'`. Next we create the command to
invoke pandoc and invoke the command with `system(command). Finally we inform
the user that we have created the pdf file.

Extract Tasks
-------------
**syctask** is a command line application that is organizing tasks. **syctask**
can import tasks from a file that has annotations. Consider following file 
snippet

    Results
    -------

    @tasks|

    title:Topic | description:Description | :Who
    ----- | ----------- | ---
    Invite to meeting | Participants: Jane, Jack, Jon | Sue
    Minutes | Distribute by tomorrow | Jane
    Decide upon investment | Get all stakeholders on one table within next 5
    days and check if the business cases are challengable and investment can be
    released | Jeniffer

    Table: Todos by next Monday

We can extract tasks from the file, assuming it has the name investments.mom.md

    $ task scan investments.mom.md

To extract the tasks from the current file we create a function 
**ExtractTasks()**

    function! vimnote#ExtractTasks()
      let command = 'syctask scan ' . @%
      let result = system(command)

      let message = len(result) == 1 ? result[0] : result[1]
      echomsg '[vimnote] . message 
    endfunction
    command! ScanTasks call vimnote#ExtractTasks()

Search Minutes' Content
-----------------------
When we are searching for a word we want to have all files and positions within
the file listed in a quickfix list and then skip through the files. To search we
create a command that takes a word and then starts searching. The search 
function is already available with 

    :vimgrep /word/ **/*

Then we can open the quickfix list with `:copen` or we can jump through the
quickfix list with `:cnext` and `:cprev`. Instead we create a function so we
can call **FindTerm()** that searches in the mom directory. The questions is - 
where is the mom directory? We need some way to configure the mom directory. It
obviously makes sense to have our moms in one place where we can search for 
their content. We set the global variable in the **~/.vimrc** file

    let g:notes_dir=~/Documents/mom/

Then in our function we can get access to **notes_dir**

    function! vimnote#SearchWord(word)
      vimgrep /word/ notes_dir/**/*
    endfunction
    command! -nargs=1 FindWord call vimnote#SearchWord(<q-args>)

Search Minutes Files
--------------------
To search files Vim comes with the `find` command. The `find` command requires
the **path** to be populated with the directories we want to search in. If a
file is found it is opend in the buffer. As an example we want to search for our
**investment.mom.md** file. First we add the **notes_dir** to the path. Then
we can search for the file.

    :set path+=~/Documents/mom/
    :find inve<TAB>
    
We want to have a slightly different behaviour. When searching for a file we 
want to have populated the quickfix list. In order to do so we will use the 
Linux `find` command where we also can use regular expressions. The `find`
command is used as shown next

    $ find ~/Documents/mom/ -type f -name "*.mom.md" | xargs file

This will give us all files ending with mom.md and what type the file is and 
if available what version.

    ~/Documents/mom/investment.mom.md: ASCII text

In order to format this for the quickfix list we have to provide a form as

    ~/Documents/mom/investment.mom.md:1: ASCII text

We do this by sending the file to sed and replacing the ':' with ':1:'

    $ find ~/Documents/mom/ -type f -name "*.mom.md" | xargs file | \
    sed "s/:/:1:/"

The function that accomplishes the intendet search will look like this

    function! vimnote#SearchFiles(filename)
      let quickfix_file = tempname()
      let command = 'find ' . g:notes_dir . ' -type f -name "' .
                       \ a:filename . '" | xargs file | set "s/:/:1:/"'
      let result = system(command)
      if result =~ 'Usage: '
        let result = '[vimnote] Search ' . filename . ':1: File not found'
      endif

      silent execute '!echo ' . result . ' > ' . tempfile()
      execute "cfile " . quickfix_file
      copen
      call delete(quickfix_file)
    endfunction
    command! -nargs=1 FindFiles call vimnote#SearchFiles(<q-args>)

Writing the Plugin
==================
A plugin can be loaded into the Vim context. In this section we acutally devleop
our plug vimnote.

Plugin Structure
----------------
A plugin has to follow a specific structure that is shown below for our 
vimnote plugin

    +- vimnote
       |
       +- plugin
       |
       +- ftdetect
       |
       +- ftplugin
       |
       +- syntax
       |
       +- autoload
       |
       +- doc

vimnote is our directory where we put our plugin related code. Each directory
has a special meaning and files in the directories will be handled differently
by Vim

Directory | Description
--------- | --------------------------------------------------------------
plugin    | Scripts in this directory get loaded at Vim start up
ftdetect  | Scripts in this directory are used to detect the file type
ftplugin  | Scripts that operate on the file type
syntax    | Syntax specific actions for the file type, e.g. highlighting
autoload  | Scripts will be loaded only when invoked from other script files
templates | Template files we want to get loaded when creating a mom.md file
doc       | Help files for the plugin

First we create the plugin structure. But without ftdetect, ftplugin and syntax
which we won't need for our plugin

    $ mkdir ~/Work/vimnote/
    $ cd ~/Work/vimnote
    $ mkdir plugin autoload templates doc

In order to get the plugin loaded during development we have to add our vimnote
directory to Vim's runtimepath. We add following to the ~/.vimrc file

    set runtimepath+=~/Work/vimnote/

The we have to eather shutdown Vim and start it to make the changes take effect
or we have to source ~/.vimrc with

    :source ~/.vimrc

templates
---------
When we open a file with the ending **.mom.md** we load a template from the
**templates** directory. If not created yet create the directory **templates**
and add the file **mom.md** with following content

     % <+TITLE+>
     % Date:     <+DATE+> - <+TIME+>
     % Location: <+LOCATIION+>

     Participants
     ------------

     Objective
     ---------

     Results
     -------

plugin
------
In the plugin directory we put the scripts we want to be loaded or executed at
start up time of Vim.

### Loading Templates
In order to load the template when opening a **.mom.md** file we need to make
Vim aware of doing so. Add following to the vimnote/plugin/vimnote.vim directory

    autocmd BufNewFile *.mom.md 0r ../templates/mom.md

    nnoremap <c-j> /<+.\{-1,\}+><cr>c/+>/e<cr>
    inoremap <c-j> <ESC>/<+.\{-1,}+><cr>c/+>/e<cr>

### Loading Functions
We add following functions to vimnote/plugin/vimnote.vim

    function! CreatePDF()
      let outfile = split(@%, 'md')[0] . 'pdf' 
      let command = 'pandoc ' . @% . '-f markdown -s -o ' . outfile
      let message = system(command)
      
      if message == ''
        let message = 'created ' . outfile
      endif

      echomsg '[vimnote] ' . message
    endfunction
    command! WritePDF call CreatePDF()

    function! ExtractTasks()
      let command = 'syctask scan ' . @%
      let result = system(command)

      let message = len(result) == 1 ? result[0] : result[1]
      echomsg '[vimnote] . message 
    endfunction
    command! ScanTasks call ExtractTasks()

    function! SearchWord(word)
      let quickfix_file = tempname()
      let command = 'grep -rn ' . a:word . ' ' . g:notes_dir
      let result = system(command)[:-3]

      if result == ""
        echomsg '[vimnote] Search ' . a:word . ' word not found'
      else
        let write_command = 'echo "' . result . '" > ' . quickfix_file
        echomsg system(write_command)
        execute "cfile " . quickfix_file
        copen
      endif

      call delete(quickfix_file)
    endfunction
    command! -nargs=1 FindWord call SearchWord(<q-args>)

    function! SearchFiles(filename)
      let quickfix_file = tempname()
      let command = 'find ' . g:notes_dir . ' -type f -name "' .
                       \ a:filename . '" | xargs file | sed "s/:/:1:/"'
      let result = system(command)[:-3]

      if result =~ 'Usage: '
        echomsg '[vimnote] Search ' . a:filename . ' file not found'
      else
        let write_command = 'echo "' . result . '" > ' .quickfix_file
        echomsg system(write_command)
        execute "cfile " . quickfix_file
        copen
      endif

      call delete(quickfix_file)
    endfunction
    command! -nargs=1 FindFiles call SearchFiles(<q-args>)

autoload
========
Files in the autoload directory will be loaded on demand. The function that we
use in vimnote/plugin/vimnote.vim which is vimnote#ExecuteSearch() we add to
vimnote/autoload/vimnote.vim

    function! vimnote#ExecuteSearch(command, condition, message)
      let quickfix_file = tempname()
      let result = system(a:command)[:-3]

      if result == "" || result =~ a:condition
        echomsg '[vimnote] ' . a:message
      else
        let write_command = 'echo "' . result . '" > ' . quickfix_file
        echomsg system(write_command)
        execute "cfile " . quickfix_file
        copen
      endif

      call delete(quickfix_file)
    endfunction

doc
---
The Vim help file goes into the doc directory. A Vim help file has a specific 
structure that we will create in the following section.

Installing vimnote
==================
To install vimnote we will use 
[pathogen.vim](https://github.com/tpope/vim-pathogen). To install pathogen.vim
follow the instructions on the pathogen.vim home page.

vimnote can be installed from [Github]() by processing following commands 

    $ cd ~/.vim/bundle
    $ git clone git://github.com/sugaryourcoffee/vimnote.git

At the next Vim start up vimnote is installed.

Sources
=======
* [The VimL Primer](https://pragprog.com/book/bkviml/the-viml-primer)
* [Hacking Vim 7.2](https://www.packtpub.com/application-development/hacking-vim-72)
* [Practical Vim](https://pragprog.com/book/dnvim2/practical-vim-second-edition)
* [wikia - searching for files](http://vim.wikia.com/wiki/Searching_for_files)

