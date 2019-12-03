***************************************************************************************
* $Id: plot.gs,v 1.40 2016/11/19 23:17:38 bguan Exp $
*
* Copyright (c) 2012-2016, Bin Guan
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this list
*    of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or other
*    materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
* OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
* SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
* BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
* ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
* DAMAGE.
***************************************************************************************
function plot(arg)
*
* Plot 1-D graph.
*
rc=gsfallow('on')

* Define system temporary directory.
tmpdir='/tmp'
* Get username and create user-specific temporary directory.
'!echo $USER > .bGASL.txt'
rc=read('.bGASL.txt')
while(sublin(rc,1))
  '!echo $USER > .bGASL.txt'
  rc=read('.bGASL.txt')
endwhile
user=sublin(rc,2)
'!rm .bGASL.txt'
mytmpdir=tmpdir'/bGASL-'user
'!mkdir -p 'mytmpdir
* Get process ID.
pidlock=mytmpdir'/pid.lock'
pidfile=mytmpdir'/pid.txt'
'!while true; do if mkdir 'pidlock'; then break; else echo System busy. Please wait...; sleep 1; fi; done 2> /dev/null'
'!echo $PPID > 'pidfile
rc=read(pidfile)
randnum=sublin(rc,2)
'!rm -r 'pidlock

*
* Parse -v option (variable).
*
num_var=parseopt(arg,'-','v','variable')

if(num_var=0)
  usage()
  return
endif

*
* Parse -r option (range).
*
range_rc=parseopt(arg,'-','r','range')
cnt=1
while(cnt<=range_rc)
  if(!valnum(_.range.cnt))
    say '[plot ERROR] <range_from> and <range_to> must be numeric.'
    return
  endif
  cnt=cnt+1
endwhile

*
* Initialize other options.
*
cnt=1
while(cnt<=num_var)
  _.mark.cnt=cnt+1
  _.marksize.cnt=0.11
  _.style.cnt=-1
  _.color.cnt=cnt
  _.thick.cnt=-1
  _.text.cnt='Variable 'cnt
  cnt=cnt+1
endwhile
_.append.1=0
_.yaxis.1='linear'

*
* Parse -m option (mark).
*
rc=parseopt(arg,'-','m','mark')
if(rc=1)
  cnt=2
  while(cnt<=num_var)
    _.mark.cnt=_.mark.1
    cnt=cnt+1
  endwhile
endif

*
* Parse -z option (mark size).
*
rc=parseopt(arg,'-','z','marksize')
if(rc=1)
  cnt=2
  while(cnt<=num_var)
    _.marksize.cnt=_.marksize.1
    cnt=cnt+1
  endwhile
endif

*
* Parse -s option (style).
*
rc=parseopt(arg,'-','s','style')
if(rc=1)
  cnt=2
  while(cnt<=num_var)
    _.style.cnt=_.style.1
    cnt=cnt+1
  endwhile
endif

*
* Parse -c option (color).
*
rc=parseopt(arg,'-','c','color')
if(rc=1)
  cnt=2
  while(cnt<=num_var)
    _.color.cnt=_.color.1
    cnt=cnt+1
  endwhile
endif

*
* Parse -k option (thick).
*
rc=parseopt(arg,'-','k','thick')
if(rc=1)
  cnt=2
  while(cnt<=num_var)
    _.thick.cnt=_.thick.1
    cnt=cnt+1
  endwhile
endif

*
* Parse -t option (text).
*
rc=parseopt(arg,'-','t','text')

*
* Parse -append option.
*
rc=parseopt(arg,'-','append','append')

*
* Parse -yaxis option.
*
rc=parseopt(arg,'-','yaxis','yaxis')

'query pp2xy 0 0'
tmpxa=subwrd(result,3)
'query pp2xy 1 1'
tmpxb=subwrd(result,3)
rvratio=tmpxb-tmpxa

tick_length=0.05
tick_length=tick_length*rvratio

*
* get lower/upper boundaries
*
if(range_rc<=1)
  'set gxout stat'
  cnt=1
  while(cnt<=num_var)
    if(_.yaxis.1='log')
      'display ('_.variable.cnt')*(('_.variable.cnt')/('_.variable.cnt'))'
    else
      'display '_.variable.cnt
    endif
    minmaxline=sublin(result,8)
    varmin.cnt=subwrd(minmaxline,4)
    varmax.cnt=subwrd(minmaxline,5)
    cnt=cnt+1
  endwhile
  'set gxout contour'
  lowerbnd=varmin.1
  upperbnd=varmax.1
  cnt=2
  while(cnt<=num_var)
    if(lowerbnd>varmin.cnt)
      lowerbnd=varmin.cnt
    endif
    if(upperbnd<varmax.cnt)
      upperbnd=varmax.cnt
    endif
    cnt=cnt+1
  endwhile
else
  lowerbnd=_.range.1
  upperbnd=_.range.2
endif

if(_.yaxis.1='log')
  'set vrange 'math_log10(lowerbnd)' 'math_log10(upperbnd)
else
  'set vrange 'lowerbnd' 'upperbnd
endif
say '[plot info] Range = 'lowerbnd' to 'upperbnd'.'

