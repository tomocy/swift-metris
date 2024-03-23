// tomocy

#pragma once

#include "Shader+Geometry.h"
#include "Shader+Physics.h"

namespace D3 {

struct Light {
public:
    float3 applyTo(const float3 color) const
    {
        return color * this->color * intensity;
    }

public:
    float3 direction() const
    {
        return metal::normalize({
            aspect.view.columns[0][2],
            aspect.view.columns[1][2],
            aspect.view.columns[2][2],
        });
    }

    float3 position() const
    {
        return aspect.view.columns[3].xyz;
    }

public:
    float3 color;
    float intensity;
    Aspect aspect;
};

struct Lights {
public:
    struct Ambient {
    public:
        float3 applyTo(const float3 color) const constant
        {
            const auto v = *this;
            return v.applyTo(color);
        }

        float3 applyTo(const float3 color) const
        {
            return value.applyTo(color);
        }

    public:
        Light value;
    };

    struct Directional {
    public:
        float3 applyTo(
            const float3 color,
            const metal::depth2d<float> shadow,
            const Positions::WVC positions,
            const Coordinates::InWorld normal
        ) const constant
        {
            const auto v = *this;
            return v.applyTo(color, shadow, positions, normal);
        }

        float3 applyTo(
            const float3 color,
            const metal::depth2d<float> shadow,
            const Positions::WVC positions,
            const Coordinates::InWorld normal
        ) const
        {
            const struct {
                float3 toLight;
                float3 toView;
                float3 normal;
            } dirs = {
                .toLight = -value.direction(),
                .toView = -metal::normalize(positions.inView.value.xyz),
                .normal = metal::normalize(normal.value.xyz),
            };

            const auto howUnshaded = 1 - Physics::Shade::measure(shadow, value.aspect, positions.inWorld);

            const auto howDiffuse = Physics::Diffuse::measure(dirs.toLight, dirs.normal) * howUnshaded;
            const auto howSpecular = Physics::Specular::measure(dirs.toLight, dirs.toView, dirs.normal) * howUnshaded;

            return value.applyTo(color * (howDiffuse + howSpecular));
        }

    public:
        Light value;
    };

    struct Point {
    public:
        float3 applyTo(
            const float3 color,
            const Positions::WVC positions,
            const Coordinates::InWorld normal
        ) const constant
        {
            const auto v = *this;
            return v.applyTo(color, positions, normal);
        }

        float3 applyTo(
            const float3 color,
            const Positions::WVC positions,
            const Coordinates::InWorld normal
        ) const
        {
            const auto toLight = value.position() - positions.inWorld.value.xyz;
            const auto howDistant = metal::dot(toLight, toLight);
            const auto attenuation = 1 / metal::max(howDistant, 1e-4);

            const struct {
                float3 toLight;
                float3 toView;
                float3 normal;
            } dirs = {
                .toLight = metal::normalize(toLight),
                .toView = -metal::normalize(positions.inView.value.xyz),
                .normal = metal::normalize(normal.value.xyz),
            };

            const auto howDiffuse = Physics::Diffuse::measure(dirs.toLight, dirs.normal) * attenuation;
            const auto howSpecular = Physics::Specular::measure(dirs.toLight, dirs.toView, dirs.normal) * attenuation;

            return value.applyTo(color * (howDiffuse + howSpecular));
        }

    public:
        Light value;
    };

public:
    Ambient ambient;
    Directional directional;
    Point point;
};

}
