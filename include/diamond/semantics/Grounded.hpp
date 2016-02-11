#ifndef DIAMOND_GROUNDED_HPP
#define DIAMOND_GROUNDED_HPP

#include <diamond/semantics/ISemantics.hpp>
#include <diamond/config.h>
#include <clingo/clingocontrol.hh>
#include <functional>

namespace diamond{
/**
 * @brief The Model class
 * one step call, no transformation neeeded
 */
class Grounded : public diamond::ISemantics{
protected:
public:
  Grounded(diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_GROUNDED_HPP */
