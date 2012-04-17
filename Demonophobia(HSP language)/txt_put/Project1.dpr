program Project1;

{$APPTYPE CONSOLE}

uses
  windows,
  SysUtils,
  Messages,
  Variants,
  Classes,
  Dialogs,
  StdCtrls,
  strutils;

var
pck:string;
pck2:string;
pck3:string;
pck4:string;
pck5:string;

br:cardinal;
ss:Cardinal;
ovr:OVERLAPPED;

offset,offset2:cardinal;

jj:cardinal;

fil,fil2,s2,bzz,bzz2:cardinal;

list:TList;

i,j,k,size:Cardinal;

buff:pointer;


dir,srcdir,dstdir:string;


entrs:cardinal;
ptmpst:Pchar;

leni:integer;

conc:cardinal;

fff,fff2:TextFile;

len:cardinal;


begin

AssignFile(fff,extractfilepath(paramstr(0))+'Texts.txt');
AssignFile(fff2,extractfilepath(paramstr(0))+'Patch.txt');

Reset(fff);
Rewrite(fff2);

pck2:=extractfilepath(paramstr(0))+'demono.hsp';
fil:=CreateFile(@pck2[1],GENERIC_ALL,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,s2);
ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.Internal:=0;
ovr.InternalHigh:=0;
size:=GetFileSize(fil,nil);
buff:=GetMemory(size);
ReadFileEx(fil,buff,size,@ovr,nil);
CloseHandle(fil);

    bzz:=0;
    bzz2:=0;

    pck2:=extractfilepath(paramstr(0))+'output.hsp';
    br:=CreateFile(@pck2[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);
j:=0;
while not(eof(fff)) do

      begin

      Readln(fff,pck5);
      pck4:=RightStr(pck5,19);
      pck2:=AnsiMidStr(pck5,10,length(pck5)-9-24);
      pck2:=StringReplace(pck2,'\n',' \n',[rfReplaceAll]);

      offset:=StrToInt('$'+LeftStr(pck4,8));
      pck4:=RightStr(pck5,5);
      len:=StrToInt(LeftStr(pck4,4));


      if bzz<offset then
        begin
          ovr.Offset:=bzz2;
          WriteFileEx(br,pointer(cardinal(buff)+bzz),offset-bzz,ovr,nil);
          bzz2:=bzz2+offset-bzz;
          bzz:=offset;
        end;




        leni:=length(pck2);
        pck3:=format('i%'+inttostr(leni)+'di',[j]);
        ovr.Offset:=bzz2;
//        pmelopan(list.items[i]).offset2:=bzz2;
        writefileex(br,@pck3[1],length(pck3),ovr,nil);
        bzz:=bzz+len;
        bzz2:=bzz2+length(pck3);

        pck3:=format('%4u=',[j]);

writeln(fff2,pck3,pck2);



      j:=j+1;
      end;

          ovr.Offset:=bzz2;
          WriteFileEx(br,pointer(cardinal(buff)+bzz),size-bzz,ovr,nil);
      closehandle(br);

closefile(fff);
closefile(fff2);

  { TODO -oUser -cConsole Main : Insert code here }
end.
