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

AssignFile(fff,extractfilepath(paramstr(0))+'Patch.txt');
Reset(fff);
    pck2:=extractfilepath(paramstr(0))+'start.ax';
    br:=CreateFile(@pck2[1],GENERIC_ALL,FILE_SHARE_WRITE or FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);
ovr.Internal:=0;
ovr.InternalHigh:=0;
ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.hEvent:=0;
size:=GetFileSize(br,nil);
buff:=GetMemory(size);
ReadFileEx(br,buff,size,@ovr,nil);

CloseHandle(br);

pck2:=extractfilepath(paramstr(0))+'output.ax';
    br:=CreateFile(@pck2[1],GENERIC_ALL,FILE_SHARE_WRITE or FILE_SHARE_READ,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

WriteFileEx(br,buff,size,ovr,nil);

while not(eof(fff)) do
  begin
  Readln(fff,pck5);

  j:=strtoint(trim(AnsiLeftStr(pck5,4)));
  pck4:=RightStr(pck5,length(pck5)-5);

  leni:=length(pck4);
  pck3:=format('i%'+inttostr(leni)+'di',[j]);
  pck4:=pck4+#0;

  for i := 1 to leni-1 do
      if (pck4[i]='\') and (pck4[i+1]='n') then
        begin
        pck4[i]:=#$0D;
        pck4[i+1]:=#$0A;

        end;
    


  


  for I := 0 to size-leni-1 do
    begin
    if CompareMem(pointer(cardinal(buff)+i),@pck3[1],length(pck3)) then
      begin
        ovr.Offset:=i;
        WriteFileEx(br,@pck4[1],leni+1,ovr,nil);
      end;
    end;
    



  end;
closefile(fff);

CloseHandle(br);

  { TODO -oUser -cConsole Main : Insert code here }
end.
