program datfix;

{$APPTYPE CONSOLE}

uses
  windows,
  SysUtils,
  pngimage,
  Strutils;

var
img:TPNGObject;
  bpp,x,y,width,height,i,j,k,fils:Integer;
  fil,ss,tmp:Cardinal;
  ovr:OVERLAPPED;
  st1,st2,st3:string;

  heh:TRect;

  buff:string[255];

  ofs,ofs2,numb:integer;



begin

                 img:=TPNGObject.Create;

if ParamCount <1 then
writeln('Usage:  datfix *.dat');
if ParamCount < 1 then Halt;


st1:=ParamStr(1);

st2:=ExtractFilePath(st1);
if length(st2)>1 then
  begin if st2[length(st2)]<>'\' then st2:=st2+'\'; end
else
begin
  st2:=ParamStr(0);
  if st2[length(st2)]<>'\' then st2:=st2+'\';
end;


fil:=createfile(@st1[1],GENERIC_ALL,FILE_SHARE_READ or FILE_SHARE_WRITE ,nil,OPEN_ALWAYS ,FILE_ATTRIBUTE_NORMAL,ss);

ovr.Internal:=0;
ovr.InternalHigh:=0;
ovr.Offset:=4;
ovr.OffsetHigh:=0;
ovr.hEvent:=0;

ReadFileEx(fil,@fils,4,@ovr,nil);

ofs:=8;
for i := 1 to fils do
begin
  ovr.Offset:=ofs;
  readfileex(fil,@numb,4,@ovr,nil);

  ofs:=ofs+4;

  ovr.Offset:=ofs;

  buff:='';

  readfileex(fil,@buff[1],numb,@ovr,nil);
  setlength(buff,numb);
  setlength(st3,numb);
  st3:=buff;

  st3:=LeftStr(st3,pos('.',st3)-1);

  ofs:=ofs+numb;

  ofs2:=ofs;

  ofs:=ofs+4*4;
  writeln(st3);

  if FileExists(st2+st3+'.png') then
  begin
    writeln('exists');
  img.LoadFromFile(st2+st3+'.png');
     heh.Top:=img.Height;
              heh.Left:=img.Width;
              heh.Right:=0;
              heh.Bottom:=0;
      if img.Header.ColorType=COLOR_RGBALPHA then
        begin
          for j := 0 to img.Height - 1 do
            for k := 0 to img.Width - 1 do
              begin

              if (pbyte(cardinal(img.AlphaScanline[j])+k)^)<>0 then
                begin
                  if heh.top>j then heh.Top:=j;
                  if heh.Left>k then heh.Left:=k;
                  if heh.Right<k then heh.Right:=k;
                  if heh.Bottom<j then heh.Bottom:=j;
                end;
              end;
              
        heh.right:=heh.Right-heh.Left+1;
        heh.Bottom:=heh.Bottom-heh.Top+1;

        tmp:=0;

        ovr.Offset:=ofs2;
        tmp:=heh.Left;
        WriteFileEx(fil,@tmp,4,ovr,nil);

        ovr.Offset:=ofs2+4;
        tmp:=heh.Top;
        WriteFileEx(fil,@tmp,4,ovr,nil);

        ovr.Offset:=ofs2+8;
        tmp:=heh.Right;
        WriteFileEx(fil,@tmp,4,ovr,nil);

        ovr.Offset:=ofs2+12;
        tmp:=heh.Bottom;
        WriteFileEx(fil,@tmp,4,ovr,nil);


        end;
      

  end;





end;
  





closehandle(fil);

  { TODO -oUser -cConsole Main : Insert code here }
end.

