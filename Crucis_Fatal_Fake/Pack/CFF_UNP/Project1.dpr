program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  strutils,
  dialogs,
  windows,classes;


type
  ptp=^tp;
  tp=record
  sz:cardinal;
  filename:string;
  offset:cardinal;
  size:cardinal;
  end;

var
pck:string;
fil:cardinal;
ss:cardinal;
ovr:OVERLAPPED;

pck2:string;
fil2:cardinal;
ss2:cardinal;
ovr2:OVERLAPPED;


dir_to:string;
dir:string;

list:TList;

offset:cardinal;
files:cardinal;
i,j:integer;

gs:ptp;

num:cardinal;


buff:pointer;

sss:TextFile;



begin


pck:=ParamStr(1);
dir:=ExtractFilePath(ParamStr(0));
if pck='' then exit;

fil:=CreateFile(@pck[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,ss);

IF  GetLastError<>0 then begin showmessage('Error opening file'); exit; end;


num:=0;

dir_to:=ExtractFileName(pck);
dir_to:=LeftStr(dir_to,pos(ExtractFileExt(pck),dir_to)-1);
CreateDir (dir+dir_to);



ovr.Offset:=4;
ovr.OffsetHigh:=0;

ReadFileEx(fil,@num,4,@ovr,nil);

ovr.Offset:=8;

list:=TList.Create;

for i:=0 to num-1 do
  begin
  new(gs);
  list.Add(gs);
  gs.sz:=0;
ReadFileEx(fil,@gs.sz,2,@ovr,nil);
ovr.Offset:=ovr.Offset+2;
gs.filename:='';
SetLength(gs.filename,gs.sz);
gs.filename:=StringOfChar(' ',gs.sz);
ReadFileEx(fil,@gs.filename[1],gs.sz,@ovr,nil);
ovr.Offset:=ovr.Offset+gs.sz;
gs.size:=0;
ReadFileEx(fil,@gs.size,4,@ovr,nil);
ovr.Offset:=ovr.Offset+4;
gs.offset:=0;
ReadFileEx(fil,@gs.offset,4,@ovr,nil);
ovr.Offset:=ovr.Offset+4;
  end;

offset:=ovr.Offset;


Assign(sss,dir+dir_to+'.txt');
Rewrite(sss);



for I := 0 to List.Count - 1 do
  begin

  pck2:=ptp(list.Items[i]).filename;
  pck2:=dir+dir_to+'\'+pck2;

  Writeln(sss,ptp(list.Items[i]).filename);

  for j := 4 to length(pck2) do
    if pck2[j]='\' then
        if not(DirectoryExists(AnsiLeftStr(pck2,j-1))) then CreateDir (AnsiLeftStr(pck2,j-1));


  fil2:=CreateFile(@pck2[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

  buff:=GetMemory(ptp(list.Items[i]).size);

  ovr.Offset:=ptp(list.Items[i]).offset+offset;

  ReadFileEx(fil,buff,ptp(list.Items[i]).size,@ovr,nil);
  ovr.Offset:=0;
  WriteFileex(fil2,buff,ptp(list.Items[i]).size,ovr,nil);

  freemem(buff);
  closehandle(fil2);
  end;


CloseFile(sss);


closehandle(fil);
  { TODO -oUser -cConsole Main : Insert code here }
end.
