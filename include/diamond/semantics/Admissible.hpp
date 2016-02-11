#ifndef DIAMOND_ADMISSIBLE_HPP
#define DIAMOND_ADMISSIBLE_HPP

#include <diamond/semantics/ISemantics.hpp>
#include <diamond/config.h>
#include <clingo/clingocontrol.hh>
#include <functional>

namespace diamond{
/**
 * @brief The Model class
 * one step call, no transformation neeeded
 */
class Admissible : public diamond::ISemantics{
protected:
public:
  Admissible (diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_ADMISSIBLE_HPP */
