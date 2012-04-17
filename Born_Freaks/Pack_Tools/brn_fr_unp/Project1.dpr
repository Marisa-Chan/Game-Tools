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
  filename:array [1..$20] of char;
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
i:integer;

gs:ptp;


buff:pointer;



begin


pck:=ParamStr(1);
dir:=ExtractFilePath(ParamStr(0));
if pck='' then exit;

fil:=CreateFile(@pck[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,ss);

IF  GetLastError<>0 then begin showmessage('Error opening file'); exit; end;



dir_to:=ExtractFileName(pck);
dir_to:=LeftStr(dir_to,pos(ExtractFileExt(pck),dir_to)-1);
CreateDir (dir+dir_to);



ovr.Offset:=4;
ovr.OffsetHigh:=0;

ReadFileEx(fil,@offset,4,@ovr,nil);

ovr.Offset:=8;
ReadFileEx(fil,@files,4,@ovr,nil);


list:=TList.Create;

ovr.Offset:=$C;
for I := 1 to files do
  begin
  new(gs);
  ReadFileEx(fil,@gs.filename[1],$20,@ovr,nil);
  ovr.Offset:=ovr.Offset+$20;
  ReadFileEx(fil,@gs.offset,4,@ovr,nil);
  ovr.Offset:=ovr.Offset+4;
  ReadFileEx(fil,@gs.size,4,@ovr,nil);
  ovr.Offset:=ovr.Offset+4;
  list.Add(gs);
  end;

for I := 0 to List.Count - 1 do
  begin

  pck2:=ptp(list.Items[i]).filename;
  pck2:=dir+dir_to+'\'+pck2;

  fil2:=CreateFile(@pck2[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

  buff:=GetMemory(ptp(list.Items[i]).size);

  ovr.Offset:=ptp(list.Items[i]).offset+$C+offset;

  ReadFileEx(fil,buff,ptp(list.Items[i]).size,@ovr,nil);
  ovr.Offset:=0;
  WriteFileex(fil2,buff,ptp(list.Items[i]).size,ovr,nil);

  freemem(buff);
  closehandle(fil2);
  end;





closehandle(fil);
  { TODO -oUser -cConsole Main : Insert code here }
end.
