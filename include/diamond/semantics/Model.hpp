#ifndef DIAMOND_MODEL_HPP
#define DIAMOND_MODEL_HPP

#include <diamond/semantics/ISemantics.hpp>
#include <diamond/config.h>
#include <clingo/clingocontrol.hh>
#include <functional>

namespace diamond{
/**
 * @brief The Model class
 * one step call, no transformation neeeded
 */
class Model : public diamond::ISemantics{
protected:
  //diamond::AppOptions* appOpt;
public:
  Model(diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_MOD>EL_HPP */
