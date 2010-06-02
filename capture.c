#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef __APPLE__
#include "OpenGL/gl.h"
#include "OpenGL/glu.h"
#else
#include "GL/gl.h"
#include "GL/glu.h"
#endif

#include <png.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#define WIDTH 640
#define HEIGHT 480

static int frame_count = 0;

static int capture__capture_frame(lua_State *L)
{
    int i;
    char filename[7+6+4+1];
    if(frame_count > 999999) return 0;
    sprintf(filename, "frames/%.6i.png", frame_count);
    printf("saving to \"%s\"\n", filename);

    GLubyte buffer[WIDTH * HEIGHT * 3];
    GLubyte *rows[HEIGHT];
    for(i = 0; i != HEIGHT; i++)
    {
        rows[i] = buffer + i * WIDTH * 3;
    }

    glReadPixels(0, 0, WIDTH, HEIGHT, GL_RGB, GL_UNSIGNED_BYTE, buffer);
    
    // begin png writing code
    png_structp png_ptr = png_create_write_struct(
        PNG_LIBPNG_VER_STRING,
        (void*)NULL, NULL, NULL);
    if(!png_ptr) return luaL_error(L, "png_create_write_struct error");

    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr)
    {
       png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
       return luaL_error(L, "png_create_info_struct error");
    }

    FILE *fp = fopen(filename, "wb");
    if(!fp) return luaL_error(L, "%s", strerror(errno));

    if (setjmp(png_jmpbuf(png_ptr)))
    {
        png_destroy_write_struct(&png_ptr, &info_ptr);
        fclose(fp);
        return luaL_error(L, "png writing error");
    }

    png_init_io(png_ptr, fp);

    png_set_IHDR(
        png_ptr, info_ptr, WIDTH, HEIGHT, 8, PNG_COLOR_TYPE_RGB,
        PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT,
        PNG_FILTER_TYPE_DEFAULT);

    png_set_rows(png_ptr, info_ptr, rows);
    png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

    png_write_end(png_ptr, info_ptr);
    png_destroy_write_struct(&png_ptr, &info_ptr);
    // end png writing code

    fclose(fp);

    frame_count++;

    return 0;
}

static const luaL_Reg capture_lib[] =
{
    {"capture_frame", capture__capture_frame},
    {NULL, NULL}
};

int luaopen_capture(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, capture_lib);
    return 1;
}
