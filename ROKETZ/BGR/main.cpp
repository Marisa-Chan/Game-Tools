#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>

#define max_offsets 1024

uint32_t offsets[max_offsets];
uint32_t chunksz[max_offsets];

uint32_t offs_cnt=0;

char tmpbuf[0xFFFF];

int main(int argc, char **argv)
{
    printf("%s\n",argv[1]);
    FILE *f = fopen(argv[1],"rb");

    uint32_t tmp;
    fread(&tmp,4,1,f);

    if (tmp != 0x5247424C) //is it LBGR?
        exit(2);


    offs_cnt = 0;

    while(!feof(f))
    {
        unsigned short chnksz=0;
        fread(&chnksz,2,1,f);
        offsets[offs_cnt] = ftell(f);
        chunksz[offs_cnt] = chnksz;
        offs_cnt++;
        fread(tmpbuf,chnksz,1,f);
    }


    //Read level params

    fseek(f,offsets[0],SEEK_SET);

    unsigned short level_width;
    unsigned short level_height;

    fread(&level_width,2,1,f);
    fread(&level_height,2,1,f);

    unsigned short chunk0_unk_pointer;

    fread(&chunk0_unk_pointer,2,1,f);

    unsigned short level_elements_cnt;

    fread(&level_elements_cnt,2,1,f);

    unsigned char level_palette[0x100 * 3]; //256 24bits

    fread(level_palette,0x300,1,f);

    for(unsigned int i = 0; i<0x100; i++) // BGR -> RGB
    {
        level_palette[i*3] ^= level_palette[i*3+2];
        level_palette[i*3+2] ^= level_palette[i*3];
        level_palette[i*3] ^= level_palette[i*3+2];
    }

    for(unsigned int i = 0; i<0x300; i++) // make color more lighten
        level_palette[i] <<= 2;

    struct __attribute__ ((__packed__)) level_chunks
    {
        short index;
        short x;
        short y;
        short x2;
        short y2;
    };

    level_chunks *lev_chunks = (level_chunks *)malloc(sizeof(level_chunks)*level_elements_cnt);

    fread(lev_chunks,sizeof(level_chunks),level_elements_cnt,f);

    unsigned int imgsz = level_width * level_height;
    unsigned char *image = (unsigned char *)malloc(imgsz);


    memset(image,0,imgsz);

    for (int j = 0; j<level_elements_cnt; j++)
    {
        fseek(f,offsets[lev_chunks[j].index],SEEK_SET); // go to chunk
        unsigned short chunk_width,chunk_height;
        fread(&chunk_width,2,1,f);
        fread(&chunk_height,2,1,f);



        for (int k=0; k<chunk_height*4;k++)
        {
            char cur_chun = k % 4;

            unsigned short dataoff;
            fread(&dataoff,2,1,f);

            int curpos = ftell(f);

            unsigned short datasz=0;

            if (k < (chunk_height*4)-1)
            {
                fread(&datasz,2,1,f);
                datasz -= dataoff;
            }
            else
            {
                datasz = chunksz[lev_chunks[j].index]-dataoff;
            }

            fseek(f,offsets[lev_chunks[j].index]+dataoff,SEEK_SET);

            unsigned char *temp = (unsigned char *)malloc(datasz);

            fread(temp,datasz,1,f);

            //parsing

            int curps=0;

            int xpos = 0;

            while (curps<datasz)
            {
                unsigned char space = temp[curps];
                xpos+=space;
                curps++;
                unsigned char count = temp[curps];
                curps++;

                if (count == 0)
                    break;

                while(count > 0 && curps < datasz)
                {
                    if (lev_chunks[j].x + (xpos*4+cur_chun) < level_width)
                        if (lev_chunks[j].x + (xpos*4+cur_chun) + ((lev_chunks[j].y+k/4)*level_width) < imgsz)
                            image[lev_chunks[j].x + (xpos*4+cur_chun) + ((lev_chunks[j].y+k/4)*level_width)] = temp[curps];
                    xpos++;
                    curps++;
                    count--;
                }


            }
            free(temp);

            fseek(f,curpos,SEEK_SET); //back to previous
        }
    }


    fclose(f);

    char outfil[1024];

    sprintf(outfil,"%s.tga",argv[1]);

    f = fopen(outfil,"wb");

    int tmp2=0x020000;
    fwrite(&tmp2,3,1,f);
    tmp=0;
    fwrite(&tmp2,4,1,f);
    fwrite(&tmp2,1,1,f);
    fwrite(&tmp2,4,1,f);

    fwrite(&level_width,2,1,f);
    fwrite(&level_height,2,1,f);

    tmp2=32;
    fwrite(&tmp2,1,1,f);
    tmp2=0x20; //For nemesis 0x20!
    fwrite(&tmp2,1,1,f);

    int lev_h = level_height;
    int lev_w = level_width;

    //unsigned char *arr = (unsigned char *)malloc(lev_h*lev_w*4);

    for (int32_t j=0;j< lev_h;j++)
        for(int32_t i=0;i<lev_w; i++)
        {
            int temp = level_palette[image[i+j*level_width]*3] |
                      (level_palette[image[i+j*level_width]*3+1] << 8) |
                      (level_palette[image[i+j*level_width]*3+2] << 16);
            //fwrite(&level_palette[image[i+j*level_width]*3],3,1,f);
            if (image[i+j*level_width] != 0)
                temp |= 0xFF000000;

            fwrite(&temp,4,1,f);
        }



    //fwrite(image,imgsz,1,f);
    fclose(f);


    return 0;
}
