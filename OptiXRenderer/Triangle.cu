#include "optix.h"
#include "optix_device.h"
#include "Geometries.h"

using namespace optix;

rtBuffer<Triangle> triangles; // a buffer of all spheres

rtDeclareVariable(Ray, ray, rtCurrentRay, );

// Attributes to be passed to material programs 
rtDeclareVariable(Attributes, attrib, attribute attrib, );

RT_PROGRAM void intersect(int primIndex)
{
    // Find the intersection of the current ray and triangle
    Triangle tri = triangles[primIndex];
    float t;

    // TODO: implement triangle intersection test here
    float3 normal = normalize(cross(tri.v2 - tri.v0, tri.v1 - tri.v0));
    
    t = (dot(tri.v0, normal) - dot(ray.origin, normal)) / dot(ray.direction, normal);
    
    //barycentric coordinates: https://cdn-uploads.piazza.com/paste/kfpn5k0uz5667e/24c3d2d5ce14011276b44c34986dfdae4bae9865111501bb37f4a24ab361e365/cse167_week4_discussion.pdf
    float3 p = t * ray.direction + ray.origin;
    //vector from v0 to the point of intersection(p)
    optix::float3 AP = p - tri.v0;
    optix::float3 AB = tri.v1 - tri.v0;
    optix::float3 AC = tri.v2 - tri.v0;
    ////dot product
    float dot00 = optix::dot(AC, AC);
    float dot01 = optix::dot(AC, AB);
    float dot0P = optix::dot(AC, AP);
    float dot11 = optix::dot(AB, AB);
    float dot1P = optix::dot(AB, AP);
    ////Compute coordinates
    float denom = dot00 * dot11 - dot01 * dot01;
    float alpha = (dot11 * dot0P - dot01 * dot1P) / denom;
    float beta = (dot00 * dot1P - dot01 * dot0P) / denom;
    float gamma = 1.0 - alpha - beta;
 

    if (alpha < 0 || alpha >= 1 || beta < 0 || beta >= 1 || gamma < 0 || gamma >= 1) {
        return;
    }

    // Report intersection (material programs will handle the rest)
    if (rtPotentialIntersection(t))
    {
        // Pass attributes

        // TODO: assign attribute variables here
        attrib = tri.attributes;
        rtReportIntersection(0);
    }
}

RT_PROGRAM void bound(int primIndex, float result[6])
{
    Triangle tri = triangles[primIndex];

    // TODO: implement triangle bouding box
    result[0] = -1000.f;
    result[1] = -1000.f;
    result[2] = -1000.f;
    result[3] = 1000.f;
    result[4] = 1000.f;
    result[5] = 1000.f;
}