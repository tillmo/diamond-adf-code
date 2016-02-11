#ifndef DIAMOND_SEMIMODEL_HPP
#define DIAMOND_SEMIMODEL_HPP

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
class SemiModel : public diamond::ISemantics, diamond::ITwoStep{
protected:
public:
  SemiModel (diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_SEMIMODEL_HPP */
