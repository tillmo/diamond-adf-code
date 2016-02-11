#ifndef DIAMOND_COMPLETE_HPP
#define DIAMOND_COMPLETE_HPP

#include <diamond/semantics/ISemantics.hpp>
#include <diamond/config.h>
#include <clingo/clingocontrol.hh>
#include <functional>

namespace diamond{
/**
 * @brief The Model class
 * one step call, no transformation neeeded
 */
class Complete : public diamond::ISemantics{
protected:
public:
  Complete(diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_COMPLETE_HPP */
