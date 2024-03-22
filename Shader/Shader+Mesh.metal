// tomocy

#include "Shader+Geometry.h"
#include "Shader+Texture.h"

namespace D3 {
namespace Mesh {

struct Raster {
public:
    Positions::WVC positions;
    Positions::InWorld normal;
    Texture::Reference texture;
};

}
}
