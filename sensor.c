#include <stdio.h>
#include <math.h>

#include <opencv/cv.h>
#include <opencv/highgui.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//// Camera Capture from OpenCV ///////////////////////////////////////////////

#define PIXEL(img, x, y, k) (((uchar*)(img)->imageData)[(y)*(img)->widthStep+(x)*(img)->nChannels+(k)])

static double capture()
{
    static CvCapture *capture = NULL;
    static IplImage *lastFrame = NULL;
    static IplImage *diffFrame = NULL;
  
    if(!capture) capture = cvCaptureFromCAM(0);
    if(!cvGrabFrame(capture)) return -1;
    IplImage* img = cvRetrieveFrame(capture);
    if(!lastFrame) lastFrame =
        cvCreateImage(cvSize(img->width, img->height), IPL_DEPTH_8U, 3);
    if(!diffFrame) diffFrame =
        cvCreateImage(cvSize(img->width, img->height), IPL_DEPTH_8U, 3);
  
    // count differences
    int i, j, k;
    uint differences = 0;
    for(j = 0; j < img->height; j++)
    for(i = 0; i < img->width; i++)
    for(k = 0; k < img->nChannels; k++)
    {
        int d = ((int)PIXEL(img, i, j, k) - PIXEL(lastFrame, i, j, k));
        if(-32 < d && d < 32) d = 0;
        differences += abs(d);
        PIXEL(diffFrame, i, j, k) = 128 + d/2;
    }
    int area = img->width * img->height * img->nChannels;
  
    if(lastFrame) cvReleaseImage(&lastFrame);
    lastFrame = cvCloneImage(img);
    return (double)differences/(area*255);
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

static const luaL_Reg sensor_lib[] =
{
    {"capture", sensor__capture},
    {NULL, NULL}
};

int luaopen_sensor(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, sensor_lib);
    return 1;
}
