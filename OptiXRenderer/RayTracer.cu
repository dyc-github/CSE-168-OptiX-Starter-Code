#include <optix.h>
#include <optix_device.h>
#include <optixu/optixu_math_namespace.h>
#include "random.h"

#include "Payloads.h"
#include "Geometries.h"
#include "Light.h"

using namespace optix;

// Declare light buffers
rtBuffer<PointLight> plights;
rtBuffer<DirectionalLight> dlights;

// Declare variables
rtDeclareVariable(Payload, payload, rtPayload, );
rtDeclareVariable(rtObject, root, , );
rtDeclareVariable(float3, origin, , );
rtDeclareVariable(float3, attenuation, , );

// Declare attibutes 
rtDeclareVariable(Attributes, attrib, attribute attrib, );
rtDeclareVariable(float3, intersectionPos, attribute intersectionPosition, );
rtDeclareVariable(float3, normal, attribute normal, );

RT_PROGRAM void closestHit()
{
    // TDOO: calculate the color using the Blinn-Phong reflection model

    float3 result = attrib.ambient + attrib.emission;
    for (int i = 0; i < plights.size(); i++) {
        PointLight plight = plights[i];
        float3 lightDir = plight.pos - intersectionPos;
        float3 half = normalize(lightDir + origin - intersectionPos);

        float3 diffuse = attrib.diffuse * max(dot(normal, lightDir), 0.0f);
        float3 specular = attrib.specular * pow(max(dot(normal, half), 0.0f), attrib.shininess);
        float3 lightIntensity = plight.color / (attenuation.x + attenuation.y * length(intersectionPos - plight.pos) + attenuation.z * pow(length(intersectionPos - plight.pos), 2));
        result += lightIntensity * (diffuse + specular);
    }
    for (int i = 0; i < dlights.size(); i++) {
        DirectionalLight dlight = dlights[i];
        float3 lightDir = dlight.dir;
        float3 half = normalize(lightDir + origin - intersectionPos);

        float3 diffuse = attrib.diffuse * max(dot(normal, lightDir), 0.0f);
        float3 specular = attrib.specular * pow(max(dot(normal, half), 0.0f), attrib.shininess);
        result += dlight.color * (diffuse + specular);
    }
    payload.radiance = result;
}