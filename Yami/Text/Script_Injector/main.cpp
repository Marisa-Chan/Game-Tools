#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/types.h>
#include <dirent.h>
#include <libgen.h>


using namespace std;

struct scw_header
{
    char        ident[0x10]; //SCW for GswSys
    uint32_t    magic1; //0x03000003
    uint32_t    magic2; //0xFFFFFFFF
    uint32_t    pkd_size;
    uint32_t    unpkd_size;
    uint32_t    unk1;
    uint32_t    unk2;
    uint32_t    cnt1;
    uint32_t    cnt2;//text count
    uint32_t    cnt3;
    uint32_t    scriptsize;//think it`s real script
    uint32_t    txt1_size;
    uint32_t    txt2_size;
    char        unk[0x48];
    char        descr[0x40];
};



DIR *dirr;
struct dirent *dp;


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

memset(&lz[0],0,0x1000);
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




void unlzw(uint8_t *dst,uint8_t *src,uint32_t size)
{
uint8_t     lz[0x1000];
uint32_t    lz_pos=0x0fee;
uint32_t    cur=0, d_cur=0, otsk;
uint8_t     bl,mk,i,j,lw,hi,loops;

memset(&lz[0],0,0x1000);

while(cur<size)
    {
    bl=src[cur];
    mk=1;

    for (i=0;i<=7;i++)
        {
        if ((bl & mk)==mk)
            {
            cur++;
            if (cur >= size) break;

            lz[lz_pos]=src[cur];

            dst[d_cur]=src[cur];

            d_cur++;
            lz_pos = (lz_pos+1) & 0xfff;
            }
        else
            {
            cur++;
            if (cur >= size) break;
            lw = src[cur];

            cur++;
            if (cur >= size) break;
            hi = src[cur];

            loops = (hi & 0xf)+2;

            otsk = lw | ((hi & 0xf0)<<4);

                for(j = 0; j <= loops;j++)
                    {
                    lz[lz_pos]=lz[(otsk+j) & 0xfff];
                    dst[d_cur]=lz[(otsk+j) & 0xfff];
                    lz_pos=(lz_pos+1) & 0xfff;
                    d_cur++;
                    }
            };

		mk=mk << 1;

        }

    cur++;
    };

}

void unXor(uint8_t *buf,uint32_t size)
{
    for (uint32_t i=0;i<size;i++)
       buf[i]=(i & 0xFF) ^ buf[i];

}


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

if (i!=-1)
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

var=st.substr(0,i+1);

return var;
}


int main(int argc, char *argv[])
{
FILE *fil;
FILE *fil2;
string st,st2;
void *pkd,*unpkd;
scw_header hh;

uint32_t ii;
uint32_t gg;
char * nuaf;

uint32_t j;

char *stroka;

char stirochka[1024];

void *buffer;
uint32_t    buff_pos,data_sz;

string dir,path,path2;


void *newunp, *newpk;
uint32_t newpkdsz,newunpkdsz;

void * buff;


dir=ExtractPath(argv[0])+"src/";
path=ExtractPath(argv[0])+"txt/";
path2=ExtractPath(argv[0])+"dst/";

mkdir(path2.c_str());

dirr = opendir (dir.c_str());
dp = readdir(dirr);
    while(dp != NULL)
        {
            if ((strcmp(dp->d_name,".")!=0) && (strcmp(dp->d_name,"..")!=0))
            {

            st2=dir+dp->d_name;

            fil=fopen(st2.c_str(),"rb");

            memset(&hh,0,sizeof(hh));


            fread(&hh,sizeof(hh),1,fil);


            pkd=malloc(hh.pkd_size);

            unpkd=malloc(hh.unpkd_size);

            memset(unpkd,0,hh.unpkd_size);

            fread(pkd,hh.pkd_size,1,fil); //reads packed script

            fclose(fil);

            unXor((uint8_t *)pkd,hh.pkd_size);

            unlzw((uint8_t *)unpkd,(uint8_t *)pkd,hh.pkd_size);

            st2=ExtractName(ExtractFileName(st2));


            st=path+st2+".txt";
                fil2=fopen(st.c_str(),"rb");
                fseek(fil2,0,SEEK_END);


                ii=ftell(fil2);
                buffer=malloc(ii*2);
                memset(buffer,0,ii*2);

                fseek(fil2,0,SEEK_SET);



            buff_pos=0;
            for (ii=0; ii<hh.cnt2;ii++)
                {
                    memset(stirochka,0,1024);
                    fgets(stirochka,1024,fil2);
                    stirochka[strlen(stirochka)-1]=0x00;
                    stroka=(char *)malloc(strlen(stirochka)+1);
                    memset(stroka,0,strlen(stirochka)+1);

                    j=0;
                    for (int jj=0;jj<strlen(stirochka);jj++)
                        {
                            if ((stirochka[jj]=='\\') && (stirochka[jj+1]=='n'))
                                {
                                stroka[j]=0x0A;
                                jj++;
                                }
                            else
                                {
                                stroka[j]=stirochka[jj];
                                }
                            j++;

                        }


                    *(uint32_t *)((uint32_t)unpkd+(hh.cnt1+ii) *0x10)=buff_pos;
                    *(uint32_t *)((uint32_t)unpkd+(hh.cnt1+ii) *0x10+0x08)=strlen(stroka)+1;

                    memcpy((void *)((uint32_t)buffer + buff_pos),(void *)stroka,strlen(stroka));

                    buff_pos+=strlen(stroka)+1;


                    free(stroka);
                };
                fclose(fil2);


            newunp=malloc(((hh.cnt1 +hh.cnt2+hh.cnt3)<< 4)+hh.scriptsize+buff_pos+hh.txt2_size);

            memcpy(newunp,unpkd,((hh.cnt1 +hh.cnt2+hh.cnt3)<< 4)+hh.scriptsize);

            memcpy((void *)(&((char *)newunp)[((hh.cnt1 +hh.cnt2+hh.cnt3)<< 4)+hh.scriptsize]),buffer,buff_pos);

            memcpy((void *)(&((char *)newunp)[((hh.cnt1 +hh.cnt2+hh.cnt3)<< 4)+hh.scriptsize+buff_pos]),(void *)(&((char *)unpkd)[((hh.cnt1 +hh.cnt2+hh.cnt3)<< 4)+hh.scriptsize+hh.txt1_size]),hh.txt2_size);

            newunpkdsz=((hh.cnt1 +hh.cnt2+hh.cnt3)<< 4)+hh.scriptsize+buff_pos+hh.txt2_size;


           /*fil2=fopen("./ooo","wb");
            fwrite(newunp,newunpkdsz,1,fil2);
            fclose(fil2);*/


            newpk=malloc(newunpkdsz*2);

            memset(newpk,0,newunpkdsz*2);

            newpkdsz=lzw((uint8_t *)newpk,(uint8_t *)newunp,newunpkdsz);

            unXor((uint8_t *)newpk,newpkdsz);




            hh.txt1_size=buff_pos;
            hh.unpkd_size=newunpkdsz;
            hh.pkd_size=newpkdsz;

            st=path2+st2;
            fil2=fopen(st.c_str(),"wb");
            fwrite(&hh,sizeof(hh),1,fil2);
            fwrite(newpk,newpkdsz,1,fil2);
            fclose(fil2);

            free(buffer);
            free(newunp);
            free(newpk);


            free(unpkd);
            free(pkd);


            }

            dp = readdir(dirr);

    }





    return 0;
}