cnt=1
while(cnt<=num_var)
  if(_.mark.cnt!=-1);'set cmark '_.mark.cnt;endif
  if(_.style.cnt!=-1 & _.style.cnt!='bar');'set cstyle '_.style.cnt;endif
  if(_.color.cnt!=-1);'set ccolor '_.color.cnt;endif
  if(_.thick.cnt!=-1);'set cthick '_.thick.cnt;endif
  'set digsiz '_.marksize.cnt*rvratio
  if(_.style.cnt='bar')
    'set gxout bar'
    if(_.thick.cnt=-1);_.thick.cnt=12;endif
    'set bargap '100-100/12*_.thick.cnt
    vara=split(_.variable.cnt,';','head')
    varb=split(_.variable.cnt,';','tail')
    cola=split(_.color.cnt,';','head')
    colb=split(_.color.cnt,';','tail')
    if(colb=''); colb=cola; endif
    if(varb='')
      'set ccolor 'cola
      'display 'vara
    else
      'set ccolor 'cola
      'display 'vara';maskout('varb','vara'-'varb')'
      'set ccolor 'colb
      'display 'vara';maskout('varb','varb'-'vara')'
    endif
  else
    'set gxout line'
    if(_.yaxis.1='log')
      setylevs='set ylevs'
      ylev=math_log10(lowerbnd)
      while(ylev<=math_log10(upperbnd))
        setylevs=setylevs' 'ylev
        ylev=ylev+1
      endwhile
      setylevs
      'set ylopts 1 -1 0'
      'display log10('_.variable.cnt')'
      'query gxinfo'
      line3=sublin(result,3)
      x=subwrd(line3,4)
      ylev=math_log10(lowerbnd)
      while(ylev<=math_log10(upperbnd))
        'query gr2xy 0 'ylev
        y=subwrd(result,6)
        'set string 1 r'
        if(cnt=1);'draw string 'x-tick_length' 'y' 'math_pow(10,ylev);endif
        ylev=ylev+1
      endwhile
    else
      'display '_.variable.cnt
    endif
  endif
  cnt=cnt+1
endwhile

if(_.append.1!=1)
  rc=write(mytmpdir'/legend.txt.'randnum,'line')
endif
cnt=1
while(cnt<=num_var)
  line=_.mark.cnt' '_.marksize.cnt*rvratio' '_.style.cnt' '_.color.cnt' '_.thick.cnt' '_.text.cnt
  if(_.append.1!=1)
    rc=write(mytmpdir'/legend.txt.'randnum,line)
  else
    rc=write(mytmpdir'/legend.txt.'randnum,line,append)
  endif
  cnt=cnt+1
endwhile
rc=close(mytmpdir'/legend.txt.'randnum)

return
***************************************************************************************
function parseopt(instr,optprefix,optname,outname)
*
* Parse an option, store argument(s) in a global variable array.
*
rc=gsfallow('on')
cnt=1
cnt2=0
while(subwrd(instr,cnt)!='')
  if(subwrd(instr,cnt)=optprefix''optname)
    cnt=cnt+1
    word=subwrd(instr,cnt)
    while(word!='' & (valnum(word)!=0 | substr(word,1,1)''999!=optprefix''999))
      cnt2=cnt2+1
      _.outname.cnt2=parsestr(instr,cnt)
      cnt=_end_wrd_idx+1
      word=subwrd(instr,cnt)
    endwhile
  endif
  cnt=cnt+1
endwhile
return cnt2
***************************************************************************************
function split(instr,char,where)
outstr1=instr
outstr2=''
* note: default output if char is not found
cnt=1
while(substr(instr,cnt,1)!='')
  if(substr(instr,cnt,1)=char)
    outstr1=substr(instr,1,cnt-1)
    outstr2=substr(instr,cnt+1,strlen(instr)-cnt)
  endif
  cnt=cnt+1
endwhile
if(where='head')
  return outstr1
endif
if(where='tail')
  return outstr2
endif
***************************************************************************************
function usage()
*
* Print usage information.
*
say '  Plot 1-D graph.'
say ''
say '  USAGE: plot -v <var1> [<var2>...] [-r <range_from> <range_to>] [-m <mark1> [<mark2>...]] [-z <size1> [<size2>...]] [-s <style1> [<style2>...]]'
say '         [-c <color1> [<color2>...]] [-k <thick1> [<thick2>...]] [-t <text1> [<text2>...]] [-yaxis linear|log] [-append 1]'
say '    <var>: variable to be plotted.'
say '    <range_from> <range_to>: axis limit. Minimum and maximum values are used if unset.'
say '    <mark>: mark type. Default="2 3 4...", i.e., open circle, closed circle, open square, closed square, etc.'
say '    <size>: mark size. Default=0.11,'
say '    <style>: line style. Current setting is used if unset.'
say '    <color>: mark/line color. Default="1 2 3...", i.e., foreground color, red, green, dark blue, etc.'
say '    <thick>: mark/line thickness. Integers between 1 and 12. Current setting is used if unset.'
say '    <text>: text to be shown in legend. Text beginning with a minus sign or containing spaces must be double quoted.'
say '    linear|log: set y-axis to be linear or logarithmic.'
say '    -append 1: use if appending to an existing plot. (Run "legend.gs" only once after all data are plotted.)'
say ''
say '  EXAMPLE 1: plot three variables with lines.'
say '    plot -v ao pna nino34 -t AO PNA Nino3.4'
say '    legend'
say ''
say '  EXAMPLE 2: plot one variable with 2-colored bars based on signs and another variable with line.'
say '    zeros=0'
say '    plot -v ao;zeros pna -t AO PNA -s bar 1 -k 10 5 -c 2;4 1'
say '    legend'
say ''
say '  DEPENDENCIES: parsestr.gsf'
say ''
say '  SEE ALSO: legend.gs'
say ''
say '  Copyright (c) 2012-2016, Bin Guan.'
return




