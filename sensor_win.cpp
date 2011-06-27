#include <string.h>
#include <stdlib.h>
#include <GL/glfw.h>
extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}
#include <videoInput.h>

#define FRAME_WIDTH 720
#define FRAME_HEIGHT 480
#define FRAME_CHANNELS 3

typedef struct {
    GLubyte image[FRAME_WIDTH * FRAME_HEIGHT * FRAME_CHANNELS];
    GLubyte diff[FRAME_WIDTH * FRAME_HEIGHT * FRAME_CHANNELS];
    double activity_level;
} frame_buffer_s;

static GLFWmutex frame_mutex;
static frame_buffer_s * volatile front_buffer = NULL;
static frame_buffer_s * volatile back_buffer = NULL;

static videoInput VI;

static int dev = 0;
static void init_capture()
{
	videoInput::listDevices();	
    VI.setIdealFramerate(dev, 20);
    //TODO check the dimensions after, they might not be the same
	VI.setupDevice(dev, FRAME_WIDTH, FRAME_HEIGHT); 
}

static void get_frame(GLubyte *image)
{
    do
    {
        glfwSleep(0.02);
    } while(!VI.isFrameNew(dev));

    VI.getPixels(dev, image, true);
    printf("size: %d\n", VI.getSize(dev) / 480 / 3);
}

static void process_frame()
{
    GLubyte *current = back_buffer->image;
    GLubyte *last = front_buffer->image;
    GLubyte *diff = back_buffer->diff;

    int area = FRAME_WIDTH * FRAME_HEIGHT * FRAME_CHANNELS;
    int differences = 0;
    for(int i = 0; i < area; i++)
    {
        int d = (int)current[i] - last[i];
        if(d < 0) d = -d;
        if(d < 22) d = 0;
        diff[i] = d;
        differences += abs(d);
    }

    back_buffer->activity_level = (double)differences / (area*255);
}

static void GLFWCALL capture_loop(void *arg)
{
    init_capture();
    while(1)
    {
        get_frame(back_buffer->image);

        process_frame();

        // swap
        glfwLockMutex(frame_mutex);
        frame_buffer_s *tmp = front_buffer;
        front_buffer = back_buffer;
        back_buffer = tmp;
        glfwUnlockMutex(frame_mutex);
    }
}

static void init()
{
    frame_mutex = glfwCreateMutex();

    front_buffer = (frame_buffer_s *)malloc(sizeof(frame_buffer_s));
    memset(front_buffer, 0, sizeof(frame_buffer_s));
    front_buffer->activity_level = 0;

    back_buffer = (frame_buffer_s *)malloc(sizeof(frame_buffer_s));
    memset(back_buffer, 0, sizeof(frame_buffer_s));
    back_buffer->activity_level = 0;

    glfwCreateThread(capture_loop, NULL);
}

static double read_activity_level()
{
    static int initted = 0;
    if(!initted)
    {
        init();
        initted = 1;
    }

    glfwLockMutex(frame_mutex);
    double activity_level = front_buffer->activity_level;
    glfwUnlockMutex(frame_mutex);

    return activity_level;
}

static unsigned get_texture(int get_diff)
{
    static GLuint tex = 0;
    if(tex == 0)
        glGenTextures(1, &tex);

    glfwLockMutex(frame_mutex);

    glBindTexture(GL_TEXTURE_2D, tex);
    GLubyte *image;
    if(get_diff)
        image = front_buffer->diff;
    else
        image = front_buffer->image;
    gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, FRAME_WIDTH, FRAME_HEIGHT,
                      GL_RGB, GL_UNSIGNED_BYTE, image);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, 0);

    glfwUnlockMutex(frame_mutex);

    return tex;
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

extern "C" {
int luaopen_sensor(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, sensor_lib);
    return 1;
}
}
