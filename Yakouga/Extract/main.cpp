#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

using namespace std;




unsigned char table[]= {0xCE, 0x43, 0xBD, 0xDC, 0xCE, 0x98, 0xC8, 0xB9, 0x89, 0x4B, 0xA5, 0xFE};



void uncrypt(uint8_t *buf,uint32_t cnt,uint32_t unk,char *tab)
{
    uint32_t ostatok;
    ostatok = unk % 0xC;

    uint32_t cont = cnt;

    uint32_t psss;
    uint32_t brrr;

    psss=0;

    if (cont>0xC)
    {
        bool exit=false;
        brrr=unk;
        if (!unk)
        {
            uint32_t ed=cont;
            do
            {
                buf[psss]^=tab[brrr];
                psss++;
                brrr++;
                ed--;
            }
            while (brrr<0xC);
            unk=0;
            cont=ed;

            if (ed<0xC) exit=true;

        }

        if (!exit)
        {
            uint32_t lp=cont/0xC;
            cont%=0xC;

            uint32_t ex1,ex2,ex3;
            ex1=*(uint32_t *)(&tab[0]);
            ex2=*(uint32_t *)(&tab[4]);
            ex3=*(uint32_t *)(&tab[8]);

            while (lp)
            {
                *(uint32_t *)(&buf[psss])^=ex1;
                *(uint32_t *)(&buf[psss+4])^=ex2;
                *(uint32_t *)(&buf[psss+8])^=ex3;
                psss+=0xC;
                lp--;
            }
        }
    }

    if (cont)
    {
        brrr=unk;

        while (cont)
        {
            buf[psss]^=tab[brrr];
            psss++;
            brrr++;
            if (brrr>=0xC) brrr=0;

            cont--;
        }
    }
};



int main()
{
    FILE *fl=fopen ("data.dat","rb");
    fseek(fl,0,SEEK_END);

    uint32_t fsz=ftell(fl);
    fseek(fl,0,SEEK_SET);



    uint8_t *pam=(uint8_t *)malloc(fsz);

    fread(&pam[0],1,fsz,fl);


    fclose(fl);

    int j=0;
  uint32_t i;
    for (i=0;i<fsz;i++)
    {
        pam[i]=pam[i] ^ table[j];
        j++;
        if (j==0xC) j=0;
    }

    FILE *flfl=fopen ("out.out","wb");
    fwrite(&pam[0],1,fsz,flfl);
    fclose(flfl);


    //cout << table<<"Hello world!" << endl;*/
    return 0;
}
