program wcg_pk;

{$APPTYPE CONSOLE}

uses
  SysUtils,windows,classes,pngimage,strutils,CRT32;

type
  pbla=^bla;
  bla=record
  num:cardinal;
  count:cardinal;
  index:Cardinal;
  end;

var
  table,imglink:TList;
  img:TPNGObject;

  i,j,k,kk:cardinal;
  tmbl:pbla;
  tmpclr,offset:Cardinal;
  est:boolean;

  tmp1,tmp2,tmp3,tmp4:cardinal;

  ou:Pointer;

  bit:cardinal;
  byt:cardinal;

  tmst,tmst2:string;



    pck:string;
fil:cardinal;
ss:cardinal;
ovr:OVERLAPPED;

procedure progress(st:string;val:Integer);
begin
DelLine;
GotoXY(0,WhereY);
write(st + ' '+IntToStr(val)+'%');
end;


function getrej(val:integer):integer;
var
bg,bgtmp:cardinal;
begin

Result:=0;

for bg := 15 downto 0 do
  begin
  if ((val shr bg) and 1) = 1 then
    begin
      Result:=bg;
      exit;
    end;


  end;


end;




procedure b_puts(bits,value:cardinal);
var
bg,bgtmp:cardinal;
ess:Boolean;
begin

for bg := bits-1 downto 0 do
  begin
  bgtmp:=0;
  bgtmp:=((value shr bg) and 1) shl bit;
  pbyte(cardinal(ou)+byt)^:=pbyte(cardinal(ou)+byt)^ or bgtmp;

  ess:=true;

  if bit>0 then
  begin
  bit:=bit-1;
  ess:=false;
  end
  else
    begin
    if ess then
    begin
      bit:=7;
      byt:=byt+1;
    end;
    end;


  end;
  
end;


procedure write4(val,rej:cardinal);
begin
case rej of
1: b_puts(1,val);
2: b_puts(1,val);
3: b_puts(2,val);
4: b_puts(3,val);
5: b_puts(4,val);
6: b_puts(5,val);
7: b_puts(6,val);
8: b_puts(7,val);
9: b_puts(8,val);
10: b_puts(9,val);
11: b_puts(10,val);
12: b_puts(11,val);
13: b_puts(12,val);
14: b_puts(13,val);
15: begin b_puts(1,0); b_puts(14,val); end;
16: begin b_puts(1,1); b_puts(1,0); b_puts(15,val); end;

end;

end;

procedure write3(val,rej:cardinal);
begin
case rej of
1: b_puts(1,val);
2: b_puts(1,val);
3: b_puts(2,val);
4: b_puts(3,val);
5: b_puts(4,val);
6: b_puts(5,val);
7: begin b_puts(1,0); b_puts(6,val); end;
8: begin b_puts(1,1); b_puts(1,0); b_puts(7,val);   end;
9: begin b_puts(1,1); b_puts(1,1); b_puts(1,0); b_puts(8,val);  end;
10: begin b_puts(1,1); b_puts(1,1); b_puts(1,1); b_puts(1,0); b_puts(9,val); end;
11: begin b_puts(1,1); b_puts(1,1); b_puts(1,1); b_puts(1,1); b_puts(1,0); b_puts(10,val);  end;
12: begin b_puts(1,1); b_puts(1,1); b_puts(1,1); b_puts(1,1); b_puts(1,1); b_puts(1,0); b_puts(11,val);   end;


end;

end;

begin

if ParamCount>0 then
for kk := 1 to ParamCount  do
begin


write(ParamStr(kk));

img:=TPNGObject.Create;
img.LoadFromFile(ParamStr(kk));

 table:=TList.Create;
 imglink:=TList.Create;

 //###### CREATE TABLE #########
 for j := 0 to img.Height - 1 do
  for I := 0 to img.Width-1 do
    begin
    tmpclr:=pbyte(cardinal(img.scanline[j])+i*3+2)^ or ((255-pbyte(cardinal(img.alphascanline[j])+i)^) shl 8);
    est:=false;

    if table.Count>0 then

    for k := 0 to table.Count - 1 do
      if pbla(table.Items[k]).num=tmpclr then
        begin
          est:=true;
          pbla(table.Items[k]).count:=pbla(table.Items[k]).count+1;
          imglink.Add(pbla(table.Items[k]));
          break;
        end;

    if not(est) then
      begin
        new(tmbl);
        tmbl.num:=tmpclr;
        tmbl.count:=1;
        table.Add(tmbl);
        imglink.Add(tmbl);
      end;

  //  progress(ParamStr(kk),round((10.0/(img.Height*img.Width))*(I*j)));

    end;
 //#############################



 //###### SORT TABLE #########
 if table.Count>2 then
 for i := 0 to table.Count - 3 do
   for j := 0 to table.Count - 2 do
    if pbla(table.Items[j]).count<pbla(table.Items[j+1]).count then
     begin
     tmbl:=pbla(table.Items[j]);
     table.Items[j]:=table.Items[j+1];
     table.Items[j+1]:=tmbl;

