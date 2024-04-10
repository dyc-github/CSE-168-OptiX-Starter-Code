#include "optix.h"
#include "optix_device.h"
#include "Geometries.h"

using namespace optix;

rtBuffer<Triangle> triangles; // a buffer of all spheres

rtDeclareVariable(Ray, ray, rtCurrentRay, );

// Attributes to be passed to material programs 
rtDeclareVariable(Attributes, attrib, attribute attrib, );
rtDeclareVariable(float3, intersectionPos, attribute intersectionPosition, );
rtDeclareVariable(float3, normal, attribute normal, );

RT_PROGRAM void intersect(int primIndex)
{
    // Find the intersection of the current ray and triangle
    Triangle tri = triangles[primIndex];
    float t;

    // TODO: implement triangle intersection test here
    float3 norm = normalize(cross(tri.v2 - tri.v0, tri.v1 - tri.v0));
    
    t = (dot(tri.v0, norm) - dot(ray.origin, norm)) / dot(ray.direction, norm);
    
    //Barycentric Approach.Reference.https://ceng2.ktu.edu.tr/~cakir/files/grafikler/Texture_Mapping.pdf
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
        attrib = tri.attributes;
        intersectionPos = p;
        normal = norm;
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