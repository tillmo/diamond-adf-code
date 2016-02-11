#ifndef DIAMOND_PREFERRED_HPP
#define DIAMOND_PREFERRED_HPP

#include <diamond/semantics/ISemantics.hpp>
#include <diamond/semantics/ITwoStep.hpp>
#include <diamond/config.h>
#include <clingo/clingocontrol.hh>
#include <functional>

namespace diamond{
/**
 * @brief The Model class
 * one step call, no transformation neeeded
 */
class Preferred : public diamond::ISemantics, diamond::ITwoStep{
protected:
public:
  Preferred (diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_PREFERRED_HPP */