//     progress(ParamStr(kk),10+round((15.0/((table.Count-3)*(table.Count-2)))*(I*j)));
     end;
 //############################

for k := 0 to table.Count - 1 do
  pbla(table.Items[k]).index:=k;

byt:=0;
bit:=7;

ou:=GetMemory(img.Width*img.Height*8);
ZeroMemory(ou,img.Width*img.Height*8);


//DelLine;
//GotoXY(0,WhereY);
//write(ParamStr(kk) + '50%');


tmp1:=0;
tmp2:=0;
while tmp1<imglink.Count do
  begin
  est:=true;

  tmp3:=0;
  if ((imglink.Count-1)-tmp1)<=$10 then
    tmp3:=$11-((imglink.Count-1)-tmp1);



  if ((imglink.Count-1)-tmp1)>1 then
  for tmp2 := tmp1 to (tmp1+$10-tmp3) do
    if cardinal(imglink.Items[tmp2])<>cardinal(imglink.Items[tmp2+1]) then
      begin
        est:=false;
        break;
      end;

      if est then
      tmp2:=tmp2-1;

  if tmp2>=tmp1+1 then
    begin
    tmp3:=getrej(pbla(imglink.Items[tmp1]).index);
    tmp3:=tmp3+1;
    
    if table.Count>$1000 then
      begin
      b_puts(4,0);
      b_puts(4,tmp2-tmp1-1);

      tmp4:=tmp3;
      if tmp4>15 then tmp4:=15;
      b_puts(4,tmp4);
      write4(pbla(imglink.Items[tmp1]).index,tmp3);
      end
    else
      begin
      b_puts(3,0);

      b_puts(4,tmp2-tmp1-1);

      tmp4:=tmp3;
      if tmp4>7 then tmp4:=7;
      b_puts(3,tmp4);
      write3(pbla(imglink.Items[tmp1]).index,tmp3);

      end;


    tmp1:=tmp2+1;
    end
  else
    begin

    tmp3:=getrej(pbla(imglink.Items[tmp1]).index);
    tmp3:=tmp3+1;
    if table.Count>$1000 then
      begin
      tmp4:=tmp3;
      if tmp4>15 then tmp4:=15;
      b_puts(4,tmp4);
      write4(pbla(imglink.Items[tmp1]).index,tmp3);
      end
    else
      begin
      tmp4:=tmp3;
      if tmp4>7 then tmp4:=7;
      b_puts(3,tmp4);
      write3(pbla(imglink.Items[tmp1]).index,tmp3);

      end;


    tmp1:=tmp1+1;
   end;


//progress(ParamStr(kk),25+round((25.0/(imglink.Count))*(tmp1)));
  end;


//progress(ParamStr(kk),50);


pck:=LeftStr(ParamStr(kk),Length(ParamStr(kk))-3)+'wcg';

