program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils,strutils,
  windows;

var
  fil,s2,s1:cardinal;
  ovr:OVERLAPPED;

  str2,str3:string;

  str:array[0..1023] of char;

  buff:Pointer;

  size:cardinal;

  fff:TextFile;

  flg,pos,nach,ln:cardinal;


begin

fil:=CreateFile(@paramstr(1)[1],GENERIC_ALL,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,s2);
ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.Internal:=0;
ovr.InternalHigh:=0;

size:=GetFileSize(fil,nil);

buff:=GetMemory(size);

ReadFileEx(fil,buff,size,@ovr,nil);

CloseHandle(fil);

nach:=0;
ln:=0;
pos:=0;
flg:=0;
str2:=extractfilepath(paramstr(0));
AssignFile(fff,str2+'Texts.txt');
Rewrite(fff);
while pos<size do
  begin

  if pos=size-3 then break;

  if pbyte(cardinal(buff)+pos)^=ord(';') then
    while (pbyte(cardinal(buff)+pos)^<>$0D) do
        pos:=pos+1;

  

  if (pcardinal(cardinal(buff)+pos)^ and $FFFFFF)=$73656D then
    begin
      pos:=pos+3;


      nach:=0;
      while pbyte(cardinal(buff)+pos)^<>$22 do
        begin
        if pbyte(cardinal(buff)+pos)^<>$20 then nach:=$FFFFFFFF;

        pos:=pos+1;
        end;

      if nach<>$FFFFFFFF then
      begin

      pos:=pos+1;

      nach:=pos;
      ln:=0;


      while (pbyte(cardinal(buff)+pos)^<>$22) AND (pbyte(cardinal(buff)+pos)^<>$0D) do
      begin
        if pbyte(cardinal(buff)+pos)^>$80 then
            pos:=pos+1;

        pos:=pos+1;
      end;

      ln:=pos-nach;

      ZeroMemory(@str[0],1024);

      CopyMemory(@str[0],pointer(cardinal(buff)+nach),ln);

      
      str2:=Format('<ID %4u>',[flg]);
      str3:=Format('<A 0x%.8x,Ln 0x%.4u>',[nach,ln]);

      Writeln(fff,str2,pansichar(@str[0]),str3);

      flg:=flg+1;
      end;
    end;
  


  pos:=pos+1;
  end;
CloseFile(fff);




  { TODO -oUser -cConsole Main : Insert code here }
end.
