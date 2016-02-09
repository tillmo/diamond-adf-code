#ifndef DIAMOND_MODEL_HPP
#define DIAMOND_MODEL_HPP

#include <diamond/semantics/ISemantics.hpp>

namespace diamond{
class Model : public diamond::ISemantics{
public:


  // ISemantics interface
public:
  bool needsFunc(){};
};
}

#endif /* DIAMOND_MOD>EL_HPP */
