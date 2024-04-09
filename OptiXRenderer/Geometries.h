#pragma once

#include <optixu/optixu_math_namespace.h>
#include <optixu/optixu_matrix_namespace.h>

/**
 * Structures describing different geometries should be defined here.
 */

struct Attributes
{
    // TODO: define the attributes structure
    optix::float3 ambient;
    optix::float3 diffuse;
    optix::float3 specular;
    optix::float3 emission;
    optix::float3 shininess;
};

struct Triangle
{
    
    // TODO: define the triangle structure
    optix::float3 v0;
    optix::float3 v1;
    optix::float3 v2;
    Attributes attributes;
};

struct Sphere
{
    // TODO: define the sphere structure
    Attributes attributes;

};

