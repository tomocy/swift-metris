// tomocy

#pragma once

#include "Dimension.h"
#include <metal_stdlib>

namespace D3 {
struct Transform {
public:
    Coordinate apply(const Coordinate position) const constant
    {
        auto result = position;

        // In MSL, matrix are constructed in column-major order.
        // Therefore in applying transformations,
        // you should proceed from right to left: scale, rotate and then translate.
        //
        result = toScale() * result;
        result = toRotateAround(Axis::Z) * result;
        result = toTranslate() * result;

        return result;
    }

protected:
    Matrix toTranslate() const constant
    {
        return {
            { 1, 0, 0, 0 },
            { 0, 1, 0, 0 },
            { 0, 0, 1, 0 },
            { translate.x, translate.y, translate.z, 1 }
        };
    }

    Matrix toRotateAround(const Axis axis) const constant
    {
        const float s = metal::sin(rotate.z);
        const float c = metal::cos(rotate.z);

        switch (axis) {
        case Axis::X:
            return {
                { 1, 0, 0, 0 },
                { 0, c, s, 0 },
                { 0, -s, c, 0 },
                { 0, 0, 0, 1 }
            };
        case Axis::Y:
            return {
                { c, 0, -s, 0 },
                { 0, 1, 0, 0 },
                { s, 0, c, 0 },
                { 0, 0, 0, 1 }
            };
        case Axis::Z:
            return {
                { c, s, 0, 0 },
                { -s, c, 0, 0 },
                { 0, 0, 1, 0 },
                { 0, 0, 0, 1 }
            };
        }
    }

    Matrix toScale() const constant
    {
        return {
            { scale.x, 0, 0, 0 },
            { 0, scale.y, 0, 0 },
            { 0, 0, scale.z, 0 },
            { 0, 0, 0, 1 }
        };
    }

public:
    Measure translate = { 0, 0, 0 };
    Measure rotate = { 0, 0, 0 };
    Measure scale = { 1, 1, 1 };
};
}
