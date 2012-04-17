#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <inttypes.h>

using namespace std;


struct section
{
    char        ObjectName[8];
    uint32_t    VirtualSize;
    uint32_t    SectionRVA;
    uint32_t    PhysicalSize;
    uint32_t    PhysicalOffset;
    uint32_t    res1;
    uint32_t    res2;
    uint32_t    res3;
    uint32_t    ObjectFlags;
};



void        *exebuff;
uint32_t    exesize,sect_num;
section     *exesec;


void * get_buff_offset(uint32_t rva)
{
    uint32_t realrva;

    realrva=rva-0x00400000;
    for (int i=0; i<sect_num;i++)
    {
        if ((exesec[i].SectionRVA<=realrva) && ((exesec[i].SectionRVA+exesec[i].VirtualSize)>=realrva ))
        {
            return (void *) &(((uint8_t *)exebuff)[exesec[i].PhysicalOffset+(realrva-exesec[i].SectionRVA)]);
        }

    }

    return NULL;
}







int main(int argc, char *argv[])
{

    FILE        *exefile, *adrfile, *textfile;
    uint32_t    peoff;
    void        *p_pe;

    char        buff[1024];


    exefile=fopen("exe.exe","rb");
    adrfile=fopen("adr.txt","rb");
    textfile=fopen("texts.txt","w");

    fseek(exefile,0,SEEK_END);
    exesize=ftell(exefile);
    fseek(exefile,0,SEEK_SET);

    exebuff=malloc(exesize);

    fread(exebuff,exesize,1,exefile);
    fclose(exefile);

    peoff=((uint32_t *)exebuff)[0xF];//0x3c - offset to pe header
    p_pe=&((uint8_t *)exebuff)[peoff];
    sect_num=((uint16_t *)p_pe)[3]; //0x06 - sections number
    exesec=(section *)&((uint8_t *)p_pe)[((uint16_t *)p_pe)[0xA] + 0x18]; //from magic + NT Header Size


    while (!feof(adrfile))
    {
        memset(buff,0,1024);
        fgets(buff,1024,adrfile);


        int z;
        z=0;
        for (int i=0;i<1024;i++)
        {
            if (buff[i]==0x0) break;
            if ((buff[i]==0xA)||(buff[i]==0xD))
            {
                buff[i]=0;
                break;
            }
            z=i;
        }

        if (z>8)
        {


            uint32_t    straddr,realstraddr;

            for (int i=0;i<1024;i++)
            {
                if (buff[i]=='o')
                {
                    sscanf(&buff[i+1],"%X",&straddr);

                    realstraddr=*(uint32_t *)get_buff_offset(straddr);
                    break;
                }

                if (buff[i]=='m')
                {
                    sscanf(&buff[i+1],"%X",&straddr);
                    realstraddr=*(uint32_t *)((uint32_t)get_buff_offset(straddr)+1);
                    break;
                }

                if (buff[i]=='r')
                {
                    sscanf(&buff[i+1],"%X",&straddr);
                    realstraddr=*(uint32_t *)((uint32_t)get_buff_offset(straddr)+3);
                    break;
                }

                if (buff[i]=='p')
                {
                    sscanf(&buff[i+1],"%X",&straddr);
                    realstraddr=*(uint32_t *)((uint32_t)get_buff_offset(straddr)+1);
                    break;
                }
            }

            realstraddr=(uint32_t)get_buff_offset(realstraddr);

            int j;

            j=0;

            while (((uint8_t *)realstraddr)[j]!=0)
            {
                if (((uint8_t *)realstraddr)[j]==0xA)
                    ((uint8_t *)realstraddr)[j]='\\';
                if (((uint8_t *)realstraddr)[j]==0xD)
                    ((uint8_t *)realstraddr)[j]='n';
                j++;
            }

            fprintf(textfile,"%s%s\n",(char *)realstraddr,buff);
        }
    }


    fclose(adrfile);
    fclose(textfile);




    return 0;
}
