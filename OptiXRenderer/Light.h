#pragma once

#include <optixu/optixu_math_namespace.h>
#include <optixu/optixu_matrix_namespace.h>

/**
 * Structures describing different light sources should be defined here.
 */

struct PointLight
{
    // TODO: define the point light structure
    optix::float3 pos;
    optix::float3 color;
};

struct DirectionalLight
{
    // TODO: define the directional light structure
    optix::float3 dir;
    optix::float3 color;
};