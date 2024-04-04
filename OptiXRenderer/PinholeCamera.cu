#include <optix.h>
#include <optix_device.h>
#include <optixu/optixu_math_namespace.h>

#include "Payloads.h"

using namespace optix;

rtBuffer<float3, 2> resultBuffer; // used to store the render result

rtDeclareVariable(rtObject, root, , ); // Optix graph

rtDeclareVariable(uint2, launchIndex, rtLaunchIndex, ); // a 2d index (x, y)

rtDeclareVariable(int1, frameID, , );

// Camera info 

// TODO:: delcare camera varaibles here
rtDeclareVariable(float, height, , );
rtDeclareVariable(float, width, , );

rtDeclareVariable(float3, eye, ,);
rtDeclareVariable(float3, center, , );
rtDeclareVariable(float3, up, , );
rtDeclareVariable(float, fovy, , );





RT_PROGRAM void generateRays()
{
    float3 result = make_float3(0.f);

    // TODO: calculate the ray direction (change the following lines)
    optix::float3 w = optix::normalize(eye-center);
    optix::float3 u = optix::normalize(optix::cross(up, w));
    optix::float3 v = -optix::cross(w, u); //Im not sure why but it seems that I need to flip the up axis

    float fovx = 2 * atan(width * tan(fovy/ 2) / height);

    float alpha = tan(fovx / 2) * ((launchIndex.x + .5) - (width / 2)) / (width / 2);
    float beta = tan(fovy / 2) * ((height / 2) - (launchIndex.y + .5)) / (height / 2);

    

    float3 origin = eye; 
    float3 dir = normalize(alpha * u + beta * v - w);
    float epsilon = 0.001f; 

    // TODO: modify the following lines if you need
    // Shoot a ray to compute the color of the current pixel
    Ray ray = make_Ray(origin, dir, 0, epsilon, RT_DEFAULT_MAX);
    Payload payload;
    rtTrace(root, ray, payload);

    // Write the result
    resultBuffer[launchIndex] = payload.radiance;
}