#include "SceneLoader.h"
#define PI 3.14159265

optix::float3 upvector(optix::float3 up, optix::float3 zvec) {
    optix::float3 x = optix::cross(up, zvec);
    optix::float3 y = optix::cross(zvec, x);
    optix::float3 ret = optix::normalize(y);
    return ret;

}

void SceneLoader::rightMultiply(const optix::Matrix4x4& M)
{
    optix::Matrix4x4& T = transStack.top();
    T = T * M;
}

optix::float3 SceneLoader::transformPoint(optix::float3 v)
{
    optix::float4 vh = transStack.top() * optix::make_float4(v, 1);
    return optix::make_float3(vh) / vh.w; 
}

optix::float3 SceneLoader::transformNormal(optix::float3 n)
{
    return optix::make_float3(transStack.top() * make_float4(n, 0));
}

template <class T>
bool SceneLoader::readValues(std::stringstream& s, const int numvals, T* values)
{
    for (int i = 0; i < numvals; i++)
    {
        s >> values[i];
        if (s.fail())
        {
            std::cout << "Failed reading value " << i << " will skip" << std::endl;
            return false;
        }
    }
    return true;
}


std::shared_ptr<Scene> SceneLoader::load(std::string sceneFilename)
{
    // Attempt to open the scene file 
    std::ifstream in(sceneFilename);
    if (!in.is_open())
    {
        // Unable to open the file. Check if the filename is correct.
        throw std::runtime_error("Unable to open scene file " + sceneFilename);
    }

    auto scene = std::make_shared<Scene>();
    scene->attenuation = optix::make_float3(1,0,0);

    transStack.push(optix::Matrix4x4::identity());

    std::string str, cmd;
    Attributes currentAttributes;
    currentAttributes.ambient = optix::make_float3(.2, .2, .2);
    currentAttributes.emission = optix::make_float3(0, 0, 0);

    // Read a line in the scene file in each iteration
    while (std::getline(in, str))
    {
        // Ruled out comment and blank lines
        if ((str.find_first_not_of(" \t\r\n") == std::string::npos) 
            || (str[0] == '#'))
        {
            continue;
        }

        // Read a command
        std::stringstream s(str);
        s >> cmd;

        // Some arrays for storing values
        float fvalues[12];
        int ivalues[3];
        std::string svalues[1];

        if (cmd == "size" && readValues(s, 2, fvalues))
        {
            scene->width = (unsigned int)fvalues[0];
            scene->height = (unsigned int)fvalues[1];
        }
        else if (cmd == "output" && readValues(s, 1, svalues))
        {
            scene->outputFilename = svalues[0];
        }
        else if (cmd == "camera" && readValues(s, 10, fvalues)) {
            scene->eye = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
            scene->center = optix::make_float3(fvalues[3], fvalues[4], fvalues[5]);
            
            optix::float3 upinit = optix::make_float3(fvalues[6], fvalues[7], fvalues[8]);
            scene->up = upvector(upinit, scene->eye - scene->center);
            scene->fovy = optix::make_float1(fvalues[9] * PI / 180);
        }
        else if (cmd == "vertex" && readValues(s, 3, fvalues)) {
            scene->vertices.push_back(optix::make_float3(fvalues[0], fvalues[1], fvalues[2]));
        }
        else if (cmd == "tri" && readValues(s, 3, fvalues)) {
            Triangle triangle;
            triangle.v0 = transformPoint(scene->vertices[fvalues[0]]);
            triangle.v1 = transformPoint(scene->vertices[fvalues[1]]);
            triangle.v2 = transformPoint(scene->vertices[fvalues[2]]);
            triangle.attributes = currentAttributes;
            scene->triangles.push_back(triangle);
        }
        else if (cmd == "translate" && readValues(s, 3, fvalues)) {
            optix::Matrix4x4 translate = optix::Matrix4x4::translate(optix::make_float3(fvalues[0], fvalues[1], fvalues[2]));
            rightMultiply(translate);
        }
        else if (cmd == "rotate" && readValues(s, 4, fvalues)) {
            optix::float3 axis = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
            float rad = fvalues[4] * PI / 180;
            optix::Matrix4x4 rotate = optix::Matrix4x4::rotate(rad, axis);
            rightMultiply(rotate);
        }
        else if (cmd == "scale" && readValues(s, 3, fvalues)) {
            optix::Matrix4x4 scale = optix::Matrix4x4::scale(optix::make_float3(fvalues[0], fvalues[1], fvalues[2]));
            rightMultiply(scale);
        }
        else if (cmd == "pushTransform") {
            transStack.push(transStack.top());
        }
        else if (cmd == "popTransform") {
            transStack.pop();
        }
        else if (cmd == "directional" && readValues(s, 6, fvalues)) {
            DirectionalLight directionalLight;
            directionalLight.dir = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
            directionalLight.color = optix::make_float3(fvalues[3], fvalues[4], fvalues[5]);
            scene->dlights.push_back(directionalLight);
        }
        else if (cmd == "point" && readValues(s, 6, fvalues)) {
            PointLight pointLight;
            pointLight.pos = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
            pointLight.color = optix::make_float3(fvalues[3], fvalues[4], fvalues[5]);
            scene->plights.push_back(pointLight);
        }
        else if (cmd == "attenuation" && readValues(s, 3, fvalues)) {
            scene->attenuation = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
        }
        else if (cmd == "ambient" && readValues(s, 3, fvalues)) {
            currentAttributes.ambient = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
        }
        else if (cmd == "diffuse" && readValues(s, 3, fvalues)) {
            currentAttributes.diffuse = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
        }
        else if (cmd == "specular" && readValues(s, 3, fvalues)) {
            currentAttributes.specular = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
        }
        else if (cmd == "shininess" && readValues(s, 1, fvalues)) {
            currentAttributes.shininess = fvalues[0];
        }
        else if (cmd == "emission" && readValues(s, 3, fvalues)) {
            currentAttributes.emission = optix::make_float3(fvalues[0], fvalues[1], fvalues[2]);
        }

    }

    in.close();

    return scene;
}


