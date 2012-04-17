program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils,classes,strutils,
  windows;

type
  prec=^rec;
  rec=record
//  buff:array[0..$10B] of byte;
  str:string;
  offset,mass:cardinal;
  xorka:byte;
  end;

var
  mal:array [0..$9bF] of byte;  //$9bF
//  mrbr:cardinal=$0EB36A9A;
  mya:cardinal=0;

  glob:cardinal=0;
  files:cardinal=0;

  xrr:Byte;

  i,j:cardinal;

  prs,prs2:Pointer;

  llst:TList;

  tabsmesh:cardinal=0;
  glosmesh:cardinal=0;

  meax,medx,mecx:cardinal;

  partmp1,partmp2:cardinal;

  per1,per2:cardinal;


  startdir_ln:cardinal;
   startdir_st:string;


  tmps,tmps2:string;


  fil,fil2:cardinal;
ss:cardinal;
ovr:OVERLAPPED;
pck,dir:string;
zzz:prec;

begin

pck:=ParamStr(1);
dir:=ExtractFilePath(ParamStr(0));
if pck='' then exit;



tmps:=pck;

fil:=CreateFile(@tmps[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);

ovr.Internal:=0;
ovr.InternalHigh:=0;
ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.hEvent:=0;

files:=0;

ReadFileEx(fil,@files,2,@ovr,nil);

j:=files*$10C;

prs:=GetMemory(j);

ovr.Offset:=2;

ReadFileex(fil,prs,j,@ovr,nil);

meax:=0;
medx:=0;

per1:=$64;
per2:=$64;

llst:=TList.Create;

for I := 0 to j - 1 do
  begin
  mecx:=pbyte(integer(prs)+I)^;
  mecx:=mecx xor per1;
  pbyte(integer(prs)+I)^:=mecx AND $FF;
  per1:=(per1+per2) and $FF;
  per2:=(per2+$4D) and $FF;
  end;

for i := 0 to files - 1 do
  begin
  new(zzz);
  zzz.str:='';
  per1:=i*$10C;
    while pbyte(integer(prs)+per1)^<>0 do
      begin
      zzz.str:=zzz.str+pchar(integer(prs)+per1)^;
        per1:=per1+1;
      end;

  zzz.mass:=pcardinal(integer(prs)+i*$10C+$104)^;
  zzz.offset:=pcardinal(integer(prs)+i*$10C+$108)^;

  //if zzz.offset=$53E0CCC then
  //  Writeln('11111');


  zzz.xorka:=((zzz.offset shr 1) or 8) and $FF;

  llst.Add(zzz);
  
  end;

FreeMemory(prs);


for I := 0 to Llst.Count - 1 do
  begin

  zzz:=llst.Items[i];

  for j := 1 to length(zzz.str) do
    if (zzz.str[j]='\') or (zzz.str[j]='/') then
        if not(DirectoryExists(dir+AnsiLeftStr(zzz.str,j-1))) then CreateDir (dir+AnsiLeftStr(zzz.str,j-1));

    tmps:=dir+zzz.str;
  fil2:=CreateFile(@tmps[1],GENERIC_ALL,FILE_SHARE_WRITE or FILE_SHARE_READ,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

  prs:=GetMemory(zzz.mass);

  ovr.Offset:=zzz.offset;

  ReadFileEx(fil,prs,zzz.mass,@ovr,nil);

  for j := 0 to zzz.mass-1 do
  begin
  pbyte(integer(prs)+J)^:=pbyte(integer(prs)+J)^ xor zzz.xorka;
  end;

  ovr.Offset:=0;

  WriteFileEx(fil2,prs,zzz.mass,ovr,nil);

  FreeMemory(prs);

  closehandle(fil2);
  end;
  


{for I := 0 to j-1 do
  begin
  pbyte(integer(prs)+I)^:=pbyte(integer(prs)+I)^ xor per1;
  end;       }




closehandle(fil);

  { TODO -oUser -cConsole Main : Insert code here }
end.