fil:=CreateFile(@pck[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

tmp4:=$2714757;

ovr.Offset:=0;
ovr.OffsetHigh:=0;

WriteFileEx(fil,@tmp4,4,ovr,nil);

tmp4:=$40000020;

ovr.Offset:=4;

WriteFileEx(fil,@tmp4,4,ovr,nil);


ovr.Offset:=8;
tmp4:=img.Width;
WriteFileEx(fil,@tmp4,4,ovr,nil);

ovr.Offset:=12;
tmp4:=img.Height;
WriteFileEx(fil,@tmp4,4,ovr,nil);

ovr.Offset:=16;
tmp4:=img.Width*img.Height*2;
WriteFileEx(fil,@tmp4,4,ovr,nil);

ovr.Offset:=20;
tmp4:=byt+2;
WriteFileEx(fil,@tmp4,4,ovr,nil);

ovr.Offset:=24;
tmp4:=table.Count;
WriteFileEx(fil,@tmp4,4,ovr,nil);

offset:=28;

for I := 0 to table.Count - 1 do
begin
  ovr.Offset:=offset;
  tmp4:=pbla(table.Items[i]).num;
  WriteFileEx(fil,@tmp4,2,ovr,nil);
  offset:=offset+2;
end;

ovr.Offset:=offset;
writeFileEx(fil,ou,byt+2,ovr,nil);


offset:=offset+byt+2;




for I := 0 to table.Count - 1 do
  begin
    Dispose(pbla(table.Items[i]));
  end;

table.Clear;
table.Destroy;

imglink.Clear;
imglink.Destroy;

  Dispose(ou);








 table:=TList.Create;
 imglink:=TList.Create;

 //###### CREATE TABLE #########
 for j := 0 to img.Height - 1 do
  for I := 0 to img.Width-1 do
    begin
    tmpclr:=pword(cardinal(img.scanline[j])+i*3)^;
    est:=false;

    if table.Count>0 then
    
    for k := 0 to table.Count - 1 do
      if pbla(table.Items[k]).num=tmpclr then
        begin
          est:=true;
          pbla(table.Items[k]).count:=pbla(table.Items[k]).count+1;
          imglink.Add(pbla(table.Items[k]));
          break;
        end;

    if not(est) then
      begin
        new(tmbl);
        tmbl.num:=tmpclr;
        tmbl.count:=1;
        table.Add(tmbl);
        imglink.Add(tmbl);
      end;


    end;
 //#############################


 //###### SORT TABLE #########
if table.Count>2 then
 for i := 0 to table.Count - 2 do
   for j := 0 to table.Count - 2 do
    if pbla(table.Items[j]).count<pbla(table.Items[j+1]).count then
     begin
     tmbl:=pbla(table.Items[j]);
     table.Items[j]:=table.Items[j+1];
     table.Items[j+1]:=tmbl;
     end;
 //############################

for k := 0 to table.Count - 1 do
  pbla(table.Items[k]).index:=k;

byt:=0;
bit:=7;

ou:=GetMemory(img.Width*img.Height*8);
ZeroMemory(ou,img.Width*img.Height*8);


tmp1:=0;
tmp2:=0;
while tmp1<imglink.Count do
  begin
  est:=true;

  tmp3:=0;
  if ((imglink.Count-1)-tmp1)<=$10 then
    tmp3:=$11-((imglink.Count-1)-tmp1);

  if ((imglink.Count-1)-tmp1)>1 then
  for tmp2 := tmp1 to (tmp1+$10-tmp3) do
    if cardinal(imglink.Items[tmp2])<>cardinal(imglink.Items[tmp2+1]) then
      begin
        est:=false;
        break;
      end;

      if est then
      tmp2:=tmp2-1;
      
  if tmp2>=tmp1+1 then
    begin
    tmp3:=getrej(pbla(imglink.Items[tmp1]).index);
    tmp3:=tmp3+1;
    if table.Count>$1000 then
      begin
      b_puts(4,0);
      b_puts(4,tmp2-tmp1-1);

      tmp4:=tmp3;
      if tmp4>15 then tmp4:=15;
      b_puts(4,tmp4);
      write4(pbla(imglink.Items[tmp1]).index,tmp3);
      end
    else
      begin
      b_puts(3,0);

      b_puts(4,tmp2-tmp1-1);

      tmp4:=tmp3;
      if tmp4>7 then tmp4:=7;
      b_puts(3,tmp4);
      write3(pbla(imglink.Items[tmp1]).index,tmp3);

      end;


    tmp1:=tmp2+1;
    end
  else
    begin

    tmp3:=getrej(pbla(imglink.Items[tmp1]).index);
    tmp3:=tmp3+1;
    if table.Count>$1000 then
      begin
      tmp4:=tmp3;
      if tmp4>15 then tmp4:=15;
      b_puts(4,tmp4);
      write4(pbla(imglink.Items[tmp1]).index,tmp3);
      end
    else
      begin
      tmp4:=tmp3;
      if tmp4>7 then tmp4:=7;
      b_puts(3,tmp4);
      write3(pbla(imglink.Items[tmp1]).index,tmp3);

      end;


    tmp1:=tmp1+1;
    end;



  end;


ovr.Offset:=offset;
tmp4:=img.Width*img.Height*2;
WriteFileEx(fil,@tmp4,4,ovr,nil);

ovr.Offset:=offset+4;
tmp4:=byt+2;
WriteFileEx(fil,@tmp4,4,ovr,nil);

ovr.Offset:=offset+8;
tmp4:=table.Count;
WriteFileEx(fil,@tmp4,4,ovr,nil);

offset:=offset+12;

for I := 0 to table.Count - 1 do
begin
  ovr.Offset:=offset;
  tmp4:=pbla(table.Items[i]).num;
  WriteFileEx(fil,@tmp4,2,ovr,nil);
  offset:=offset+2;
end;

ovr.Offset:=offset;
writeFileEx(fil,ou,byt+2,ovr,nil);


offset:=offset+byt+2;


for I := 0 to table.Count - 1 do
  begin
    Dispose(pbla(table.Items[i]));
  end;

table.Clear;
table.Destroy;

imglink.Clear;
imglink.Destroy;




CloseHandle(fil);

 Dispose(ou);


img.Destroy;

DelLine;
GotoXY(0,WhereY);
writeln(ParamStr(kk)+'    OK');

end;
writeln('');
writeln('');
writeln('');
writeln('If you don`t know:');
writeln('                   People Die if they are killed!');
writeln('                                 Unknown FanSuber');
writeln('');
tmst2:='';
tmst:='Если читаете эту хуйню, значит прога закончила';
SetLength(tmst2,length(tmst));
CharToOem(@tmst[1],@tmst2[1]);
writeln(tmst2);
tmst:='  работать, и вам нехуй делать.';
SetLength(tmst2,length(tmst));
CharToOem(@tmst[1],@tmst2[1]);
writeln(tmst2);
writeln('');
writeln('');
tmst:='  И вообще, че за ХУЙню я тут написал....';
SetLength(tmst2,length(tmst));
CharToOem(@tmst[1],@tmst2[1]);
writeln(tmst2);
writeln('');
writeln('   ^_____^                               Zi, 2009');

Sleep(5000); 

  { TODO -oUser -cConsole Main : Insert code here }
end.
