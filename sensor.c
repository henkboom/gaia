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

#include "GL/glfw.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//// Camera Capture from OpenCV ///////////////////////////////////////////////

#define PIXEL(img, x, y, k) (((uchar*)(img)->imageData)[(y)*(img)->widthStep+(x)*(img)->nChannels+(k)])

// locks
static GLFWmutex ready_to_read;
static GLFWmutex ready_to_update;

// shared data
// BEWARE THERE BE DEMONS HERE!!!
static IplImage *lastFrame = NULL;
static IplImage *diffFrame = NULL;
static int changed = 0;
static double activity_level = 0;
// end shared data

static void GLFWCALL capture_loop(void *arg)
{
    while(1)
    {
        static CvCapture *captureCam = NULL;

        if(!captureCam) captureCam = cvCaptureFromCAM(0);
        if(cvGrabFrame(captureCam))
        {
            IplImage* img = cvRetrieveFrame(captureCam, 0);
            if(!lastFrame) lastFrame =
                cvCreateImage(cvSize(img->width, img->height), IPL_DEPTH_8U, 3);
            if(!diffFrame) diffFrame =
                cvCreateImage(cvSize(img->width, img->height), IPL_DEPTH_8U, 3);

            glfwLockMutex(ready_to_update);

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
                PIXEL(diffFrame, i, j, k) = abs(d);
            }
            int area = img->width * img->height * img->nChannels;

            if(lastFrame) cvReleaseImage(&lastFrame);
            lastFrame = cvCloneImage(img);

            activity_level = (double)differences/(area*255);
        }

        glfwUnlockMutex(ready_to_read);
    }
}

static double read_activity_level()
{
    static int initted = 0;
    if(!initted)
    {
        ready_to_read = glfwCreateMutex();
        ready_to_update = glfwCreateMutex();
        glfwLockMutex(ready_to_update);
        glfwCreateThread(capture_loop, NULL);
        initted = 1;
    }

    glfwLockMutex(ready_to_read);

    double ret = activity_level;

    glfwUnlockMutex(ready_to_update);

    return ret;
}

static unsigned get_texture(int get_diff)
{
    return 0;
//    // LOCK(ready_to_read)
//
//    static unsigned tex = 0;
//    IplImage * img = lastFrame;
//    if(get_diff) img = diffFrame;
//
//    if(img == NULL) return 0;
//
//    if(changed == 0) return tex;
//    changed = 0;
//
//    if(tex == 0)
//        glGenTextures(1, &tex);
//
//    glBindTexture(GL_TEXTURE_2D, tex);
//    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, img->width, img->height, 0,
//    //             GL_BGR, GL_UNSIGNED_BYTE, img->imageData);
//    gluBuild2DMipmaps(GL_TEXTURE_2D, 3, img->width, img->height, GL_RGB,
//                      GL_UNSIGNED_BYTE, img->imageData);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//
//    glBindTexture(GL_TEXTURE_2D, 0);
//
//    // RELEASE(ready_to_read)
//
//    return tex;
}

//// Lua Bindings /////////////////////////////////////////////////////////////

static int sensor__read_activity_level(lua_State *L)
{
    double ret = read_activity_level();
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
    {"read_activity_level", sensor__read_activity_level},
    {"get_texture", sensor__get_texture},
    {NULL, NULL}
};

int luaopen_sensor(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, sensor_lib);
    return 1;
}
