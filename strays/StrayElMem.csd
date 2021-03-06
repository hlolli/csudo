/****************************************************************************
ipos StrayElMem Stray, Stest [, isep1 [, isep2]]
Tests whether a string is contained as an element in an array-string

Looks whether a string equals one of the elements in Stray. If yes, itest returns the position of the element, if no, -1. Elements are defined by two seperators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). if just one seperator is used, isep2 equals isep1.
Requires Csound 5.15 or higher.

Stray - a string as array
Stest - a string to be looked for in Stray
isep1 - the first seperator (default=32: space)
isep2 - the second seperator (default=9: tab) 
ipos - if Stest has been found as element in Stray, the position (starting at 0) is returned. if Stest has not been found as a member of Stray, -1 is returned
****************************************************************************/


<CsoundSynthesizer>
<CsOptions>
-n -m0
</CsOptions>
<CsInstruments>

  opcode StrayElMem, i, SSjj
;looks whether Stest is an element of Stray. returns the index of the element if found, and -1 if not.
Stray, Stest, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
istartsel =         -1; startindex for searched element
iout      =         -1 ;default output
iel       =         -1; actual number of element while searching
iwarleer  =         1; is this the start of a new element
indx      =         0 ;character index
inewel    =         0 ;new element to find
;;LOOP
 if ilen == 0 igoto end ;don't go into the loop if Stray is empty
loop:
Schar     strsub    Stray, indx, indx+1; this character
isep1p    strcmp    Schar, Sep1; returns 0 if Schar is sep1
isep2p    strcmp    Schar, Sep2; 0 if Schar is sep2
is_sep    =         (isep1p == 0 || isep2p == 0 ? 1 : 0) ;1 if Schar is a seperator
 ;END OF STRING AND NO SEPARATORS BEFORE?
 if indx == ilen && iwarleer == 0 then
Sel       strsub    Stray, istartsel, -1
inewel    =         1
 ;FIRST CHARACTER OF AN ELEMENT?
 elseif is_sep == 0 && iwarleer == 1 then
istartsel =         indx ;if so, set startindex
iwarleer  =         0 ;reset info about previous separator 
iel       =         iel+1 ;increment element count
 ;FIRST SEPERATOR AFTER AN ELEMENT?
 elseif iwarleer == 0 && is_sep == 1 then
Sel       strsub    Stray, istartsel, indx ;get elment
inewel    =         1 ;tell about
iwarleer  =         1 ;reset info about previous separator
 endif
 ;CHECK THE ELEMENT
 if inewel == 1 then ;for each new element
icmp      strcmp    Sel, Stest ;check whether equals Stest
  ;terminate and return the position of the element if successful
  if icmp == 0 then
iout      =         iel
          igoto     end
  endif
 endif
inewel    =         0
          loop_le   indx, 1, ilen, loop 
end:
          xout      iout
  endop 
  
instr 1
Stray     strget    p4
Stest     =         "a"
ipcnt     pcount
if ipcnt == 4 then
itest     StrayElMem Stray, Stest
Sep1      sprintf   "%c", 32
Sep2      sprintf   "%c", 9
elseif ipcnt == 5 then
itest     StrayElMem Stray, Stest, p5
Sep1      sprintf   "%c", p5
Sep2      sprintf   "%c", p5
elseif ipcnt == 6 then
itest     StrayElMem Stray, Stest, p5, p6
Sep1      sprintf   "%c", p5
Sep2      sprintf   "%c", p6
endif
		printf_i	"'%s' in '%s' with separators '%s' and '%s': result = %d\n", 1, Stest, Stray, Sep1, Sep2, itest
endin 

</CsInstruments>
<CsScore>
i 1 0 0.01 "sdhgfa elh 4 876" ;result: negative 
i . + . "a sdhgf elh 4 876" ;positive (at position 0)
i . + . "sdhgf a elh 4 876" ;positive (at position 1)
i . + . "sdhgf elh a 4 876" ;positive (at position 2)
i . + . "sdhgf elh 4 a 876" ;positive (at position 3)
i . + . "sdhgf elh 4 876 a" ;positive (at position 4)
i . + . "sdhgf, a, elh,  4,  876"  44 ;negative (because just commas are separators)
i . + . "sdhgf,a,elh,4,876"  44 ;positive (position 1)
i . + . "sdhgf, a, elh,  4,  876" 44 32 ;positive (because both commas and spaces are separators)
e
</CsScore>
</CsoundSynthesizer>

returns:
'a' in 'sdhgfa elh 4 876' with separators ' ' and '	': result = -1
'a' in 'a sdhgf elh 4 876' with separators ' ' and '	': result = 0
'a' in 'sdhgf a elh 4 876' with separators ' ' and '	': result = 1
'a' in 'sdhgf elh a 4 876' with separators ' ' and '	': result = 2
'a' in 'sdhgf elh 4 a 876' with separators ' ' and '	': result = 3
'a' in 'sdhgf elh 4 876 a' with separators ' ' and '	': result = 4
'a' in 'sdhgf, a, elh,  4,  876' with separators ',' and ',': result = -1
'a' in 'sdhgf,a,elh,4,876' with separators ',' and ',': result = 1
'a' in 'sdhgf, a, elh,  4,  876' with separators ',' and ' ': result = 1