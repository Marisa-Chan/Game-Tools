#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/types.h>
#include <dirent.h>
#include <libgen.h>
#include <fstream>
#include <list>

using namespace std;




struct header
{
   uint32_t magic;  //0x43415049 ()
   uint16_t count;
   uint16_t unk; // May be entry count
};


struct f_entry
{
   char     name[0x24];
   uint32_t offset;
   uint32_t size;
};






void unXor(uint8_t *buf,uint32_t size)
{
    for (uint32_t i=0;i<size;i++)
       buf[i]=(i & 0xFF) ^ buf[i];

}


uint32_t lzw(uint8_t *dst,uint8_t *src,uint32_t size)
{
uint8_t     lz[0x1000];
uint32_t    lz_pos=0x0fee;
uint32_t    cur=0, d_cur=0, otsk;
uint8_t     bl,mk,lw,hi;

uint32_t    pred,sei; //это для поиска
uint8_t     p_dl,dl; //длинна того что нашли

uint8_t     srv[18];
uint8_t     chars;
uint32_t    sz;

memset(&lz[0],0x20,0x1000);
mk=0;
bl=1;
sei=0;
sz=1;
d_cur=1;
while(cur<size)
    {

    p_dl=0;
    dl=0;
    pred=0;
    memset(srv,0,18);
    for (chars=0;chars<18;chars++)
        {
            if ((cur+chars) >= size) break;
            srv[chars]=src[cur+chars];
        }
    otsk=0;
    while (otsk<0x1000)
        {
            for(dl=0;dl<chars;dl++)
                {
                if (srv[dl]!=lz[(otsk+dl) & 0xFFF]) break;
                if ((otsk+dl)==(lz_pos-1)) break;
                }

            if (p_dl<dl)
                {
                    p_dl=dl;
                    pred=otsk;
                }

            otsk++;
        }

    if (p_dl>=3)
        {
            lw=pred & 0xFF;
            hi=((p_dl-3) & 0xf) | ((pred & 0xF00) >> 4);
            for (chars=0;chars<p_dl;chars++)
                {
                    lz[lz_pos]=src[cur];
                    cur++;
                    lz_pos=(lz_pos+1) & 0xFFF;
                }

            dst[d_cur]=lw;
            dst[d_cur+1]=hi;

            d_cur+=2;

            sz+=2;

            cur--;
        }
    else
        {
            dst[d_cur]=src[cur];
            lz[lz_pos]=src[cur];
            lz_pos=(lz_pos+1) & 0xFFF;
            mk=mk | bl;
            sz++;
            d_cur++;
        }


    if (bl==0x80)
    {
        dst[sei]=mk;
        mk=0;
        bl=1;
        sei=d_cur;
        d_cur++;
        sz++;
    }
    else
    {
        bl=bl<<1;
    }

    cur++;
    }
    dst[sei]=mk;

return sz;
};


string ExtractFileName(string st)
{
string      var;
uint32_t    i;


for (i=st.length();i>=1;i--)
    if ((st[i]=='/') || (st[i]=='\\')) break;


var=st.substr(i,st.length()-i);

return var;

}

string ExtractName(string st)
{
string      var;
uint32_t    i;

i=st.find('.');
if (i!=0)
    var=st.substr(0,i);
else
    var=st;

return var;
}

string ExtractPath(string st)
{
string      var;
uint32_t    i;

for (i=st.length();i>=1;i--)
    if ((st[i]=='/') || (st[i]=='\\')) break;

var=st.substr(0,i);

return var;
}





DIR *dirr;
struct dirent *dp;


int main(int argc, char *argv[])
{
FILE * fil, *fil2;
string st,st2;
void *pkd,*unpkd;
header hh;

uint32_t j;

f_entry *fent;

string dir,path;

void * buff, *buff2;

uint32_t cont,sz,pksz,sect,sz2;

void *pk;

uint32_t triapk;

dir=ExtractPath(argv[0]);
cont=0;

st2=argv[1];
if ((st2[st2.length()-1]!='/') || (st2[st2.length()-1]!='\\'))
    st2+="/";

if (argc>1)
    {
        dirr = opendir (st2.c_str());//////////////////////////очень тупо, просто лень... надо на СПИСКАХ делать было..
        dp = readdir(dirr);

      while(dp != NULL)
        {
            if ((strcmp(dp->d_name,".")!=0) && (strcmp(dp->d_name,"..")!=0))
            {
                cont++;
            }
            dp = readdir(dirr);
        }
        closedir(dirr);////////////////////////////////////очень тупо, просто лень... надо на СПИСКАХ делать было..


        memset(&hh,0,sizeof(hh));

        buff=malloc(cont*0x2C);

        memset(buff,0,cont*0x2C);



        dirr = opendir (st2.c_str());
        dp = readdir(dirr);


        j=0;
        sz=0;

        while(dp != NULL)
        {
            if ((strcmp(dp->d_name,".")!=0) && (strcmp(dp->d_name,"..")!=0))
            {
                path=st2;
                path+=dp->d_name;

                fil=fopen(path.c_str(),"rb");
                fseek(fil,0,SEEK_END);
                memcpy((void *)((f_entry *)buff)[j].name,(void *)(dp->d_name),strlen(dp->d_name));
                //((f_entry *)buff)[j].size=ftell(fil);
                //((f_entry *)buff)[j].offset=sz;

                sz+=ftell(fil);

                fclose(fil);

                j++;
            }
            dp = readdir(dirr);
        }
        closedir(dirr);

        sect=cont*0x2C;


        hh.unk=0x77CF;
        hh.count=cont;
        hh.magic=0x43415049;


        fil2=fopen("./output.PAK","wb");
        fwrite(&hh,sizeof(hh),1,fil2);
        fwrite(buff,sect,1,fil2);

        dirr = opendir (st2.c_str());
        dp = readdir(dirr);

        j=0;
        sz=0;
        sz2=sizeof(hh)+hh.count*0x2C;
        while(dp != NULL)
        {
            if ((strcmp(dp->d_name,".")!=0) && (strcmp(dp->d_name,"..")!=0))
            {
                path=st2;
                path+=dp->d_name;

                fil=fopen(path.c_str(),"rb");

                fseek(fil,0,SEEK_END);
                sz=ftell(fil);
                buff2=malloc(sz);


                fseek(fil,0,SEEK_SET);
                fread(buff2,sz,1,fil);

                pk=malloc(sz*2);

                pksz=lzw((uint8_t *)pk,(uint8_t *)buff2,sz);

                triapk=0x314C4549;
                fwrite(&triapk,4,1,fil2);
                fwrite(&sz,4,1,fil2);

                fwrite(pk,pksz,1,fil2);

                sz=pksz+8;
                ((f_entry *)buff)[j].size=sz;
                ((f_entry *)buff)[j].offset=sz2;

                sz2+=sz;


                free(buff2);
                free(pk);

                fclose(fil);

                j++;
            }
            dp = readdir(dirr);
        }
        closedir(dirr);

        fseek(fil2,sizeof(hh),SEEK_SET);
        fwrite(buff,sect,1,fil2);


        fclose(fil2);


        }



    return 0;
}
