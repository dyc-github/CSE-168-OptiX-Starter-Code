#pragma once

#include <optixu/optixu_math_namespace.h>
#include <optixu/optixu_matrix_namespace.h>

#include "Geometries.h"
#include "Light.h"

struct Scene
{
    // Info about the output image
    std::string outputFilename;
    unsigned int width, height;

    std::string integratorName;

    std::vector<optix::float3> vertices;

    std::vector<Triangle> triangles;
    std::vector<Sphere> spheres;

    std::vector<DirectionalLight> dlights;
    std::vector<PointLight> plights;

    // TODO: add other variables that you need here
    optix::float3 attenuation;

    optix::float3 eye;
    optix::float3 center;
    optix::float3 up;
    optix::float1 fovy;

    Scene()
    {
        outputFilename = "raytrace.png";
        integratorName = "raytracer";
    }
};