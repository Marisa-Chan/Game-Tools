program wcg_unp;

{$APPTYPE CONSOLE}

uses
  SysUtils,windows,
  pngimage,strutils;

var
  img:TPNGObject;

  pck:string;
fil:cardinal;
ss:cardinal;
ovr:OVERLAPPED;

width,height:cardinal;


dir:string;

buff:pointer;
offset:cardinal;
files:cardinal;

tm,tm2,tm3,tm4,tm5,tm6,tm7,k,j,jj:cardinal;

  cbit,cpointer:cardinal;

ou,tabl,pam:pointer;


function get_bits(num:integer):integer;
var
i,tmp:cardinal;
begin
Result:=0;

for i := num - 1 downto 0 do
begin

tmp:=pbyte(cpointer)^;
if ((tmp shr (7-cbit)) and 1) = 1 then
result:=result or (1 shl i);

cbit:=cbit+1;
if (cbit and 7)<>cbit then
  begin
    cpointer:=cpointer + 1;
    cbit:=cbit and 7;
  end;


end;


end;


function hih(param:integer):cardinal;
var
tmp:cardinal;
begin

case (param-1) of
  0:
  begin
   Result:=get_bits(1);
  end;
  1:
  begin
    Result:=get_bits(1) or 2;
  end;
  2:
  begin
    Result:=get_bits(2) or 4;
  end;
  3:
  begin
    Result:=get_bits(3) or 8;
  end;
  4:
  begin
    Result:=get_bits(4) or $10;
  end;
  5:
  begin
    Result:=get_bits(5) or $20;
  end;
  6:
  begin
    if get_bits(1)=1 then
      begin
        if get_bits(1)=1 then
          begin

            if get_bits(1)=1 then
              begin

                if get_bits(1)=1 then
                  begin

                    if get_bits(1)=1 then
                      begin

                        if get_bits(1)=1 then
                          begin

                          end
                          else
                          begin
                          Result:=get_bits(11) or $800;
                          end;

                      end
                    else
                      begin
                      Result:=get_bits(10) or $400;
                      end;

                  end
                else
                  begin
                  Result:=get_bits(9) or $200;
                  end;

              end
            else
              begin
              Result:=get_bits(8) or $100;
              end;

          end
        else
          begin
          Result:=get_bits(7) or $80;
          end;
      end
    else
    begin
     Result:=get_bits(6) or $40;
    end;


  end;

end;

end;


function hih2(param:integer):cardinal;
var
tmp:cardinal;
begin

case (param-1) of
  0:
  begin
   Result:=get_bits(1);
  end;
  1:
  begin
    Result:=get_bits(1) or 2;
  end;
  2:
  begin
    Result:=get_bits(2) or 4;
  end;
  3:
  begin
    Result:=get_bits(3) or 8;
  end;
  4:
  begin
    Result:=get_bits(4) or $10;
  end;
  5:
  begin
    Result:=get_bits(5) or $20;
  end;
  6:
  begin
    Result:=get_bits(6) or $40;
  end;
  7:
  begin
    Result:=get_bits(7) or $80;
  end;
  8:
  begin
    Result:=get_bits(8) or $100;
  end;
  9:
  begin
    Result:=get_bits(9) or $200;
  end;
  10:
  begin
    Result:=get_bits(10) or $400;
  end;
  11:
  begin
    Result:=get_bits(11) or $800;
  end;
  12:
  begin
    Result:=get_bits(12) or $1000;
  end;
  13:
  begin
    Result:=get_bits(13) or $2000;
  end;
  14:
  begin
    if get_bits(1)=1 then
    begin
    get_bits(1);
    Result:=get_bits(15) or $8000;
    end
    else
    begin
     Result:=get_bits(14) or $4000;
    end;
  end;


  end;


end;


begin

for jj := 1 to ParamCount  do
begin
pck:=ParamStr(jj);

