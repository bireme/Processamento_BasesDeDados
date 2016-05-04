TPR="start"
. log

if [ "$#" -ne 1 ]
then
   TPR="fatal"
   MSG="use: $0 <DP>"
   . log
fi

TPR="iffatal"
MSG="Erro: $0 - geracao mdlmp"
mx mdlbb$1 "proc=if mfn=1 then putenv('DATE='date) fi" "proc='d*a354|'replace(v354,'-',' ')'|'" "proc='Gsplit=354= '" "fst=1 0 s1:=(v354[1].4),e1:=l(['../tabs/tab354']v354[2]),s2:=(if e1>0 then ref(['../tabs/tab354']e1,v2) else '00' fi),,,e1:=(val(s(getenv('DATE')).4)-1900)*12+val(s(getenv('DATE'))*4.2),e2:=(val(s1)-1900)*12+val(s2),,,s1,s2/,,replace(f(e1-e2,4,0),' ','0')/" fullinv=mdlmp tell=110000
#mx $1 "proc=if mfn=1 then putenv('DATE='date) fi" "proc='a1354|'replace(v354,'-',' ')'|'" "proc='Gsplit=1354= '" "proc='<854>'s1:=(v1354[1].4),e1:=l(['../tabs/tab354']v1354[2]),s2:=(if e1>0 then ref(['../tabs/tab354']e1,v2) else '00' fi),,,e1:=(val(s(getenv('DATE')).4)-1900)*12+val(s(getenv('DATE'))*4.2),'</854>','<855>'e2:=(val(s1)-1900)*12+val(s2),,,s1,s2/,,replace(f(e1-e2,4,0),' ','0'),'</855>'" 
. log

exit 0

TPR="end"
. log

G4 serverofi2:/bases/mdl.000 $ cd tabs
G4 serverofi2:/bases/mdl.000/tabs $ mx seq=tab354.seq -all now create=tab354
G4 serverofi2:/bases/mdl.000/tabs $ mx tab354 "fst=1 0 v1" fullinv=tab354
exit

 mx mdlbb08 "proc='d*a354|'replace(v354,'-',' ')'|'" "proc='Gsplit=354= '" "tab=v354[2],if v354[2]='' then '-'v354[1] fi" now |sort>x354a

mx mdlbb08 "proc='d*a354|'replace(v354,'-',' ')'|'" "proc='Gsplit=354= '" "tab=v354[1],x1,e1:=l(['../tabs/tab354']v354[2]),if e1>0 then ref(['../tabs/tab354']e1,v2) else '00' fi" now |sort>x354

mx seq=x354 "pft=e1:=(val(s(date).4)-1900)*12+val(s(date)*4.2),e2:=(val(v3.4)-1900)*12+val(v3*5),replace(f(e1-e2,4,0),' ','0')"

mx mdlbb08 "proc=if mfn=1 then putenv('DATE='date) fi" "proc='d*a354|'replace(v354,'-',' ')'|'" "proc='Gsplit=354= '" "pft=s1:=(v354[1].4),e1:=l(['../tabs/tab354']v354[2]),s2:=(if e1>0 then ref(['../tabs/tab354']e1,v2) else '00' fi),,,e1:=(val(s(getenv('DATE')).4)-1900)*12+val(s(getenv('DATE'))*4.2),e2:=(val(s1)-1900)*12+val(s2),,,s1,s2/,,replace(f(e1-e2,4,0),' ','0')"
