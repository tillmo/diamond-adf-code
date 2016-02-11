#ifndef DIAMOND_STABLEMODEL_HPP
#define DIAMOND_STABLEMODEL_HPP

#include <diamond/semantics/ISemantics.hpp>
#include <diamond/config.h>
#include <clingo/clingocontrol.hh>
#include <functional>

namespace diamond{
/**
 * @brief The Model class
 * one step call, no transformation neeeded
 */
class StableModel : public diamond::ISemantics{
protected:
public:
  StableModel(diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_STABLEMODEL_HPP */