fil:=CreateFile(@pck[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,ss);


ovr.Offset:=8;
ovr.OffsetHigh:=0;
ReadFileEx(fil,@width,4,@ovr,nil);
ovr.Offset:=12;
ReadFileEx(fil,@height,4,@ovr,nil);


ovr.Offset:=16;
ReadFileEx(fil,@tm,4,@ovr,nil);
ovr.Offset:=20;
ReadFileEx(fil,@tm2,4,@ovr,nil);
ovr.Offset:=24;
tm3:=0;
ReadFileEx(fil,@tm3,2,@ovr,nil);

ou:=GetMemory(tm+100);
ZeroMemory(ou,tm+100);

tabl:=GetMemory(tm3*2);
ZeroMemory(tabl,tm3*2);

pam:=GetMemory(tm2+100);
ZeroMemory(pam,tm2+100);

ovr.Offset:=28;
ReadFileEx(fil,tabl,tm3*2,@ovr,nil);

ovr.Offset:=28+tm3*2;
ReadFileEx(fil,pam,tm2,@ovr,nil);

offset:=28+tm3*2+tm2;

cbit:=0;
cpointer:=cardinal(pam);

tm4:=0;

while cpointer<(cardinal(pam)+tm2) do
begin

if tm3>$1000 then
tm5:=get_bits(4)
else
tm5:=get_bits(3);

  if tm5=0 then
begin

tm6:=get_bits(4)+2;

if tm3>$1000 then
tm7:=get_bits(4)
else
tm7:=get_bits(3);

if tm3>$1000 then
tm7:=pword(cardinal(tabl)+hih2(tm7)*2)^
else
tm7:=pword(cardinal(tabl)+hih(tm7)*2)^;


for j := 0 to tm6-1 do
begin
pword(cardinal(ou)+tm4)^:=word(tm7);
  tm4:=tm4+2;
end;
end

  else

begin
if tm3>$1000 then
tm6:=pword(cardinal(tabl)+hih2(tm5)*2)^
else
tm6:=pword(cardinal(tabl)+hih(tm5)*2)^;

pword(cardinal(ou)+tm4)^:=word(tm6);
tm4:=tm4+2;

end;

end;

img:=TPNGObject.CreateBlank(COLOR_RGBALPHA,8,width,height);
for k := 0 to height-1 do
  for j := 0 to width- 1 do
    begin
      tm6:=pword(cardinal(ou)+j*2+k*width*2)^;
      tm7:=tm6 and $FF;
      tm6:=tm6 shr 8;
      pbyte(cardinal(img.AlphaScanline[k])+j)^:=255-byte(tm6);
      pbyte(cardinal(img.Scanline[k])+j*3+2)^:=byte(tm7);

    end;


Dispose(pam);
Dispose(tabl);
Dispose(ou);


//#####################################
//img.SaveToFile('C:\out.png');

ovr.Offset:=offset;
ReadFileEx(fil,@tm,4,@ovr,nil);
ovr.Offset:=offset+4;
ReadFileEx(fil,@tm2,4,@ovr,nil);
ovr.Offset:=offset+8;
ReadFileEx(fil,@tm3,2,@ovr,nil);

ou:=GetMemory(tm+100);
ZeroMemory(ou,tm+100);

tabl:=GetMemory(tm3*2);
ZeroMemory(tabl,tm3*2);

pam:=GetMemory(tm2+100);
ZeroMemory(pam,tm2+100);

ovr.Offset:=offset+12;
ReadFileEx(fil,tabl,tm3*2,@ovr,nil);

ovr.Offset:=offset+12+tm3*2;
ReadFileEx(fil,pam,tm2,@ovr,nil);


cbit:=0;
cpointer:=cardinal(pam);

tm4:=0;

while cpointer<(cardinal(pam)+tm2) do
begin

if tm3>$1000 then
tm5:=get_bits(4)
else
tm5:=get_bits(3);
  if tm5=0 then
begin

tm6:=get_bits(4)+2;

if tm3>$1000 then
tm7:=get_bits(4)
else
tm7:=get_bits(3);

if tm3>$1000 then
tm7:=pword(cardinal(tabl)+hih2(tm7)*2)^
else
tm7:=pword(cardinal(tabl)+hih(tm7)*2)^;
for j := 0 to tm6-1 do
begin
pword(cardinal(ou)+tm4)^:=word(tm7);
  tm4:=tm4+2;
end;
end

  else

begin

if tm3>$1000 then
tm6:=pword(cardinal(tabl)+hih2(tm5)*2)^
else
tm6:=pword(cardinal(tabl)+hih(tm5)*2)^;
pword(cardinal(ou)+tm4)^:=word(tm6);
tm4:=tm4+2;

end;

end;


for k := 0 to height-1 do
  for j := 0 to width- 1 do
    begin
      tm6:=pword(cardinal(ou)+j*2+k*width*2)^;
      pword(cardinal(img.Scanline[k])+j*3)^:=word(tm6);

    end;

Dispose(pam);
Dispose(tabl);
Dispose(ou);

img.SaveToFile(leftstr(ParamStr(jj),length(ParamStr(jj))-3)+'png');


CloseHandle(fil);

 end;

  { TODO -oUser -cConsole Main : Insert code here }
end.
