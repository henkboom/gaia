#include <stdio.h>
#include <math.h>

#include <opencv/cv.h>
#include <opencv/highgui.h>

#ifdef __APPLE__
#include "OpenGL/gl.h"
#include "OpenGL/glu.h"
#else
#include "GL/gl.h"
#include "GL/glu.h"
#endif

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//// Camera Capture from OpenCV ///////////////////////////////////////////////

#define PIXEL(img, x, y, k) (((uchar*)(img)->imageData)[(y)*(img)->widthStep+(x)*(img)->nChannels+(k)])

static CvCapture *captureCam = NULL;
static IplImage *lastFrame = NULL;
static IplImage *diffFrame = NULL;

static int changed = 0;

static double capture()
{
    if(!captureCam) captureCam = cvCaptureFromCAM(0);
    if(!cvGrabFrame(captureCam)) return -1;
    IplImage* img = cvRetrieveFrame(captureCam, 0);
    if(!lastFrame) lastFrame =
        cvCreateImage(cvSize(img->width, img->height), IPL_DEPTH_8U, 3);
    if(!diffFrame) diffFrame =
        cvCreateImage(cvSize(img->width, img->height), IPL_DEPTH_8U, 3);

    changed = 1;
  
    // count differences
    int i, j, k;
    unsigned differences = 0;
    for(j = 0; j < img->height; j++)
    for(i = 0; i < img->width; i++)
    for(k = 0; k < img->nChannels; k++)
    {
        int d = ((int)PIXEL(img, i, j, k) - PIXEL(lastFrame, i, j, k));
        if(-22 < d && d < 22) d = 0;
        differences += abs(d);
        PIXEL(diffFrame, i, j, k) = 128 + d/2;
    }
    int area = img->width * img->height * img->nChannels;
  
    if(lastFrame) cvReleaseImage(&lastFrame);
    lastFrame = cvCloneImage(img);

    return (double)differences/(area*255);
}

static unsigned get_texture(int get_diff)
{
    static unsigned tex = 0;
    IplImage * img = lastFrame;
    if(get_diff) img = diffFrame;

    if(img == NULL) return 0;
    if(changed == 0) return tex;
    changed = 0;

    if(tex == 0)
        glGenTextures(1, &tex);

    glBindTexture(GL_TEXTURE_2D, tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, img->width, img->height, 0,
                 GL_BGR, GL_UNSIGNED_BYTE, img->imageData);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    glBindTexture(GL_TEXTURE_2D, 0);

    return tex;
}

//// Lua Bindings /////////////////////////////////////////////////////////////

static int sensor__capture(lua_State *L)
{
    double ret = capture();
    if(ret < 0)
    {
        lua_pushnil(L);
        lua_pushstring(L, "error capturing frame from sensor");
        return 2;
    }
    else
    {
        lua_pushnumber(L, ret);
        return 1;
    }
}

static int sensor__get_texture(lua_State *L)
{
    lua_pushnumber(L, get_texture(lua_toboolean(L, 1)));
    return 1;
}

static const luaL_Reg sensor_lib[] =
{
    {"capture", sensor__capture},
    {"get_texture", sensor__get_texture},
    {NULL, NULL}
};

int luaopen_sensor(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, sensor_lib);
    return 1;
}
