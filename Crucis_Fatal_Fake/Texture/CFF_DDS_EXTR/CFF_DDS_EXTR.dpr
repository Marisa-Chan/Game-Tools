program CFF_DDS_EXTR;

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


type
  pdat=^dat;
  dat=array [0..2] of char;

  pmelopan=^melopan;
  melopan=record
  txt:string;
  offset:cardinal;
  size:cardinal;
  end;

var

pck:string;

br:cardinal;
ss:Cardinal;
ovr:OVERLAPPED;

list:TList;

i,j,k,size,fisize:Cardinal;

buff:pointer;


dir,srcdir,dstdir:string;
fil:TextFile;

bf:pdat;


entrs:cardinal;
tmp:pmelopan;
ptmpst:Pchar;


begin

dir:=ParamStr(1);

//if not(DirectoryExists(dir+'src')) then exit;

//if not(DirectoryExists(dir+'dst')) then CreateDir(dir+'dst');

srcdir:=leftstr(dir,length(dir)-4)+'\';
dstdir:=srcdir+'dat.tmp';
if not(DirectoryExists(srcdir)) then CreateDir(leftstr(dir,length(dir)-3));
//dstdir:=dir+'dst\';

CopyFile(@dir[1],@dstdir[1],false);

AssignFile(fil,srcdir+'files.txt');


Rewrite(fil);



 pck:=dir;

    br:=CreateFile(@pck[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);

     size:=GetFileSize(br,@ss);
     buff:=GetMemory(size);

     ovr.OffsetHigh:=0;
     ovr.Offset:=0;
     ReadFileEx(br,buff,size,@ovr,nil);
     closehandle(br);

     entrs:=0;
 //    tmpst:='';
 list:=TList.Create;
 i:=0;
     while i<= size-3 do
        begin

        bf:=pdat(i+cardinal(buff));

        if (bf[0]='D') and (bf[1]='D') and (bf[2]='S') then
          begin



          entrs:=entrs+1;

          fisize:=pcardinal(i+cardinal(buff)-4)^;

          pck:=srcdir+inttostr(entrs)+'.dds';

          br:=CreateFile(@pck[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

          ovr.OffsetHigh:=0;
          ovr.Internal:=0;
          ovr.InternalHigh:=0;
          ovr.hEvent:=0;
          ovr.Offset:=0;

          WriteFileEx(br,pointer(i+cardinal(buff)),fisize,ovr,nil);


          closehandle(br);


          //tmpst:=StringOfChar(' ',j-i);
          //CopyMemory(@tmpst[1],pointer(i+cardinal(buff)),j-i);


          new(tmp);
          tmp.txt:=inttostr(entrs)+'.dds';
          tmp.offset:=i;
          tmp.size:=fisize;

          list.Add(tmp);

          i:=i+tmp.size;

          end;
          
        i:=i+1;
        end;




     freemem(buff);

     if entrs>0 then
      begin
      writeln(fil,inttostr(entrs));
        for k := 0 to List.Count - 1 do
           begin
           writeln(fil,pmelopan(list.Items[k]).txt);
           writeln(fil,inttostr(pmelopan(list.Items[k]).offset));
           writeln(fil,inttostr(pmelopan(list.Items[k]).size));
           end;

           
      for k := List.Count - 1 downto 0 do
        begin
        Dispose(pmelopan(list.Items[k]));
        end;

      end;

 list.Destroy;



//ScanDir(dir+'src\','',false);

CloseFile(fil);



  { TODO -oUser -cConsole Main : Insert code here }
end.
