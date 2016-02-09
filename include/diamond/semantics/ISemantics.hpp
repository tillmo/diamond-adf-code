#ifndef DIAMOND_ISEMANTICS_HPP
#define DIAMOND_ISEMANTICS_HPP

#include <diamond/AppOptions.hpp>

namespace diamond{
//forward declarations
class AppOptions;

class ISemantics{
protected:
public:
  virtual bool needsFunc() = 0;
};
}

#endif /* DIAMOND_ISEMANTICS_HPP */
