@echo off
assoc .c=vim
assoc .h=vim
assoc .pl=vim
assoc .py=vim
assoc .properties=vim
assoc .md=vim
assoc .xml=vim
assoc .sh=vim
assoc .groovy=vim
assoc .css=vim
assoc .js=vim
assoc .vim=vim
assoc .sql=vim
assoc .conf=vim

REM the daddy is below:
assoc .=vim

ftype vim="C:\Program Files (x86)\Vim\vim74\gvim.exe" --remote-silent "%%1"

pause
